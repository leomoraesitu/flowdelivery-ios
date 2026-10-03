#!/bin/bash

set -euo pipefail

# Gera o prompt de abertura da próxima aula a partir de docs/ROTEIRO.md
# e o copia para a área de transferência (pbcopy).
#
# Uso:
#   ./Scripts/lesson-prompt.sh            # copia e mostra o prompt
#   ./Scripts/lesson-prompt.sh --print    # só mostra, sem copiar

PRINT_ONLY=false
if [[ "${1:-}" == "--print" ]]; then
    PRINT_ONLY=true
elif [[ $# -gt 0 ]]; then
    echo "❌ Argumento inválido: $1"
    echo "Uso: ./Scripts/lesson-prompt.sh [--print]"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROADMAP="$REPO_ROOT/docs/ROTEIRO.md"

if [[ ! -f "$ROADMAP" ]]; then
    echo "❌ Roteiro não encontrado: docs/ROTEIRO.md"
    exit 1
fi

LAST_LESSON="$(sed -n 's/^- Última aula concluída: \([0-9][0-9]*\).*/\1/p' "$ROADMAP" | head -n 1)"

if [[ -z "$LAST_LESSON" ]]; then
    echo "❌ Não encontrei 'Última aula concluída: N' em docs/ROTEIRO.md"
    exit 1
fi

NEXT_LESSON=$((LAST_LESSON + 1))

# Bloco "Próxima:" (linha inicial + continuações indentadas) e "Pendente:".
extract_item() {
    awk -v key="$1" '
        index($0, "- " key ":") == 1 { printing = 1; print; next }
        printing && /^  / { print; next }
        printing { exit }
    ' "$ROADMAP"
}

NEXT_BLOCK="$(extract_item "Próxima")"
PENDING_BLOCK="$(extract_item "Pendente")"

PROMPT="$(cat <<PROMPT_END
Vamos para a aula ${NEXT_LESSON} do FlowDelivery iOS.

Antes de qualquer coisa:
1. Leia CLAUDE.md e docs/ROTEIRO.md (estado, decisões que não devem ser revertidas, dívidas).
2. Confirme em quais arquivos vamos mexer e peça os que faltarem.

Contexto atual (de docs/ROTEIRO.md):
${NEXT_BLOCK:-- Próxima: (não informada no roteiro)}
${PENDING_BLOCK:-- Pendente: nenhuma}

Regras desta sessão:
- Haja como professor de Desenvolvimento de Software e Segurança da Informação, especialista em iOS, guiando-me passo a passo.
- Use a documentação oficial da Apple como fonte e cite os links.
- Não execute nada diretamente a não ser que eu peça; entregue os comandos e explique.
- Responda em português; commits, PR e Review em inglês.
- Meça antes de afirmar a causa de uma falha.
- Formato da aula: pré-voo (git) → conceito e decisões de design → passo a passo com TDD → commits → Definition of Done → o que NÃO fazer → pergunta de fixação.

Se houver mais de uma opção para a aula, recomende uma e justifique antes de começar.
PROMPT_END
)"

printf '%s\n' "$PROMPT"

if [[ "$PRINT_ONLY" == "true" ]]; then
    exit 0
fi

if ! command -v pbcopy >/dev/null 2>&1; then
    echo "❌ pbcopy não encontrado (disponível apenas no macOS). Use --print."
    exit 1
fi

printf '%s' "$PROMPT" | pbcopy
echo
echo "✅ Prompt da aula ${NEXT_LESSON} copiado para a área de transferência."
