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
    echo "./Scripts/start-branch.sh <tipo/nome-em-kebab-case>"
    echo ""
    echo "Exemplo:"
    echo "./Scripts/start-branch.sh feat/display-order-status"
    echo ""
    echo "Tipos permitidos:"
    echo "feat, fix, refactor, test, chore, docs e ci"
}

require_command git

if [[ "$#" -ne 1 ]]; then
    usage
    exit 1
fi

BRANCH_NAME="$1"
REMOTE_NAME="${REMOTE_NAME:-origin}"
BASE_BRANCH="${BASE_BRANCH:-main}"

BRANCH_PATTERN='^(feat|fix|refactor|test|chore|docs|ci)/[a-z0-9]+(-[a-z0-9]+)*$'

if [[ ! "$BRANCH_NAME" =~ $BRANCH_PATTERN ]]; then
    echo "❌ Nome de branch inválido: $BRANCH_NAME"
    echo ""
    usage
    exit 1
fi

if ! ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    echo "❌ Este comando deve ser executado dentro de um repositório Git."
    exit 1
fi

cd "$ROOT_DIR"

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

if ! git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
    echo "❌ Branch base local não encontrada: $BASE_BRANCH"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Iniciando branch de trabalho"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Base: $BASE_BRANCH"
echo "🌐 Remote: $REMOTE_NAME"
echo "🌱 Nova branch: $BRANCH_NAME"

echo ""
echo "🔄 Atualizando referências remotas..."

git fetch --prune "$REMOTE_NAME"

REMOTE_BASE_REF="refs/remotes/${REMOTE_NAME}/${BASE_BRANCH}"

if ! git show-ref --verify --quiet "$REMOTE_BASE_REF"; then
    echo "❌ Branch base remota não encontrada:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "❌ A branch local já existe: $BRANCH_NAME"
    exit 1
fi

REMOTE_BRANCH_REF="refs/remotes/${REMOTE_NAME}/${BRANCH_NAME}"

if git show-ref --verify --quiet "$REMOTE_BRANCH_REF"; then
    echo "❌ A branch remota já existe:"
    echo "${REMOTE_NAME}/${BRANCH_NAME}"
    exit 1
fi

if ! git merge-base \
    --is-ancestor \
    "$BASE_BRANCH" \
    "${REMOTE_NAME}/${BASE_BRANCH}"
then
    echo "❌ A branch local $BASE_BRANCH possui commits exclusivos"
    echo "ou divergiu de ${REMOTE_NAME}/${BASE_BRANCH}."
    echo "Resolva a divergência antes de continuar."
    exit 1
fi

echo ""
echo "🔀 Atualizando $BASE_BRANCH..."

git switch "$BASE_BRANCH"
git merge --ff-only "${REMOTE_NAME}/${BASE_BRANCH}"

echo ""
echo "🌱 Criando $BRANCH_NAME..."

git switch -c "$BRANCH_NAME"

echo ""
echo "✅ Branch criada com sucesso."
echo "📍 Branch atual: $BRANCH_NAME"
