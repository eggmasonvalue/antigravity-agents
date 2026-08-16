#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${HOME}/.gemini/config/agents"
REPO_URL="https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main"
AGENTS=("better-agy.md")

LOCAL_MODE=false
for arg in "$@"; do
    if [ "$arg" == "--local" ]; then
        LOCAL_MODE=true
    fi
done

echo "==> Setting up Antigravity Agents (${TARGET_DIR})..."
mkdir -p "${TARGET_DIR}"

if [ "$LOCAL_MODE" = true ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    echo "==> Local mode: copying agents from ${REPO_ROOT}/agents/..."
    for agent in "${AGENTS[@]}"; do
        if [ -f "${REPO_ROOT}/agents/${agent}" ]; then
            cp "${REPO_ROOT}/agents/${agent}" "${TARGET_DIR}/${agent}"
            echo "  [✓] Installed ${agent} (local)"
        else
            echo "  [!] Warning: ${REPO_ROOT}/agents/${agent} not found"
        fi
    done
else
    echo "==> Remote mode: fetching latest agents from GitHub..."
    for agent in "${AGENTS[@]}"; do
        DOWNLOAD_URL="${REPO_URL}/agents/${agent}"
        echo "  --> Fetching ${agent}..."
        curl -fsSL "${DOWNLOAD_URL}" -o "${TARGET_DIR}/${agent}"
        echo "  [✓] Installed ${agent}"
    done
fi

echo "==> Installation complete!"
echo "    Verify with: agy agents"
echo "    Run with:    agy --agent better-agy"
