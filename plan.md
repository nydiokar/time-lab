# Time-Lab Scaffold (Improved Plan)

## Objective
Build a **reproducible AI workbench** like the `time-2025` repo:  
- Pinned Nix environment  
- Daily artifact capture  
- Small scripts → pipelines  
- Rust/Python integration  
- CI parity  
- Ready for AI-team integration  

## Ground Rules
- All runs happen inside **Nix flake devshells** or via `nix run`.  
- Every run emits a `run.json` manifest and artifacts in a dated folder.  
- One repo. One lockfile. Many profiles.  
- Secrets kept outside git (`sops-nix` or `.env` files).  
- Determinism where possible; log seeds and model hashes.

---

## Repository Layout

time-lab/
├── flake.nix
├── flake.lock
├── .envrc
├── .gitignore
├── .gitattributes
├── Justfile
├── docs/
│ ├── SOPS.md
│ ├── DECISIONS.md
│ └── SCHEMA_run.json.md
├── scripts/
│ ├── today.sh
│ ├── run_llm_task.sh
│ ├── mine_commits.sh
│ ├── summarize_diff.sh
│ └── sync_latest.sh
├── tools/
│ ├── rust_extractor/
│ │ ├── Cargo.toml
│ │ └── src/main.rs
│ └── py_post/
│ ├── pyproject.toml
│ └── py_post.py
├── nix/
│ ├── overlays.nix
│ └── poetry2nix.nix
├── secrets/ # not in git
│ └── .env.lab
└── 2025/
└── 10/
└── 15/
├── README.md
├── ai-team/
│ ├── specs/
│ └── artifacts/
├── analyzer/
│ ├── inputs/
│ └── outputs/
└── knowledge/
├── notes.md
└── graph/

markdown
Copy code

---

## Improvements Over Draft

1. **Deterministic IDs & UTC timestamps**  
   - `run_id = sha256(spec + git_sha + flake_lock + utc_timestamp)`  
   - `date -u +"%Y-%m-%dT%H:%M:%SZ"`

2. **LLM reproducibility knobs**  
   - Log `temperature, top_p, seed, max_tokens, stop`  
   - Record model file hash/etag if possible  

3. **Schema validation**  
   - Add `schemas/run.schema.json` and `schemas/spec.schema.json`  
   - Validate specs before run  

4. **Safer shell**  
   - `set -Eeuo pipefail; IFS=$'\n\t'` in scripts  
   - Use `mktemp -d` for scratch dirs  

5. **Profile isolation**  
   - Root `.envrc` minimal (`use flake .`)  
   - Subfolders choose profiles (`use flake ../..#rust_an`)  

6. **Lint & format**  
   - Nix: `alejandra`  
   - Rust: `cargo fmt`, `cargo clippy`  
   - Python: `ruff`, `black`, `mypy`  
   - Shell: `shellcheck`

7. **Pre-commit hooks**  
   - black, ruff, mypy, shellcheck, detect-secrets, trailing-whitespace  

8. **Secrets**  
   - `detect-secrets` baseline  
   - `.env` not in git  
   - Later adopt `sops-nix`

9. **Provenance**  
   - Add `git describe` + `nix flake metadata` to manifests  

10. **Artifact layout**  
   - `YYYY/MM/DD`  
   - Inside run: `run.json`, `input/`, `output/`, `logs/`  
   - `latest/` symlink + `runs.csv`  

11. **CI upgrades**  
   - Add Cachix later  
   - E2E test with small fixture  

12. **Network safety**  
   - Default offline; `allow_net: true` must be explicit  

13. **Git mining optimization**  
   - Use shallow `--filter=blob:none` instead of repeated fetches  

14. **Python packaging**  
   - Start with pip in Nix devshell  
   - Upgrade to `uv` or `poetry2nix` later  

15. **Justfile interface**  
   - Add `just day`, `just ai`, `just mine`, `just summ`, `just check`  

16. **Timezone clarity**  
   - Canonical UTC in `run.json`, optional local time  

17. **Fixtures for tests**  
   - `tests/fixtures/` with tiny specs/diffs  

18. **Lockfile governance**  
   - Document how to update/review `flake.lock`  

19. **Security posture**  
   - Run as non-root  
   - Secrets dir `0700`  
   - Optional: dedicated system user  

20. **AI-team contract**  
   - Freeze `spec.json` schema  
   - Return codes: `0` success, `64` usage, `65` data, `70` internal  
   - Only read artifacts folder, not stdout  

---

## Run Manifest Example

```json
{
  "run_id": "sha256-hash",
  "timestamp_start": "2025-10-15T10:23:00Z",
  "timestamp_end": "2025-10-15T10:23:02Z",
  "cmd": "llm-task --spec 2025/10/15/ai-team/specs/demo.json",
  "git_sha": "abcd123",
  "flake_lock_sha256": "efgh456",
  "env": {
    "system": "x86_64-linux",
    "apps": ["llm-task@1.0"],
    "tools": {"rustc":"1.XX","python":"3.11.X"}
  },
  "task": {
    "kind": "llm",
    "spec_path": "demo.json",
    "inputs_hash": "sha256-of-spec"
  },
  "model": {
    "name": "ollama:qwen2.5:7b",
    "hash": "sha256-model",
    "params": {"temperature":0.2,"top_p":0.95,"seed":1234}
  },
  "status": "ok",
  "artifacts": ["input.spec.json","output.jsonl","log.txt"]
}
Acceptance Checklist
nix develop → Rust, Python, jq, just available

nix build .#rust_extractor succeeds

just day creates daily tree

just ai spec=2025/10/15/ai-team/specs/foo.json writes artifacts

just mine repo=owner name=repo limit=5 creates commit folders

just summ sha=abcd123 creates analysis_summary.md

nix flake check passes in CI

Decision Registry (examples)
D001: VM on Windows host, no Docker

D002: Single repo monorepo

D003: Date tree YYYY/MM/DD

D004: Run manifests must follow schema

D005: Model calls logged with params + seed

D006: Existing projects wrapped via devShells

Hand-off Contract (for AI or dev)
Create tree exactly as above

Write flake.nix with shells, packages, apps

Place hardened scripts

Implement Rust + Python tools

Add .envrc root + subfolder profiles

Add Justfile with commands

Add docs, schema, decisions

Add pre-commit hooks and CI workflow

Verify acceptance checklist

Output absolute paths of artifacts after each run