{
  description = "Time-Lab: Reproducible AI Workbench";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };

        # Python environment with common packages
        pythonEnv = pkgs.python311.withPackages (ps:
          with ps; [
            pip
            setuptools
            wheel
            # Add more Python packages as needed
          ]);
      in {
        # Development shells for different workflows
        devShells = {
          # Default shell with common tools
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Task runners and utilities
              just
              jq
              direnv

              # Version control
              git

              # Node.js for Claude CLI and other tools
              nodejs_20

              # Shell scripting
              shellcheck
              shfmt

              # Text processing
              ripgrep
              fd
              bat

              # Development tools
              curl
              wget
              unzip

              # Python (minimal)
              pythonEnv
            ];

            shellHook = ''
              echo "🔬 Time-Lab Development Environment"
              echo "====================================="
              echo ""
              echo "Available commands:"
              echo "  just --list    # Show all tasks"
              echo "  just day       # Create today's workspace"
              echo ""
              echo "Shells:"
              echo "  nix develop .#rust_dev    # Rust development"
              echo "  nix develop .#python_ml   # Python ML"
              echo "  nix develop .#data_mining # Git analysis"
              echo ""
            '';
          };

          # Rust development environment
          rust_dev = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Rust toolchain
              rustc
              cargo
              rustfmt
              clippy
              rust-analyzer

              # Common tools
              just
              jq
              git
              shellcheck
            ];

            shellHook = ''
              echo "🦀 Rust Development Environment"
              echo "cargo --version: $(cargo --version)"
              echo "rustc --version: $(rustc --version)"
            '';
          };

          # Python ML environment
          python_ml = pkgs.mkShell {
            buildInputs = with pkgs; [
              python311
              python311Packages.pip
              python311Packages.virtualenv

              # Common tools
              just
              jq
              git
            ];

            shellHook = ''
              echo "🐍 Python ML Environment"
              # Create venv if it doesn't exist
              if [ ! -d .venv ]; then
                python -m venv .venv
              fi
              source .venv/bin/activate
              pip install -q --upgrade pip
              pip install -q -e "tools/py_post[dev]"
            '';
          };

          # Data mining environment
          data_mining = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Git tools
              git
              gh # GitHub CLI

              # Data processing
              jq
              yq
              csvkit

              # Common tools
              just
              pythonEnv
            ];

            shellHook = ''
              echo "⛏️  Data Mining Environment"
              echo "git --version: $(git --version)"
            '';
          };
        };

        # Packages (for future Rust/Python tools)
        packages = {
          # Rust extractor tool
          rust_extractor = pkgs.rustPlatform.buildRustPackage {
            pname = "rust_extractor";
            version = "0.1.0";
            src = ./tools/rust_extractor;
            cargoLock = {
              lockFile = ./tools/rust_extractor/Cargo.lock;
            };
          };
        };

        # Apps (for nix run .#app-name)
        apps = {
          # Example: day
          # day = {
          #   type = "app";
          #   program = "${self.packages.${system}.rust_extractor}/bin/day";
          # };
        };

        # Checks (for nix flake check)
        checks = {
          # Shellcheck all scripts
          shellcheck =
            pkgs.runCommand "shellcheck" {
              buildInputs = [pkgs.shellcheck];
            } ''
              shellcheck ${./scripts}/*.sh
              touch $out
            '';

          # Nix format check
          nixfmt =
            pkgs.runCommand "nixfmt-check" {
              buildInputs = [pkgs.alejandra];
            } ''
              alejandra --check ${./.}
              touch $out
            '';
        };
      }
    );
}
