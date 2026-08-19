#!/bin/bash

set -euo pipefail

usage() {
    echo "Uso:"
    echo "./Scripts/dev-flow.sh [--dry-run] <comando> [argumento]"
    echo ""
    echo "Comandos:"
    echo "start <tipo/nome>    Cria uma branch a partir da main"
    echo "sync                 Sincroniza a branch com origin/main"
    echo "check                Executa o Quality Gate"
    echo "commit <mensagem>    Cria um Conventional Commit"
    echo "publish <título>     Publica a branch e cria um PR draft"
    echo "ready                Move o Pull Request para Ready for review"
    echo "finish               Atualiza main e remove a branch concluída"
    echo ""
    echo "Exemplos:"
    echo "./Scripts/dev-flow.sh start feat/display-order-status"
    echo './Scripts/dev-flow.sh commit "feat(order): display status"'
    echo './Scripts/dev-flow.sh --dry-run publish "feat(scope): short description"'
}

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
fi

COMMAND="${1:-help}"

if [[ "$COMMAND" == "help" ]]; then
    usage
    exit 0
fi

shift

case "$COMMAND" in
    start)
        SCRIPT_NAME="start-branch.sh"
        EXPECTED_ARGUMENTS=1
        ;;

    sync)
        SCRIPT_NAME="sync-branch.sh"
        EXPECTED_ARGUMENTS=0
        ;;

    check)
        SCRIPT_NAME="quality.sh"
        EXPECTED_ARGUMENTS=0
        ;;

    commit)
        SCRIPT_NAME="commit.sh"
        EXPECTED_ARGUMENTS=1
        ;;

    publish)
        SCRIPT_NAME="publish-pr.sh"
        EXPECTED_ARGUMENTS=1
        ;;

    ready)
        SCRIPT_NAME="ready-pr.sh"
        EXPECTED_ARGUMENTS=0
        ;;

    finish)
        SCRIPT_NAME="finish-branch.sh"
        EXPECTED_ARGUMENTS=0
        ;;

    *)
        echo "❌ Comando inválido: $COMMAND"
        echo ""
        usage
        exit 1
        ;;
esac

if [[ "$#" -ne "$EXPECTED_ARGUMENTS" ]]; then
    echo "❌ Quantidade de argumentos inválida para: $COMMAND"
    echo ""
    usage
    exit 1
fi

SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

if [[ ! -x "$SCRIPT_PATH" ]]; then
    echo "❌ Script não encontrado ou sem permissão de execução:"
    echo "$SCRIPT_PATH"
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "🔎 Dry-run: nenhum comando será executado."
    echo ""
    printf "Comando planejado:"
    printf " %q" "$SCRIPT_PATH" "$@"
    echo
    exit 0
fi

exec "$SCRIPT_PATH" "$@"
