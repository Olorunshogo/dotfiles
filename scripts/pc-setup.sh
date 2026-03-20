#!/usr/bin/env bash
set -e  # Stop on any error

clear
echo "🚀 Starting Full PC Development Setup"
echo "   Node.js (via nvm) → Corepack (pnpm + yarn) → Git + SSH + Global Tools"
echo ""

# ========================
# 1. NODE.JS via NVM
# ========================
echo "📦 Step 1: Installing nvm (Node Version Manager)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# Load nvm into current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

echo "✅ nvm installed and loaded successfully."
echo ""

echo "📥 Step 2: Installing Node.js 24 (Active LTS)..."
nvm install 24
nvm use 24
nvm alias default 24

echo ""
echo "🔍 Verifying Node.js installation:"
node -v
npm -v

echo ""
read -p "✅ Node.js is installed. Press Enter to continue with Corepack setup..."

# ========================
# 2. COREPACK + PNPM + YARN
# ========================
echo ""
echo "⚡ Step 3: Enabling Corepack and activating pnpm & yarn..."

corepack enable
corepack prepare pnpm@latest --activate
corepack prepare yarn@stable --activate

echo ""
echo "🔍 Verifying package managers:"
echo "   npm  → $(npm -v)"
echo "   yarn → $(yarn -v)"
echo "   pnpm → $(pnpm -v)"

echo ""
echo "✅ Corepack enabled! You can now use npm, yarn, and pnpm globally."
read -p "Press Enter to continue with Git + SSH setup..."

# ========================
# 3. GIT + SSH SETUP
# ========================
echo ""
echo "🔧 Step 4: Starting Git Full Setup..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
  OS="windows"
else
  OS="unknown"
fi
echo "Detected OS: $OS"

# Prompt for Git identity
read -p "Enter your full name for Git commits: " USERNAME
read -p "Enter your email for Git (and SSH key comment): " EMAIL

if [ -z "$USERNAME" ] || [ -z "$EMAIL" ]; then
  echo "❌ Name and email are required. Exiting."
  exit 1
fi

git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
echo "✅ Git user name & email configured."

# SSH Key Setup
echo ""
echo "=== SSH Key Setup for GitHub ==="
KEY_FILE="$HOME/.ssh/id_ed25519"
PUB_FILE="$KEY_FILE.pub"

if [ -f "$PUB_FILE" ]; then
  echo "✅ Existing ed25519 SSH key found."
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "⚠️  RSA key found. Using it (consider switching to ed25519 later)."
  KEY_FILE="$HOME/.ssh/id_rsa"
  PUB_FILE="$KEY_FILE.pub"
else
  echo "🔑 Generating new ed25519 SSH key..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
fi

echo ""
echo "📋 Your public key (copy this):"
cat "$PUB_FILE"
echo ""
echo "✅ Go to https://github.com/settings/keys"
echo "   → Click 'New SSH key'"
echo "   → Title: e.g. $(hostname) - $(date +%Y-%m-%d)"
echo "   → Paste the key above"
echo ""
read -p "Press Enter AFTER you have added the SSH key to GitHub..."

# Add key to ssh-agent
echo "🔑 Starting SSH agent and adding key..."
eval "$(ssh-agent -s)"
ssh-add "$KEY_FILE"

echo "🧪 Testing SSH connection to GitHub..."
ssh -T git@github.com || echo "⚠️  Test showed warning (this is normal on first connection)."

# Enable SSH commit signing
echo "🔏 Configuring SSH commit signing..."
git config --global gpg.format ssh
git config --global user.signingkey "$PUB_FILE"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
echo "✅ SSH commit signing enabled."

read -p "Press Enter to create global configuration files..."

# ========================
# 4. GLOBAL CONFIG FILES
# ========================
echo ""
echo "📁 Step 5: Creating global configuration files..."

mkdir -p ~/.vscode

# Global VS Code settings
cat << 'EOF' > ~/.vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "editor.rulers": [100],
  "editor.detectIndentation": false,

  "[javascript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[json]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[solidity]": { "editor.defaultFormatter": "NomicFoundation.hardhat-solidity" },
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.formatOnSave": true
  },

  "prettier.requireConfig": true,
  "prettier.useEditorConfig": false,

  "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
  "editor.codeActionsOnSave": { "source.fixAll.eslint": "explicit" },

  "solidity.compileUsingRemoteVersion": "v0.8.24",
  "solidity.formatter": "prettier",
  "solidity.linter": "solhint",

  "rust-analyzer.check.command": "clippy",
  "rust-analyzer.checkOnSave": true,
  "rust-analyzer.procMacro.enable": true,
  "rust-analyzer.cargo.buildScripts.enable": true,
  "rust-analyzer.inlayHints.enable": true,

  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,

  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/cache": true,
    "**/artifacts": true,
    "**/out": true,
    "**/target": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/cache": true,
    "**/artifacts": true,
    "**/out": true,
    "**/target": true
  }
}
EOF
echo "✅ ~/.vscode/settings.json created"

# Prettier config
cat << 'EOF' > ~/.prettierrc
{
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "semi": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "plugins": ["prettier-plugin-solidity"]
}
EOF
echo "✅ ~/.prettierrc created"

# Solhint config
cat << 'EOF' > ~/.solhint.json
{
  "extends": "solhint:recommended",
  "rules": {
    "compiler-version": ["warn", ">=0.8.0"],
    "func-visibility": ["error", { "ignoreConstructors": true }],
    "max-line-length": ["warn", 120],
    "reason-string": ["warn", { "maxLength": 64 }],
    "no-console": "off",
    "no-empty-blocks": "off",
    "not-rely-on-time": "off"
  }
}
EOF
echo "✅ ~/.solhint.json created"

# Lint-staged config
cat << 'EOF' > ~/.lintstagedrc.json
{
  "*.{js,jsx,ts,tsx,json,css,scss,md}": ["prettier --write"],
  "*.sol": ["prettier --write", "solhint --fix"]
}
EOF
echo "✅ ~/.lintstagedrc.json created"

# Global .gitignore
cat << 'EOF' > ~/.gitignore_global
# OS & Editors
.DS_Store
Thumbs.db
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
.idea/
.history

# Dependencies
node_modules/
target/
out/
dist/
build/
coverage/
.next/
.nuxt/
.vercel/

# Environment
.env
.env.local
.env.*.local
*.pem
*.key
keystore/
wallets/

# Package managers
package-lock.json
.yarn/
.pnp.*
bun.lockb

# Solidity / Blockchain
artifacts/
cache/
broadcast/
forge-cache/
typechain/

# Rust
Cargo.lock   # Remove this line if you want to commit it
*.rs.bk

# Misc
*.log
*.tmp
*.cache
EOF
echo "✅ ~/.gitignore_global created"

git config --global core.excludesfile ~/.gitignore_global

# ========================
# 5. FINAL GIT CONFIGURATIONS
# ========================
echo ""
echo "⚙️  Step 6: Applying Git global configurations..."

git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
git config --global push.default simple
git config --global help.autocorrect 1
git config --global color.ui auto
git config --global rerere.enabled true

# OS specific
if [ "$OS" = "windows" ]; then
  git config --global core.autocrlf true
elif [ "$OS" = "mac" ]; then
  git config --global core.autocrlf input
else
  git config --global core.autocrlf input
fi

echo "✅ Git configurations applied."

echo ""
echo "🎉 FULL SETUP COMPLETED SUCCESSFULLY!"
echo ""
echo "   • Node.js 24 + npm + pnpm + yarn ready"
echo "   • Global Prettier, Solhint, lint-staged, VS Code & Rust settings"
echo "   • Git + SSH + commit signing configured"
echo ""
echo "💡 Recommended next steps:"
echo "   1. Restart your terminal (or run: source ~/.bashrc or ~/.zshrc)"
echo "   2. Restart VS Code"
echo "   3. Install recommended extensions:"
echo "      code --install-extension esbenp.prettier-vscode"
echo "      code --install-extension dbaeumer.vscode-eslint"
echo "      code --install-extension NomicFoundation.hardhat-solidity"
echo "      code --install-extension rust-lang.rust-analyzer"
echo ""
echo "Happy coding! 🚀 You can now use pnpm, yarn, or npm anywhere."