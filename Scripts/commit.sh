#!/bin/bash

set -euo pipefail

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "❌ Dependência não encontrada: $command_name"
        exit 1
    fi
}

usage() {
    echo "Uso:"
    echo './Scripts/commit.sh "<mensagem Conventional Commit>"'
    echo ""
    echo "Exemplo:"
    echo './Scripts/commit.sh "feat(cart): add item quantity control"'
}

require_command git

if [[ "$#" -ne 1 ]]; then
    usage
    exit 1
fi

COMMIT_MESSAGE="$1"
BASE_BRANCH="${BASE_BRANCH:-main}"

COMMIT_MESSAGE_PATTERN='^(feat|fix|refactor|test|chore|docs|ci)(\([a-z0-9-]+\))?: .+'

if [[ ! "$COMMIT_MESSAGE" =~ $COMMIT_MESSAGE_PATTERN ]]; then
    echo "❌ Mensagem de commit inválida:"
    echo "$COMMIT_MESSAGE"
    echo ""
    echo "Use o padrão Conventional Commits."
    echo 'Exemplo: feat(cart): add item quantity control'
    exit 1
fi

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
    echo "❌ Não é permitido criar commits diretamente em $BASE_BRANCH."
    exit 1
fi

HOOKS_PATH="$(git config --get core.hooksPath || true)"

if [[ "$HOOKS_PATH" != ".git-hooks" ]]; then
    echo "❌ Os hooks versionados não estão habilitados."
    echo ""
    echo "Execute:"
    echo "git config core.hooksPath .git-hooks"
    exit 1
fi

if [[ ! -x ".git-hooks/pre-commit" ]]; then
    echo "❌ O hook pre-commit não está executável."
    echo ""
    echo "Execute:"
    echo "chmod +x .git-hooks/pre-commit"
    exit 1
fi

if git diff --cached --quiet; then
    echo "❌ Não há arquivos em stage."
    echo ""
    echo "Adicione explicitamente os arquivos desejados:"
    echo "git add <arquivo>"
    exit 1
fi

if ! git diff --cached --check; then
    echo "❌ O stage contém problemas de whitespace."
    echo "Corrija-os antes de criar o commit."
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Criando commit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Branch: $CURRENT_BRANCH"
echo "💬 Mensagem: $COMMIT_MESSAGE"
echo ""
echo "📄 Arquivos em stage:"

git diff --cached --name-only

echo ""
echo "🪝 Executando pre-commit..."

git commit -m "$COMMIT_MESSAGE"

echo ""
echo "✅ Commit criado com sucesso."
echo "🔎 HEAD: $(git rev-parse --short HEAD)"
