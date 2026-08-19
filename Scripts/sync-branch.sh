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
    echo "./Scripts/sync-branch.sh"
}

restore_original_state() {
    local operation="$1"

    if [[ "$operation" == "rebase" ]]; then
        git rebase --abort >/dev/null 2>&1 || true
    else
        git merge --abort >/dev/null 2>&1 || true
    fi

    local restored_branch
    local restored_head
    local restored_status

    restored_branch="$(git branch --show-current)"
    restored_head="$(git rev-parse HEAD 2>/dev/null || true)"
    restored_status="$(git status --porcelain=v1 2>/dev/null || true)"

    echo ""

    if [[ "$restored_branch" == "$CURRENT_BRANCH" \
        && "$restored_head" == "$ORIGINAL_HEAD" \
        && -z "$restored_status" ]]
    then
        echo "✅ Estado original restaurado."
        echo "📍 Branch: $CURRENT_BRANCH"
        echo "🔎 HEAD: $ORIGINAL_HEAD"
    else
        echo "❌ O Git não conseguiu restaurar completamente"
        echo "o estado anterior."
        echo ""
        echo "Não execute novos comandos de sincronização."
        echo "Revise o estado atual com:"
        echo "git status"
    fi

    exit 1
}

require_command git

if [[ "$#" -ne 0 ]]; then
    usage
    exit 1
fi

REMOTE_NAME="${REMOTE_NAME:-origin}"
BASE_BRANCH="${BASE_BRANCH:-main}"

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
    echo "❌ A branch $BASE_BRANCH não deve ser sincronizada"
    echo "por este comando."
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ Existem alterações locais pendentes."
    echo "Faça commit, stash ou descarte as alterações antes de continuar."
    echo ""
    git status --short
    exit 1
fi

GIT_DIR="$(git rev-parse --git-dir)"

if [[ -f "$GIT_DIR/MERGE_HEAD" \
    || -d "$GIT_DIR/rebase-merge" \
    || -d "$GIT_DIR/rebase-apply" ]]
then
    echo "❌ Existe uma operação Git em andamento."
    echo "Conclua ou aborte a operação antes de sincronizar."
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

ORIGINAL_HEAD="$(git rev-parse HEAD)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Sincronizando branch de trabalho"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Branch: $CURRENT_BRANCH"
echo "🎯 Base: $BASE_BRANCH"
echo "🌐 Remote: $REMOTE_NAME"
echo "🔎 HEAD inicial: $ORIGINAL_HEAD"

echo ""
echo "📡 Atualizando referências remotas..."

git fetch --prune "$REMOTE_NAME"

REMOTE_BASE_REF="refs/remotes/${REMOTE_NAME}/${BASE_BRANCH}"
REMOTE_BRANCH_REF="refs/remotes/${REMOTE_NAME}/${CURRENT_BRANCH}"
EXPECTED_UPSTREAM="${REMOTE_NAME}/${CURRENT_BRANCH}"

if ! git show-ref --verify --quiet "$REMOTE_BASE_REF"; then
    echo "❌ Branch base remota não encontrada:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

UPSTREAM="$(
    git rev-parse \
        --abbrev-ref \
        --symbolic-full-name \
        "@{upstream}" \
        2>/dev/null || true
)"

REMOTE_BRANCH_EXISTS="false"

if git show-ref --verify --quiet "$REMOTE_BRANCH_REF"; then
    REMOTE_BRANCH_EXISTS="true"
fi

if [[ -n "$UPSTREAM" && "$UPSTREAM" != "$EXPECTED_UPSTREAM" ]]; then
    echo "❌ Upstream inesperado para a branch atual."
    echo "Esperado: $EXPECTED_UPSTREAM"
    echo "Atual: $UPSTREAM"
    exit 1
fi

if [[ "$REMOTE_BRANCH_EXISTS" == "true" && -z "$UPSTREAM" ]]; then
    echo "❌ Existe uma branch remota com o mesmo nome,"
    echo "mas ela não é o upstream da branch local."
    echo ""
    echo "Revise a relação entre as branches antes de continuar."
    exit 1
fi

if [[ "$REMOTE_BRANCH_EXISTS" == "false" \
    && "$UPSTREAM" == "$EXPECTED_UPSTREAM" ]]
then
    echo "❌ O upstream configurado não existe mais no remote."
    echo "Revise a branch antes de continuar."
    exit 1
fi

if [[ "$REMOTE_BRANCH_EXISTS" == "true" ]]; then
    if ! git merge-base \
        --is-ancestor \
        "$REMOTE_BRANCH_REF" \
        "$ORIGINAL_HEAD"
    then
        echo "❌ A branch remota possui commits que não estão"
        echo "presentes na branch local."
        echo ""
        echo "A sincronização foi interrompida para evitar"
        echo "sobrescrever trabalho remoto."
        exit 1
    fi
fi

if git merge-base \
    --is-ancestor \
    "$REMOTE_BASE_REF" \
    "$ORIGINAL_HEAD"
then
    echo ""
    echo "✅ A branch já contém a versão mais recente de:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 0
fi

if [[ "$(git branch --show-current)" != "$CURRENT_BRANCH" \
    || "$(git rev-parse HEAD)" != "$ORIGINAL_HEAD" \
    || -n "$(git status --porcelain=v1)" ]]
then
    echo "❌ O estado local mudou durante a validação."
    exit 1
fi

echo ""

if [[ "$REMOTE_BRANCH_EXISTS" == "true" ]]; then
    echo "🔀 Branch publicada: incorporando a base com merge..."

    if ! git merge \
        --no-edit \
        "$REMOTE_BASE_REF"
    then
        echo ""
        echo "❌ Conflito durante o merge."
        restore_original_state "merge"
    fi
else
    echo "♻️ Branch ainda não publicada: aplicando rebase..."

    if ! git rebase \
        --merge \
        "$REMOTE_BASE_REF"
    then
        echo ""
        echo "❌ Conflito durante o rebase."
        restore_original_state "rebase"
    fi
fi

FINAL_HEAD="$(git rev-parse HEAD)"

if [[ "$(git branch --show-current)" != "$CURRENT_BRANCH" ]]; then
    echo "❌ A branch ativa mudou durante a sincronização."
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ A sincronização terminou com alterações pendentes."
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "$REMOTE_BASE_REF" \
    "$FINAL_HEAD"
then
    echo "❌ A branch final não contém:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

if [[ "$REMOTE_BRANCH_EXISTS" == "true" ]]; then
    if ! git merge-base \
        --is-ancestor \
        "$REMOTE_BRANCH_REF" \
        "$FINAL_HEAD"
    then
        echo "❌ A branch final não preservou o histórico remoto."
        exit 1
    fi
fi

echo ""
echo "✅ Branch sincronizada com sucesso."
echo "📍 Branch: $CURRENT_BRANCH"
echo "🔎 HEAD anterior: $ORIGINAL_HEAD"
echo "🔎 HEAD atual: $FINAL_HEAD"
echo ""
echo "ℹ️ Nenhum push foi executado."
