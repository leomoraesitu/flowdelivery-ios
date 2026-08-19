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
    echo './Scripts/publish-pr.sh "<título convencional do PR>"'
    echo ""
    echo "Exemplo:"
    echo './Scripts/publish-pr.sh "feat(tooling): automate pull request publishing"'
}

require_command git
require_command gh

if [[ "$#" -ne 1 ]]; then
    usage
    exit 1
fi

PR_TITLE="$1"
REMOTE_NAME="${REMOTE_NAME:-origin}"
BASE_BRANCH="${BASE_BRANCH:-main}"
GITHUB_HOST="${GITHUB_HOST:-github.com}"
EXPECTED_GITHUB_LOGIN="${EXPECTED_GITHUB_LOGIN:-leomoraesitu}"
PR_TEMPLATE_PATH=".github/pull_request_template.md"

PR_TITLE_PATTERN='^(feat|fix|refactor|test|chore|docs|ci)(\([a-z0-9-]+\))?: .+'

if [[ ! "$PR_TITLE" =~ $PR_TITLE_PATTERN ]]; then
    echo "❌ Título de Pull Request inválido:"
    echo "$PR_TITLE"
    echo ""
    echo "Use o padrão Conventional Commits."
    echo 'Exemplo: feat(tooling): automate pull request publishing'
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
    echo "❌ A branch $BASE_BRANCH não pode ser publicada como Pull Request."
    exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
    echo "❌ Existem alterações locais sem commit."
    echo "Revise e faça commit antes de publicar."
    echo ""
    git status --short
    exit 1
fi

if ! git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
    echo "❌ Remote não encontrado: $REMOTE_NAME"
    exit 1
fi

if [[ ! -f "$PR_TEMPLATE_PATH" ]]; then
    echo "❌ Template de Pull Request não encontrado:"
    echo "$PR_TEMPLATE_PATH"
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

if [[ ! -x ".git-hooks/pre-push" ]]; then
    echo "❌ O hook pre-push não está executável."
    echo ""
    echo "Execute:"
    echo "chmod +x .git-hooks/pre-push"
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
echo "🚀 Publicando Pull Request"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌿 Branch: $CURRENT_BRANCH"
echo "🎯 Base: $BASE_BRANCH"
echo "🌐 Remote: $REMOTE_NAME"
echo "👤 GitHub: $ACTIVE_GITHUB_LOGIN"

echo ""
echo "🔄 Atualizando referências remotas..."

git fetch --prune "$REMOTE_NAME"

REMOTE_BASE_REF="refs/remotes/${REMOTE_NAME}/${BASE_BRANCH}"

if ! git show-ref --verify --quiet "$REMOTE_BASE_REF"; then
    echo "❌ Branch base remota não encontrada:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
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
    echo "Atualize a branch antes de publicar:"
    echo "git rebase ${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

AHEAD_COUNT="$(
    git rev-list \
        --count \
        "${REMOTE_NAME}/${BASE_BRANCH}..HEAD"
)"

if [[ "$AHEAD_COUNT" -eq 0 ]]; then
    echo "❌ A branch não possui commits novos em relação a:"
    echo "${REMOTE_NAME}/${BASE_BRANCH}"
    exit 1
fi

echo ""
echo "🧪 Publicando branch..."
echo "O hook pre-push executará o Quality Gate."

git push \
    --set-upstream \
    "$REMOTE_NAME" \
    "$CURRENT_BRANCH"

EXISTING_PR_URL="$(
    gh pr list \
        --state open \
        --base "$BASE_BRANCH" \
        --head "$CURRENT_BRANCH" \
        --limit 1 \
        --json url \
        --jq ".[0].url // empty"
)"

if [[ -n "$EXISTING_PR_URL" ]]; then
    echo ""
    echo "✅ Branch publicada."
    echo "ℹ️ Já existe um Pull Request aberto:"
    echo "$EXISTING_PR_URL"
    exit 0
fi

echo ""
echo "📝 Criando Pull Request draft..."

PR_URL="$(
    gh pr create \
        --draft \
        --base "$BASE_BRANCH" \
        --head "$CURRENT_BRANCH" \
        --title "$PR_TITLE" \
        --body-file "$PR_TEMPLATE_PATH"
)"

echo ""
echo "✅ Pull Request draft criado:"
echo "$PR_URL"
echo ""
echo "Complete a descrição e marque somente as validações executadas"
echo "antes de mover o Pull Request para Ready for review."
