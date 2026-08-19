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
    echo "./Scripts/ready-pr.sh"
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
    echo "❌ A branch $BASE_BRANCH não possui um Pull Request de trabalho."
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ Existem alterações locais sem commit."
    echo "Faça commit antes de preparar o Pull Request."
    echo ""
    git status --short
    exit 1
fi

if ! git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
    echo "❌ Remote não encontrado: $REMOTE_NAME"
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

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔎 Preparando Pull Request"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Branch: $CURRENT_BRANCH"
echo "🎯 Base: $BASE_BRANCH"
echo "🌐 Remote: $REMOTE_NAME"
echo "👤 GitHub: $ACTIVE_GITHUB_LOGIN"

echo ""
echo "🔄 Atualizando referências remotas..."

git fetch --prune "$REMOTE_NAME"

REMOTE_BASE_REF="refs/remotes/${REMOTE_NAME}/${BASE_BRANCH}"
REMOTE_BRANCH_REF="refs/remotes/${REMOTE_NAME}/${CURRENT_BRANCH}"

if ! git show-ref --verify --quiet "$REMOTE_BASE_REF"; then
    echo "❌ Branch base remota não encontrada:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

if ! git show-ref --verify --quiet "$REMOTE_BRANCH_REF"; then
    echo "❌ A branch atual ainda não foi publicada:"
    echo "${REMOTE_NAME}/${CURRENT_BRANCH}"
    exit 1
fi

EXPECTED_UPSTREAM="${REMOTE_NAME}/${CURRENT_BRANCH}"

UPSTREAM="$(
    git rev-parse \
        --abbrev-ref \
        --symbolic-full-name \
        "@{upstream}" \
        2>/dev/null || true
)"

if [[ "$UPSTREAM" != "$EXPECTED_UPSTREAM" ]]; then
    echo "❌ Upstream inesperado para a branch atual."
    echo "Esperado: $EXPECTED_UPSTREAM"
    echo "Atual: ${UPSTREAM:-não configurado}"
    exit 1
fi

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "$REMOTE_BRANCH_REF")"

if [[ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]]; then
    echo "❌ A branch local e a branch remota não estão alinhadas."
    echo "Local: $LOCAL_HEAD"
    echo "Remota: $REMOTE_HEAD"
    echo ""
    echo "Publique ou reconcilie as alterações antes de continuar."
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "${REMOTE_NAME}/${BASE_BRANCH}" \
    HEAD
then
    echo "❌ A branch não contém a versão mais recente de:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    echo ""
    echo "Atualize a branch:"
    echo "git rebase ${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

PR_COUNT="$(
    gh pr list \
        --state open \
        --base "$BASE_BRANCH" \
        --head "$CURRENT_BRANCH" \
        --limit 2 \
        --json number \
        --jq "length"
)"

if [[ "$PR_COUNT" -eq 0 ]]; then
    echo "❌ Nenhum Pull Request aberto foi encontrado para:"
    echo "$CURRENT_BRANCH → $BASE_BRANCH"
    exit 1
fi

if [[ "$PR_COUNT" -ne 1 ]]; then
    echo "❌ Mais de um Pull Request aberto foi encontrado."
    echo "Revise os Pull Requests antes de continuar."
    exit 1
fi

PR_NUMBER="$(
    gh pr list \
        --state open \
        --base "$BASE_BRANCH" \
        --head "$CURRENT_BRANCH" \
        --limit 1 \
        --json number \
        --jq ".[0].number"
)"

PR_DETAILS="$(
    gh pr view "$PR_NUMBER" \
        --json url,state,isDraft,baseRefName,headRefName,headRefOid,title \
        --jq '[
            .url,
            .state,
            (.isDraft | tostring),
            .baseRefName,
            .headRefName,
            .headRefOid,
            .title
        ] | @tsv'
)"

IFS=$'\t' read -r \
    PR_URL \
    PR_STATE \
    PR_IS_DRAFT \
    PR_BASE_BRANCH \
    PR_HEAD_BRANCH \
    PR_HEAD_OID \
    PR_TITLE \
    <<< "$PR_DETAILS"

if [[ "$PR_STATE" != "OPEN" ]]; then
    echo "❌ O Pull Request não está aberto."
    exit 1
fi

if [[ "$PR_BASE_BRANCH" != "$BASE_BRANCH" ]]; then
    echo "❌ Base inesperada no Pull Request."
    echo "Esperada: $BASE_BRANCH"
    echo "Atual: $PR_BASE_BRANCH"
    exit 1
fi

if [[ "$PR_HEAD_BRANCH" != "$CURRENT_BRANCH" ]]; then
    echo "❌ O Pull Request não pertence à branch atual."
    exit 1
fi

if [[ "$PR_HEAD_OID" != "$LOCAL_HEAD" ]]; then
    echo "❌ O HEAD do Pull Request não corresponde ao HEAD local."
    echo "Pull Request: $PR_HEAD_OID"
    echo "Local: $LOCAL_HEAD"
    exit 1
fi

echo ""
echo "📋 Pull Request encontrado:"
echo "$PR_TITLE"
echo "$PR_URL"

if [[ "$PR_IS_DRAFT" != "true" ]]; then
    echo ""
    echo "✅ O Pull Request já está Ready for review."
    exit 0
fi

echo ""
echo "⏳ Aguardando checks obrigatórios..."

if ! gh pr checks "$PR_NUMBER" \
    --required \
    --watch \
    --fail-fast \
    --interval 10
then
    echo ""
    echo "❌ Um check obrigatório falhou ou foi interrompido."
    echo "O Pull Request continuará como draft."
    exit 1
fi

if [[ "$(git branch --show-current)" != "$CURRENT_BRANCH" ]]; then
    echo "❌ A branch ativa mudou durante a validação."
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ O worktree mudou durante a validação."
    exit 1
fi

if [[ "$(git rev-parse HEAD)" != "$LOCAL_HEAD" ]]; then
    echo "❌ O HEAD local mudou durante a validação."
    exit 1
fi

echo ""
echo "🔄 Confirmando o estado final..."

git fetch --prune "$REMOTE_NAME"

if ! git show-ref --verify --quiet "$REMOTE_BRANCH_REF"; then
    echo "❌ A branch remota deixou de existir durante a validação."
    exit 1
fi

if [[ "$(git rev-parse "$REMOTE_BRANCH_REF")" != "$LOCAL_HEAD" ]]; then
    echo "❌ A branch remota mudou durante a validação."
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "${REMOTE_NAME}/${BASE_BRANCH}" \
    "$LOCAL_HEAD"
then
    echo "❌ A branch base avançou durante a validação."
    echo ""
    echo "Atualize a branch e execute novamente:"
    echo "git rebase ${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

FINAL_PR_DETAILS="$(
    gh pr view "$PR_NUMBER" \
        --json state,isDraft,headRefOid \
        --jq '[
            .state,
            (.isDraft | tostring),
            .headRefOid
        ] | @tsv'
)"

IFS=$'\t' read -r \
    FINAL_PR_STATE \
    FINAL_PR_IS_DRAFT \
    FINAL_PR_HEAD_OID \
    <<< "$FINAL_PR_DETAILS"

if [[ "$FINAL_PR_STATE" != "OPEN" ]]; then
    echo "❌ O estado do Pull Request mudou durante a validação."
    exit 1
fi

if [[ "$FINAL_PR_HEAD_OID" != "$LOCAL_HEAD" ]]; then
    echo "❌ O HEAD do Pull Request mudou durante a validação."
    exit 1
fi

if [[ "$FINAL_PR_IS_DRAFT" != "true" ]]; then
    echo ""
    echo "✅ O Pull Request já foi movido para Ready for review."
    echo "$PR_URL"
    exit 0
fi

echo ""
echo "🟢 Movendo Pull Request para Ready for review..."

gh pr ready "$PR_NUMBER"

echo ""
echo "✅ Pull Request pronto para revisão:"
echo "$PR_URL"
