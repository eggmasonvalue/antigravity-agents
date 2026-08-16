#!/usr/bin/env bash
set -euo pipefail

TARGET_AGENTS_DIR="${HOME}/.gemini/config/agents"
TARGET_SKILLS_DIR="${HOME}/.gemini/config/skills"
REPO_URL="https://raw.githubusercontent.com/eggmasonvalue/antigravity-agents/main"
AGENTS=("better-agy.md" "lean-agy.md")
SKILLS=("agy-subagents")

LOCAL_MODE=false
for arg in "$@"; do
    if [ "$arg" == "--local" ]; then
        LOCAL_MODE=true
    fi
done

echo "==> Setting up Antigravity Agents and Skills..."
mkdir -p "${TARGET_AGENTS_DIR}"
mkdir -p "${TARGET_SKILLS_DIR}"

if [ "$LOCAL_MODE" = true ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    echo "==> Local mode: copying from ${REPO_ROOT}..."

    # Install Agents
    for agent in "${AGENTS[@]}"; do
        if [ -f "${REPO_ROOT}/agents/${agent}" ]; then
            cp "${REPO_ROOT}/agents/${agent}" "${TARGET_AGENTS_DIR}/${agent}"
            echo "  [✓] Installed agent: ${agent} (local)"
        else
            echo "  [!] Warning: ${REPO_ROOT}/agents/${agent} not found"
        fi
    done

    # Install Skills
    for skill in "${SKILLS[@]}"; do
        if [ -d "${REPO_ROOT}/.agents/skills/${skill}" ]; then
            mkdir -p "${TARGET_SKILLS_DIR}/${skill}"
            cp -r "${REPO_ROOT}/.agents/skills/${skill}/"* "${TARGET_SKILLS_DIR}/${skill}/"
            echo "  [✓] Installed skill: ${skill} (local)"
        else
            echo "  [!] Warning: ${REPO_ROOT}/.agents/skills/${skill} not found"
        fi
    done
else
    echo "==> Remote mode: fetching latest from GitHub..."

    # Install Agents
    for agent in "${AGENTS[@]}"; do
        DOWNLOAD_URL="${REPO_URL}/agents/${agent}"
        echo "  --> Fetching agent ${agent}..."
        curl -fsSL "${DOWNLOAD_URL}" -o "${TARGET_AGENTS_DIR}/${agent}"
        echo "  [✓] Installed agent: ${agent}"
    done

    # Install Skills
    for skill in "${SKILLS[@]}"; do
        mkdir -p "${TARGET_SKILLS_DIR}/${skill}"
        DOWNLOAD_URL="${REPO_URL}/.agents/skills/${skill}/SKILL.md"
        echo "  --> Fetching skill ${skill}..."
        curl -fsSL "${DOWNLOAD_URL}" -o "${TARGET_SKILLS_DIR}/${skill}/SKILL.md"
        echo "  [✓] Installed skill: ${skill}"
    done
fi

echo "==> Installation complete!"
echo "    Verify agents: agy agents"
echo "    Run Better:    agy --agent better-agy"
echo "    Run Lean:      agy --agent lean-agy"
