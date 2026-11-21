#!/usr/bin/env bash
set -euo pipefail

TARGET_AGENTS_DIR="${HOME}/.gemini/config/agents"
TARGET_SKILLS_DIR="${HOME}/.gemini/config/skills"
REPO_URL="https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main"

CLEAN_FILES=(
    "agent.md"
    "worker.md"
    "skills/run-workflow/SKILL.md"
    "skills/agy-subagents/SKILL.md"
)

LOCAL_MODE=false
for arg in "$@"; do
    if [ "$arg" == "--local" ]; then
        LOCAL_MODE=true
    fi
done

echo "==> Setting up Antigravity Agents (clean & bare)..."
mkdir -p "${TARGET_AGENTS_DIR}/clean/skills/run-workflow"
mkdir -p "${TARGET_AGENTS_DIR}/clean/skills/agy-subagents"

# Clean up legacy v0.1/v0.2 global installations to avoid duplicate agents or global skill bleed
for legacy_file in "${TARGET_AGENTS_DIR}/better-agy.md" "${TARGET_AGENTS_DIR}/lean-agy.md"; do
    if [ -f "$legacy_file" ]; then
        rm -f "$legacy_file"
        echo "  [~] Removed legacy agent: $(basename "$legacy_file")"
    fi
done
if [ -d "${TARGET_SKILLS_DIR}/agy-subagents" ]; then
    rm -rf "${TARGET_SKILLS_DIR}/agy-subagents"
    echo "  [~] Removed legacy global skill: agy-subagents (now scoped privately to clean)"
fi

if [ "$LOCAL_MODE" = true ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    echo "==> Local mode: copying from ${REPO_ROOT}..."

    for rel in "${CLEAN_FILES[@]}"; do
        src="${REPO_ROOT}/agents/clean/${rel}"
        dst="${TARGET_AGENTS_DIR}/clean/${rel}"
        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            echo "  [✓] Installed clean/${rel} (local)"
        else
            echo "  [!] Warning: ${src} not found"
        fi
    done

    if [ -f "${REPO_ROOT}/agents/bare.md" ]; then
        cp "${REPO_ROOT}/agents/bare.md" "${TARGET_AGENTS_DIR}/bare.md"
        echo "  [✓] Installed bare.md (local)"
    else
        echo "  [!] Warning: ${REPO_ROOT}/agents/bare.md not found"
    fi
else
    echo "==> Remote mode: fetching latest from GitHub..."

    for rel in "${CLEAN_FILES[@]}"; do
        dst="${TARGET_AGENTS_DIR}/clean/${rel}"
        mkdir -p "$(dirname "$dst")"
        echo "  --> Fetching clean/${rel}..."
        curl -fsSL "${REPO_URL}/agents/clean/${rel}" -o "$dst"
        echo "  [✓] Installed clean/${rel}"
    done

    echo "  --> Fetching bare.md..."
    curl -fsSL "${REPO_URL}/agents/bare.md" -o "${TARGET_AGENTS_DIR}/bare.md"
    echo "  [✓] Installed bare.md"
fi

echo "==> Installation complete!"
echo "    Verify agents: agy agents"
echo "    Run Clean:     agy --agent clean"
echo "    Run Bare:      agy --agent bare"
