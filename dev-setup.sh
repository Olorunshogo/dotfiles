#!/usr/bin/env bash
set -e  # Stop on any error

clear
echo "🚀 Full Development Machine Setup"
echo "   System Update → Essentials → Rust → Node.js → Git + SSH + Global Configs"
echo ""

# ========================
# 1. SYSTEM UPDATE & ESSENTIAL TOOLS
# ========================
echo "📦 Step 1: Updating system packages and installing essentials..."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt-get update -qq
  sudo apt-get upgrade -y -qq
  sudo apt-get install -y curl wget git build-essential ca-certificates
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew update
  brew upgrade
  brew install curl wget git
  OS="mac"
else
  echo "❌ Unsupported OS: $OSTYPE"
  exit 1
fi

echo "✅ System updated and essentials installed (curl, wget, git, build tools)."
read -p "Press Enter to continue with Rust installation..."

# ========================
# 2. RUST via RUSTUP
# ========================
echo ""
echo "🦀 Step 2: Installing Rust via rustup..."

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Load Rust into current shell
source "$HOME/.cargo/env"

echo ""
echo "🔍 Verifying Rust installation:"
rustc --version
cargo --version
rustup component add rustfmt clippy

echo "✅ Rust installed successfully (with rustfmt & clippy)."
read -p "Press Enter to continue with Node.js installation..."

# ========================
# 3. NODE.JS via NVM
# ========================
echo ""
echo "📦 Step 3: Installing nvm (Node Version Manager)..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# Load nvm into current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

echo "✅ nvm installed and loaded."
echo ""

echo "📥 Installing Node.js 24 (Active LTS)..."
nvm install 24
nvm use 24
nvm alias default 24

echo ""
echo "🔍 Verifying Node.js:"
node -v
npm -v

read -p "✅ Node.js ready. Press Enter to enable Corepack (pnpm + yarn)..."

# ========================
# 4. COREPACK + PNPM + YARN
# ========================
echo ""
echo "⚡ Step 4: Enabling Corepack and activating pnpm & yarn..."

corepack enable
corepack prepare pnpm@latest --activate
corepack prepare yarn@stable --activate

echo ""
echo "🔍 Package managers versions:"
echo "   npm  → $(npm -v)"
echo "   yarn → $(yarn -v)"
echo "   pnpm → $(pnpm -v)"

echo "✅ Corepack enabled. npm, yarn, and pnpm are ready."
read -p "Press Enter to continue with Git + SSH setup..."

# ========================
# 5. GIT + SSH SETUP
# ========================
echo ""
echo "🔧 Step 5: Git + SSH Setup..."

# Git identity
read -p "Enter your full name for Git commits: " USERNAME
read -p "Enter your email for Git (and SSH key comment): " EMAIL

if [ -z "$USERNAME" ] || [ -z "$EMAIL" ]; then
  echo "❌ Name and email are required. Exiting."
  exit 1
fi

git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
echo "✅ Git user configured."

# SSH Key
echo ""
echo "=== SSH Key Setup for GitHub ==="
KEY_FILE="$HOME/.ssh/id_ed25519"
PUB_FILE="$KEY_FILE.pub"

if [ -f "$PUB_FILE" ]; then
  echo "✅ Existing ed25519 key found."
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "⚠️ Using existing RSA key."
  KEY_FILE="$HOME/.ssh/id_rsa"
  PUB_FILE="$KEY_FILE.pub"
else
  echo "🔑 Generating new ed25519 SSH key..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
fi

echo ""
echo "📋 Your public key:"
cat "$PUB_FILE"
echo ""
echo "✅ Go to https://github.com/settings/keys"
echo "   → New SSH key → Paste the key above"
echo ""
read -p "Press Enter AFTER adding the key to GitHub..."

eval "$(ssh-agent -s)"
ssh-add "$KEY_FILE"

echo "🧪 Testing GitHub SSH..."
ssh -T git@github.com || echo "⚠️ Warning is normal on first run."

# SSH Commit Signing
git config --global gpg.format ssh
git config --global user.signingkey "$PUB_FILE"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
echo "✅ SSH commit signing enabled."

read -p "Press Enter to create global config files..."

# ========================
# 6. GLOBAL CONFIG FILES
# ========================
echo ""
echo "📁 Step 6: Creating global configuration files..."

mkdir -p ~/.vscode

# VS Code settings (with Rust + Solidity)
cat << 'EOF' > ~/.vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "editor.rulers": [100],

  "[javascript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[json]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[solidity]": { "editor.defaultFormatter": "NomicFoundation.hardhat-solidity" },
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.formatOnSave": true
  },

  "prettier.requireConfig": true,
  "eslint.validate": ["javascript","javascriptreact","typescript","typescriptreact"],
  "editor.codeActionsOnSave": { "source.fixAll.eslint": "explicit" },

  "solidity.compileUsingRemoteVersion": "v0.8.24",
  "solidity.formatter": "prettier",
  "solidity.linter": "solhint",

  "rust-analyzer.check.command": "clippy",
  "rust-analyzer.checkOnSave": true,
  "rust-analyzer.procMacro.enable": true,

  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,

  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/target": true,
    "**/artifacts": true,
    "**/out": true
  }
}
EOF
echo "✅ ~/.vscode/settings.json created"

# Prettier, Solhint, Lint-staged, .gitignore (same as before)
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

cat << 'EOF' > ~/.lintstagedrc.json
{
  "*.{js,jsx,ts,tsx,json,css,scss,md}": ["prettier --write"],
  "*.sol": ["prettier --write", "solhint --fix"]
}
EOF
echo "✅ ~/.lintstagedrc.json created"

cat << 'EOF' > ~/.gitignore_global
# OS
.DS_Store
Thumbs.db

# Editors
.vscode/*
!.vscode/settings.json
.idea/
.history

# Dependencies
node_modules/
target/
out/
dist/
build/
artifacts/
cache/
.next/
.nuxt/

# Secrets
.env
.env.local
*.pem
*.key
keystore/

# Package
package-lock.json
.yarn/
.pnp.*
bun.lockb

# Misc
*.log
*.tmp
*.cache
EOF
echo "✅ ~/.gitignore_global created"

git config --global core.excludesfile ~/.gitignore_global

# Final Git configs
echo ""
echo "⚙️ Applying final Git configurations..."
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true

echo "✅ All configurations applied."

# ========================
# FINAL MESSAGE
# ========================
echo ""
echo "🎉 FULL MACHINE SETUP COMPLETED!"
echo ""
echo "Installed:"
echo "   • Rust (rustup + cargo + clippy + rustfmt)"
echo "   • Node.js 24 + npm + pnpm + yarn"
echo "   • Git + SSH + commit signing"
echo "   • Global Prettier, Solhint, Rust, Solidity settings"
echo ""
echo "💡 Next steps:"
echo "   1. Restart your terminal"
echo "   2. Restart VS Code (if installed)"
echo "   3. Install VS Code extensions:"
echo "      code --install-extension rust-lang.rust-analyzer"
echo "      code --install-extension esbenp.prettier-vscode"
echo "      code --install-extension dbaeumer.vscode-eslint"
echo "      code --install-extension NomicFoundation.hardhat-solidity"
echo ""
echo "You are now ready to code in Rust, TypeScript, Solidity, and more!"
echo "Happy hacking! 🚀"