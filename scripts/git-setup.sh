#!/usr/bin/env bash
set -e  # Stop on any error

echo "🚀 Starting Git Full Setup..."

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

# === Prompt for name and email FIRST ===
read -p "Enter your full name for Git commits: " USERNAME
read -p "Enter your email for Git (and SSH key comment): " EMAIL

if [ -z "$USERNAME" ] || [ -z "$EMAIL" ]; then
  echo "❌ Name and email are required. Try again."
  exit 1
fi

git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
echo "✅ Git user name & email saved."

# === SSH Key Handling ===
echo ""
echo "=== SSH Key Setup for GitHub ==="
KEY_FILE="$HOME/.ssh/id_ed25519"
PUB_FILE="$KEY_FILE.pub"

if [ -f "$PUB_FILE" ]; then
  echo "✅ Existing ed25519 key found."
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "⚠️  RSA key found (ed25519 is better). Using RSA."
  KEY_FILE="$HOME/.ssh/id_rsa"
  PUB_FILE="$KEY_FILE.pub"
else
  echo "🔑 No SSH key found. Generating new ed25519 key..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE"
fi

echo ""
echo "📋 Your public key:"
cat "$PUB_FILE"
echo ""
echo "✅ Go to: https://github.com/settings/keys"
echo "   Click 'New SSH key'"
echo "   Title: e.g. My $(hostname) - $(date +%Y)"
echo "   Paste the entire key above (starting with ssh-ed25519 ... and ending with e.g shownzy001@gmail.com)"
echo "   Now, click the add SSH button"
echo ""
read -p "Press Enter AFTER you added the key to GitHub..."

# Start ssh-agent and add key
echo "🔑 Starting SSH agent..."
eval "$(ssh-agent -s)"
ssh-add "$KEY_FILE"

echo "🧪 Testing GitHub SSH connection..."
ssh -T git@github.com || echo "⚠️  Connection test showed warning (normal if first time). Check output above."
echo ""

# SSH Commit Signing Setup
echo "🔏 Configuring SSH commit signing..."

git config --global gpg.format ssh
git config --global user.signingkey "$PUB_FILE"
git config --global commit.gpgsign true 
git config --global tag.gpgsign true

echo "✅ SSH commit signing enabled."

echo ""
read -p "Press Enter to continue with Git configurations..."

# Apply Git Configurations
echo "⚙️  Applying Git configurations..."

git config --global init.defaultBranch main
git config --global help.autocorrect 1
git config --global color.ui auto
git config --global core.editor "code --wait"
git config --global core.fsmonitor true
git config --global fetch.prune true
git config --global pull.ff only
git config --global gc.auto 256
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global push.default simple
git config --global color.status.untracked red

# OS-specific settings
if [ "$OS" = "windows" ]; then
  git config --global core.autocrlf true
  git config --global core.ignorecase true
  git config --global credential.helper manager-core
elif [ "$OS" = "mac" ]; then
  git config --global core.autocrlf input
  git config --global core.ignorecase true
  git config --global credential.helper osxkeychain
else
  git config --global core.autocrlf input
  git config --global core.ignorecase false
  git config --global credential.helper store
fi

# Aliases
git config --global alias.lg "log --graph --oneline --decorate --all"
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch

# VS Code diff/merge
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "code --wait --diff \$LOCAL \$REMOTE"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait \$MERGED"

# Extra useful settings
git config --global core.quotePath false
git config --global merge.conflictstyle zdiff3
git config --global rerere.enabled true

# Global gitignore
git config --global core.excludesfile ~/.gitignore_global
cat << 'EOF' > ~/.gitignore_global

 # GLOBAL OS FILES

# Linux
.fuse_hidden*
.directory
.Trash-*
.nfs*

# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk
*.icloud

# Windows
Thumbs.db
Desktop.ini

# EDITORS & IDEs


# VSCode
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
!.vscode/*.code-snippets
.vscode-test
.history
*.vsix

# JetBrains / IntelliJ
.idea/*
!.idea/codeStyles
!.idea/runConfigurations
*.iml
modules.xml
*.ipr
*.iws

# Sublime
*.tmlanguage.cache
*.tmPreferences.cache
*.stTheme.cache
*.sublime-workspace
Package Control.cache/
Package Control.ca-certs/
Package Control.ca-bundle
Package Control.merged-ca-bundle
Package Control.user-ca-bundle
oscrypto-ca-bundle.crt
bh_unicode_properties.cache
GitHub.sublime-settings

# Vim
[._]*.s[a-v][a-z]
[._]*.sw[a-p]
Session.vim
Sessionx.vim
.netrwhist
[._]*.un~


# VERSION CONTROL


*.orig
*.BACKUP.*
*.BASE.*
*.LOCAL.*
*.REMOTE.*
*_BACKUP_*.txt
*_BASE_*.txt
*_LOCAL_*.txt
*_REMOTE_*.txt


# ENVIRONMENT & SECRETS (SECURITY HARDENED)


.env
.env.*
.env.local
.env.*.local
.env.production
.env.staging
.env.development
.env.test

# Private keys / crypto material
*.pem
*.key
*.p12
*.pfx
*.crt
*.csr

# Wallet / keystore
keystore/
wallets/
*.keystore
*.mnemonic

# SSH
**/.ssh/id_*
**/.ssh/*_id_*
**/.ssh/known_hosts


# NODE / JS / TS


node_modules/
.npm
.pnp
.pnp.js

npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*
.pnpm-debug.log*

.parcel-cache
.nyc_output
.eslintcache
.stylelintcache

coverage/
*.lcov
*.tsbuildinfo


# NEXT.JS

.next/
out/
.vercel
.next/cache


# NUXT


.nuxt
.nuxt-*
.output
.gen
dist/


# REMIX

.cache
/public/build


# RUST

target/
debug/
**/*.rs.bk
rust-project.json

# Rust test artifacts
*.profraw
*.profdata


# SOLIDITY / WEB3

# Hardhat
artifacts/
cache/
typechain/
coverage/

# Foundry
out/
broadcast/
forge-cache/

# Truffle
build
build_webpack
.truffle-solidity-loader
blockchain/geth/**
blockchain/keystore/**
blockchain/history

# Geth
/geth
/keystore
history

# ABI exports
*.abi
*.bin


# REDIS

dump.rdb
*.rdb

# DATABASES

*.accdb
*.db
*.dbf
*.mdb
*.sqlite3
*.db-shm
*.db-wal
*.mdf
*.ldf
*.ndf


# PYTHON / DJANGO

__pycache__/
*.py[cod]
*.so
.venv
venv/
env/
ENV/
.pytest_cache/
.mypy_cache/
.coverage
htmlcov/
db.sqlite3
media/


# GO

*.test
go.work


# JAVA

*.class
*.jar
*.war
*.ear
*.nar
hs_err_pid*
replay_pid*


# C# / .NET

[Dd]ebug/
[Rr]elease/
x64/
x86/
*.user
*.suo
*.pdb
*.cache
.vs/


# FLUTTER / DART

.dart_tool/
.packages
.pub-cache/
.flutter-plugins
.flutter-plugins-dependencies
build/
doc/api/


# LARAVEL / PHP

/vendor/
storage/*.key
public/storage
public/hot
.phpunit.result.cache


# RUBY / RAILS

*.gem
.bundle
/vendor/bundle
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep


# WORDPRESS

/wp-admin/
/wp-includes/
/wp-content/uploads/
wp-config.php
.htaccess


# BUILD OUTPUT / GENERIC

bin/
obj/
build/
dist/
out/
coverage/
*.log
*.tmp
*.cache
*.pid
*.seed
*.tgz


# LIGHTHOUSECI
.lighthouseci/


# DOCKER


# Docker overrides & local configs
docker-compose.override.yml
docker-compose.local.yml
docker-compose.*.local.yml

# Environment files often used by docker
.docker.env
.env.docker
.env.docker.local

# Docker runtime / temp
*.pid
*.cid
*.sock

# Docker logs
docker.log
docker-*.log

# Build cache / context
.docker/
docker-data/
docker-tmp/

# PACKAGE MANAGERS

# NPM
package-lock.json

# PNPM

# Yarn
.yarn/
.yarn-cache/
.yarnrc.yml
.pnp.*
.yarn-integrity

# Bun
bun.lockb

# Turborepo
.turbo/

# Go
go.sum

# Java / Gradle
.gradle/
gradle-app.setting

EOF

echo "✅ Global .gitignore created."

# Show final config
echo ""
echo "📋 Final Global Git Configuration:"
git config --global --list | sort

echo ""
echo "🎉 SUCCESS! Git is fully configured."
echo "✅ You can now use SSH to clone repos (git clone git@github.com:username/repo.git)"
echo "💡 Recommendation: Restart your terminal."
echo "   Or run: source ~/.bashrc   (if using bash)"
echo ""
echo "You can close this terminal now."
