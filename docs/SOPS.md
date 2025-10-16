# Secrets Management with SOPS

## Overview

We use [sops-nix](https://github.com/Mic92/sops-nix) for managing secrets in Nix.

## Quick Start

### 1. Install SOPS

```bash
nix profile install nixpkgs#sops
```

### 2. Generate Age Key

```bash
mkdir -p secrets
age-keygen -o secrets/age-key.txt
chmod 600 secrets/age-key.txt
```

**⚠️ IMPORTANT**: Add `secrets/age-key.txt` to `.gitignore` (already done).

### 3. Create Secrets File

```bash
# Get your public key
cat secrets/age-key.txt | grep "public key"

# Create .sops.yaml
cat > .sops.yaml << EOF
keys:
  - &admin YOUR_PUBLIC_KEY_HERE
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: *admin
EOF

# Create encrypted secrets
sops secrets/lab.yaml
```

### 4. Access Secrets in Nix

```nix
# In flake.nix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs = { self, nixpkgs, sops-nix, ... }: {
    # Add sops to devShell
  };
}
```

## Best Practices

1. **Never commit unencrypted secrets**
2. **Use `.env` files for local development** (git-ignored)
3. **Use sops for production secrets**
4. **Rotate keys periodically**
5. **Document what secrets are needed** (but not their values!)

## Secrets Needed

Document here what secrets the project needs (without values):

- `OPENAI_API_KEY` - OpenAI API key for LLM tasks
- `GITHUB_TOKEN` - GitHub PAT for API access (mining commits)
- `HF_TOKEN` - Hugging Face token for model downloads

## Local Development

For local development, create `secrets/.env.lab`:

```bash
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

This file is automatically loaded by `.envrc`.
