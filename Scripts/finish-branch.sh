#!/bin/bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "❌ Dependência não encontrada: $command_name"
        exit 1
    fi
}

usage() {
    echo "Uso:"
    echo "./Scripts/finish-branch.sh"
    echo ""
    echo "Execute o comando permanecendo na branch"
    echo "depois que o Pull Request tiver sido mesclado."
}

require_command git
require_command gh

if [[ "$#" -ne 0 ]]; then
    usage
    exit 1
fi

REMOTE_NAME="${REMOTE_NAME:-origin}"
BASE_BRANCH="${BASE_BRANCH:-main}"
GITHUB_HOST="${GITHUB_HOST:-github.com}"
EXPECTED_GITHUB_LOGIN="${EXPECTED_GITHUB_LOGIN:-leomoraesitu}"

if ! ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    echo "❌ Este comando deve ser executado dentro de um repositório Git."
    exit 1
fi

cd "$ROOT_DIR"

CURRENT_BRANCH="$(git branch --show-current)"

if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "❌ Nenhuma branch local está ativa."
    echo "O repositório pode estar em detached HEAD."
    exit 1
fi

if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
    echo "❌ A branch $BASE_BRANCH não pode ser finalizada."
    echo ""
    usage
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ Existem alterações locais pendentes."
    echo "Faça commit, stash ou descarte as alterações antes de continuar."
    echo ""
    git status --short
    exit 1
fi

if ! git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
    echo "❌ Remote não encontrado: $REMOTE_NAME"
    exit 1
fi

LOCAL_BASE_REF="refs/heads/${BASE_BRANCH}"

if ! git show-ref --verify --quiet "$LOCAL_BASE_REF"; then
    echo "❌ Branch base local não encontrada: $BASE_BRANCH"
    exit 1
fi

if ! gh auth status \
    --active \
    --hostname "$GITHUB_HOST" \
    >/dev/null 2>&1
then
    echo "❌ GitHub CLI não está autenticado em $GITHUB_HOST."
    echo ""
    echo "Execute:"
    echo "gh auth login --hostname $GITHUB_HOST --git-protocol https --web"
    exit 1
fi

ACTIVE_GITHUB_LOGIN="$(gh api user --jq ".login")"

if [[ "$ACTIVE_GITHUB_LOGIN" != "$EXPECTED_GITHUB_LOGIN" ]]; then
    echo "❌ Conta GitHub ativa incorreta."
    echo "Esperada: $EXPECTED_GITHUB_LOGIN"
    echo "Atual: $ACTIVE_GITHUB_LOGIN"
    exit 1
fi

CURRENT_HEAD="$(git rev-parse HEAD)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏁 Finalizando branch de trabalho"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Branch: $CURRENT_BRANCH"
echo "🎯 Base: $BASE_BRANCH"
echo "🌐 Remote: $REMOTE_NAME"
echo "👤 GitHub: $ACTIVE_GITHUB_LOGIN"
echo "🔎 HEAD: $CURRENT_HEAD"

echo ""
echo "🔄 Atualizando referências remotas..."

git fetch --prune "$REMOTE_NAME"

REMOTE_BASE_REF="refs/remotes/${REMOTE_NAME}/${BASE_BRANCH}"

if ! git show-ref --verify --quiet "$REMOTE_BASE_REF"; then
    echo "❌ Branch base remota não encontrada:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

REMOTE_BASE_OID="$(git rev-parse "$REMOTE_BASE_REF")"

echo ""
echo "🔍 Localizando o Pull Request mesclado..."

PR_RESULT="$(
    gh pr list \
        --state merged \
        --base "$BASE_BRANCH" \
        --head "$CURRENT_BRANCH" \
        --limit 100 \
        --json \
            number,url,state,mergedAt,baseRefName,headRefName,headRefOid,mergeCommit,isCrossRepository \
        --jq "
            map(
                select(
                    .state == \"MERGED\"
                    and .isCrossRepository == false
                    and .baseRefName == \"$BASE_BRANCH\"
                    and .headRefName == \"$CURRENT_BRANCH\"
                    and .headRefOid == \"$CURRENT_HEAD\"
                )
            ) |
            if length == 0 then
                \"NOT_FOUND\"
            elif length > 1 then
                \"AMBIGUOUS\"
            else
                .[0] |
                [
                    (.number | tostring),
                    .url,
                    .state,
                    .mergedAt,
                    .baseRefName,
                    .headRefName,
                    .headRefOid,
                    (.mergeCommit.oid // \"\")
                ] |
                @tsv
            end
        "
)"

if [[ "$PR_RESULT" == "NOT_FOUND" ]]; then
    echo "❌ Nenhum Pull Request mesclado corresponde ao HEAD atual."
    echo ""
    echo "A branch pode ainda não ter sido mesclada ou pode possuir"
    echo "commits criados depois do merge."
    exit 1
fi

if [[ "$PR_RESULT" == "AMBIGUOUS" ]]; then
    echo "❌ Mais de um Pull Request mesclado corresponde ao HEAD atual."
    echo "A finalização foi interrompida por segurança."
    exit 1
fi

PR_NUMBER=""
PR_URL=""
PR_STATE=""
PR_MERGED_AT=""
PR_BASE_BRANCH=""
PR_HEAD_BRANCH=""
PR_HEAD_OID=""
PR_MERGE_OID=""

IFS=$'\t' read -r \
    PR_NUMBER \
    PR_URL \
    PR_STATE \
    PR_MERGED_AT \
    PR_BASE_BRANCH \
    PR_HEAD_BRANCH \
    PR_HEAD_OID \
    PR_MERGE_OID \
    <<< "$PR_RESULT"

if [[ -z "$PR_NUMBER" \
    || -z "$PR_URL" \
    || -z "$PR_STATE" \
    || -z "$PR_MERGED_AT" \
    || -z "$PR_BASE_BRANCH" \
    || -z "$PR_HEAD_BRANCH" \
    || -z "$PR_HEAD_OID" \
    || -z "$PR_MERGE_OID" ]]
then
    echo "❌ Os dados do Pull Request estão incompletos."
    exit 1
fi

if [[ "$PR_STATE" != "MERGED" ]]; then
    echo "❌ O Pull Request ainda não foi mesclado."
    exit 1
fi

if [[ "$PR_BASE_BRANCH" != "$BASE_BRANCH" ]]; then
    echo "❌ O Pull Request foi mesclado em uma base inesperada."
    echo "Esperada: $BASE_BRANCH"
    echo "Atual: $PR_BASE_BRANCH"
    exit 1
fi

if [[ "$PR_HEAD_BRANCH" != "$CURRENT_BRANCH" ]]; then
    echo "❌ O Pull Request não pertence à branch atual."
    exit 1
fi

if [[ "$PR_HEAD_OID" != "$CURRENT_HEAD" ]]; then
    echo "❌ O HEAD do Pull Request não corresponde à branch local."
    echo "Pull Request: $PR_HEAD_OID"
    echo "Local: $CURRENT_HEAD"
    exit 1
fi

if ! git cat-file \
    -e \
    "${PR_MERGE_OID}^{commit}" \
    2>/dev/null
then
    echo "❌ O commit criado pelo merge não está disponível localmente."
    echo "Commit: $PR_MERGE_OID"
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "$PR_MERGE_OID" \
    "$REMOTE_BASE_OID"
then
    echo "❌ O commit criado pelo Pull Request não pertence a:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    echo ""
    echo "Pull Request: $PR_URL"
    echo "Commit: $PR_MERGE_OID"
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "$BASE_BRANCH" \
    "$REMOTE_BASE_OID"
then
    echo "❌ A branch local $BASE_BRANCH possui commits exclusivos"
    echo "ou divergiu de ${REMOTE_NAME}/${BASE_BRANCH}."
    echo "Resolva a divergência antes de continuar."
    exit 1
fi

if [[ "$(git branch --show-current)" != "$CURRENT_BRANCH" ]]; then
    echo "❌ A branch ativa mudou durante a validação."
    exit 1
fi

if [[ "$(git rev-parse HEAD)" != "$CURRENT_HEAD" ]]; then
    echo "❌ O HEAD local mudou durante a validação."
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ O worktree mudou durante a validação."
    exit 1
fi

REMOTE_WORK_REF="refs/remotes/${REMOTE_NAME}/${CURRENT_BRANCH}"
REMOTE_BRANCH_EXISTS="false"

if git show-ref --verify --quiet "$REMOTE_WORK_REF"; then
    REMOTE_BRANCH_EXISTS="true"
fi

echo ""
echo "✅ Pull Request mesclado validado."
echo "🔗 Pull Request: #${PR_NUMBER}"
echo "🕒 Merge: $PR_MERGED_AT"
echo "🧾 Commit na main: $PR_MERGE_OID"

echo ""
echo "🔀 Atualizando $BASE_BRANCH..."

git switch "$BASE_BRANCH"
git merge --ff-only "${REMOTE_NAME}/${BASE_BRANCH}"

UPDATED_BASE_OID="$(git rev-parse HEAD)"

if [[ "$UPDATED_BASE_OID" != "$REMOTE_BASE_OID" ]]; then
    echo "❌ A branch local não alcançou o estado remoto validado."
    echo "Esperado: $REMOTE_BASE_OID"
    echo "Atual: $UPDATED_BASE_OID"
    echo ""
    echo "A branch $CURRENT_BRANCH não foi removida."
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "$PR_MERGE_OID" \
    "$UPDATED_BASE_OID"
then
    echo "❌ A main atualizada não contém o commit do Pull Request."
    echo "A branch $CURRENT_BRANCH não foi removida."
    exit 1
fi

echo ""
echo "🧹 Removendo branch local concluída..."

git branch -D "$CURRENT_BRANCH"

echo ""
echo "✅ Branch finalizada com sucesso."
echo "📍 Branch atual: $BASE_BRANCH"
echo "🧾 HEAD concluído: $CURRENT_HEAD"
echo "🔗 Pull Request: $PR_URL"

if [[ "$REMOTE_BRANCH_EXISTS" == "true" ]]; then
    echo ""
    echo "⚠️ A branch remota ainda existe:"
    echo "${REMOTE_NAME}/${CURRENT_BRANCH}"
    echo "Ela não foi removida por este script."
fi
