#!/usr/bin/env bash
set -euo pipefail

# rebuild.sh for devflowinc/trieve
# Runs on existing source tree (no clone).
# Current directory should be the docusaurus root (clients/docusaurus-theme-search/example).
# The example depends on ../dist/index.js from the plugin package.
# We clone the source to /tmp to build the plugin, then copy dist back.

echo "=== rebuild.sh: devflowinc/trieve ==="

# --- Node version: Node 20 ---
export NVM_DIR="${HOME}/.nvm"
if [ -s "${NVM_DIR}/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "${NVM_DIR}/nvm.sh"
    nvm use 20 2>/dev/null || nvm install 20
fi
echo "[INFO] Using Node $(node --version)"
echo "[INFO] npm version: $(npm --version)"

# --- Clone source repo to build the plugin (example uses ../dist/index.js) ---
# The staging repo may not have the plugin source, so we clone it fresh.
PLUGIN_TMP="/tmp/trieve-plugin-build-$$"
git clone --depth 1 https://github.com/devflowinc/trieve "$PLUGIN_TMP"
cd "$PLUGIN_TMP/clients/docusaurus-theme-search"
npm install --legacy-peer-deps
npm run build
cd -

# Copy the built plugin dist back to the expected location (one level up from example)
mkdir -p ../dist
cp -r "$PLUGIN_TMP/clients/docusaurus-theme-search/dist/." ../dist/
rm -rf "$PLUGIN_TMP"
echo "[INFO] Plugin dist copied to ../dist/"

# --- Install example dependencies ---
npm install --legacy-peer-deps

# --- Build ---
echo "[INFO] Building Docusaurus site..."
npm run build

echo "[DONE] Build complete."
