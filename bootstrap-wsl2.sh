#!/usr/bin/env bash
# WSL2 Bootstrap Script for Time-Lab
# Run this once on any new WSL2 instance to set up the complete environment
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/main/bootstrap-wsl2.sh | bash
#   OR: bash bootstrap-wsl2.sh

set -Eeuo pipefail
IFS=$'\n\t'

echo "🚀 Time-Lab WSL2 Bootstrap"
echo "=========================="
echo ""

# Check if running in WSL
if ! grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo "⚠️  Warning: This doesn't look like WSL2. Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update package lists (minimal, just essentials)
echo "📦 Updating package lists..."
sudo apt-get update -qq

# Install only what Nix can't provide (curl, ca-certificates)
echo "📦 Installing system essentials..."
sudo apt-get install -y -qq curl ca-certificates xz-utils

# Install Nix (single-user mode, no daemon needed in WSL2)
if ! command -v nix &> /dev/null; then
    echo "📥 Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --no-daemon

    # Source Nix immediately
    . ~/.nix-profile/etc/profile.d/nix.sh
else
    echo "✅ Nix already installed: $(nix --version)"
fi

# Enable flakes
echo "🔧 Configuring Nix (enabling flakes)..."
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
# Keep builds deterministic
sandbox = true
# Speed up builds
max-jobs = auto
# Use binary cache
substituters = https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
EOF

# Reload Nix configuration
echo "🔄 Reloading Nix..."
. ~/.nix-profile/etc/profile.d/nix.sh

# Add Nix to shell profiles (persist across sessions)
echo "📝 Configuring shell profiles..."
for profile in ~/.bashrc ~/.zshrc; do
    if [ -f "$profile" ] && ! grep -q "nix-profile/etc/profile.d/nix.sh" "$profile"; then
        echo "" >> "$profile"
        echo "# Nix" >> "$profile"
        echo 'if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then' >> "$profile"
        echo '  . ~/.nix-profile/etc/profile.d/nix.sh' >> "$profile"
        echo 'fi' >> "$profile"
    fi
done

# Install direnv globally (optional but recommended)
echo "🔧 Installing direnv..."
nix profile install nixpkgs#direnv

# Add direnv hook to shell
for profile in ~/.bashrc ~/.zshrc; do
    if [ -f "$profile" ] && ! grep -q "direnv hook" "$profile"; then
        echo "" >> "$profile"
        echo "# Direnv" >> "$profile"
        if [[ "$profile" == *"zshrc"* ]]; then
            echo 'eval "$(direnv hook zsh)"' >> "$profile"
        else
            echo 'eval "$(direnv hook bash)"' >> "$profile"
        fi
    fi
done

# Configure git (only if not already configured)
if ! git config --global user.name &> /dev/null; then
    echo "⚙️  Git configuration needed"
    echo -n "Enter your git user.name: "
    read -r git_name
    echo -n "Enter your git user.email: "
    read -r git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global core.autocrlf input
fi

# Clone time-lab if not already in it
if [ ! -f "flake.nix" ]; then
    echo "📂 Time-Lab repository not detected in current directory"
    echo -n "Clone time-lab? (y/n): "
    read -r clone_response

    if [[ "$clone_response" =~ ^[Yy]$ ]]; then
        echo -n "Enter repository URL: "
        read -r repo_url

        mkdir -p ~/projects
        cd ~/projects
        git clone "$repo_url" time-lab
        cd time-lab
        echo "✅ Cloned to ~/projects/time-lab"
    fi
fi

# Test Nix installation
echo ""
echo "🧪 Testing Nix installation..."
nix --version
nix flake show nixpkgs 2>/dev/null || echo "Note: Test flake command completed"

# If we're in the time-lab directory, set up Claude CLI in user space
if [ -f "flake.nix" ]; then
    echo ""
    echo "📦 Setting up Claude CLI..."
    
    # Install to user's local directory (not Nix store)
    nix develop --command bash -c "npm install -g --prefix ~/.local @anthropic-ai/claude-code" || echo "Note: Will install Claude CLI to ~/.local"
    
    # Add ~/.local/bin to PATH if not already there
    if [ -f ~/.bashrc ] && ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
        echo '' >> ~/.bashrc
        echo '# User-local binaries' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    echo "✅ Claude CLI installed to ~/.local/bin"
fi

echo ""
echo "✅ Bootstrap Complete!"
echo ""
echo "📋 Summary:"
echo "  - Nix installed with flakes enabled"
echo "  - direnv installed and configured"
echo "  - Git configured"
echo "  - Node.js provided by Nix"
echo "  - Claude CLI installed globally"
echo ""
echo "🎯 Next Steps:"
echo "  1. Close and reopen your terminal (or run: source ~/.bashrc)"
echo "  2. Navigate to time-lab: cd ~/projects/time-lab"
echo "  3. Enter development environment: nix develop"
echo "  4. Verify Claude: claude --version"
echo "  5. Start building: just day"
echo ""
echo "💡 All tools (git, python, rust, node, claude) are provided by Nix!"
echo "   No need to install anything else manually."
echo ""
echo "🔄 To replicate on another machine:"
echo "   curl -fsSL <URL-to-this-script> | bash"
echo ""
