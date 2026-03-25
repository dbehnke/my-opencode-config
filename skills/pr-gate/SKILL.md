---
name: pr-gate
description: Use this skill when preparing to open or push a PR. Runs the full local review pipeline — lint, static analysis, then AI diff review via @code-reviewer. Produces a structured issue report. Use when user says "run pr-gate", "review before push", "pre-PR check", or similar.
---

# PR Gate Skill

## Purpose

Runs the complete pre-PR quality pipeline locally before code is pushed,
preventing the endless AI review loop caused by pushing unreviewed code.

## Tool Preference Order (Per-Check Fallback)

For each language/check, pr-gate uses the best available tool:

1. **Nix** (if `nix-shell` or `nix develop` is available) — Try first if in nix environment
2. **Individual linter** (if installed) — Try second
3. **Megalinter** (if Docker available) — Fill gaps where individual linters are missing

This means: Use your preferred tools first, but Megalinter fills in for anything you don't have installed.

---

### Option A: Individual Linters + Gitleaks (Universal)

No Docker dependency. Install tools via your package manager (brew, apt, pacman, etc.)
or use Nix (see Option C).

**Install:**
```bash
# JavaScript/TypeScript
npm install -g eslint oxlint

# Go
# brew install golangci-lint  # macOS
# apt install golangci-lint    # Debian/Ubuntu
# pacman -S golangci-lint     # Arch

# Python
# brew install ruff            # macOS
# apt install ruff             # Debian/Ubuntu
# pacman -S ruff               # Arch

# Shell
# brew install shellcheck      # macOS
# apt install shellcheck       # Debian/Ubuntu
# pacman -S shellcheck        # Arch

# Security (injection, XSS, auth issues)
# brew install semgrep          # macOS
# pip install semgrep           # or use Nix

# Secrets detection
# brew install gitleaks          # macOS
# apt install gitleaks          # Debian/Ubuntu
# or use Nix (see Option C)
```

**Run:**
```bash
# Linters
npx oxlint . 2>&1 || true
npx eslint . --format json --output-file /tmp/eslint-results.json 2>&1 || true
golangci-lint run --out-format json > /tmp/golangci-results.json 2>&1 || true
ruff check --output-format json . > /tmp/ruff-results.json 2>&1 || true

# Shell files — use git ls-files for portability across projects
git ls-files '*.sh' | xargs -r shellcheck 2>&1 || true

# Markdown files — catches duplicate step numbers, broken lists, etc.
git diff HEAD --name-only | grep '\.md$' | xargs -r npx markdownlint 2>&1 || true

semgrep --json --config=auto . > /tmp/semgrep-results.json 2>&1 || true

# Secrets
gitleaks protect --staged
```

---

### Option B: Megalinter + Gitleaks (Convenience)

One tool to rule them all. Requires Docker (cross-platform).

**Install:**
```bash
# Docker (recommended - works on Linux, macOS, Windows)
docker pull oxsecurity/megalinter:latest

# Secrets (use package manager or Nix)
# brew install gitleaks  # macOS
# apt install gitleaks    # Debian/Ubuntu
# or use Nix (see Option C)
```

**Run:**
```bash
# Ensure image is up to date
docker pull oxsecurity/megalinter:latest

# Run on diff
git diff HEAD --name-only > /tmp/changed_files.txt
mega-linter-runner -x -fl "/tmp/changed_files.txt"

# Secrets
gitleaks protect --staged
```

**Note:** Megalinter wraps the same linters as Option A. Use this if you want convenience.

---

### Option C: Nix (Reproducible)

For power users who want reproducible environments. No Docker, but requires Nix.

**Install:**
```bash
# Install Nix (if not already installed)
/bin/bash -c "$(curl -L https://nixos.org/nix/install)"
```

**With flake** (add to your project's `flake.nix`):
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        nodejs_20
        eslint
        oxlint
        golangci-lint
        ruff
        shellcheck
        semgrep
        gitleaks
      ];
    };
  };
}
```

**Run:**
```bash
# Enter the dev shell
nix develop

# Run linters
npx oxlint . 2>&1 || true
npx eslint . --format json --output-file /tmp/eslint-results.json 2>&1 || true
golangci-lint run --out-format json > /tmp/golangci-results.json 2>&1 || true
ruff check --output-format json . > /tmp/ruff-results.json 2>&1 || true

# Shell files — use git ls-files for portability
git ls-files '*.sh' | xargs -r shellcheck 2>&1 || true

# Markdown files
git diff HEAD --name-only | grep '\.md$' | xargs -r npx markdownlint 2>&1 || true

semgrep --json --config=auto . > /tmp/semgrep-results.json 2>&1 || true

# Secrets
gitleaks protect --staged
```

---

## Common Checks (All Options)

### Hygiene pass
```bash
# Check for accidentally committed cache/build artifacts
(git diff HEAD --name-only | grep -E \
  '\.(cache|pyc|pyo)$|__pycache__|\.pytest_cache|\.next|\.nuxt|\.output|node_modules|\.turbo|\.vercel|\.netlify|dist|\.tsbuildinfo|\.rustfmt' \
  && echo "CACHE_FILES_DETECTED") || true
```

---

## AI Diff Review

Invoke @code-reviewer with this context:
- Pass the relevant linter JSON output so it knows what's already flagged
- Instruct it: "Here are the linter results. Do not re-flag these issues.
  Review the diff for anything beyond what the linters caught."

## Collate and Present Results

Merge all findings. Group by severity. Present as:

**ERRORS** (must fix before pushing)
- List each error with file, line, and suggestion

**WARNINGS** (should fix)
- List each warning

**INFO** (optional improvements)
- List each info item

**LINTER NOTES** (missing tools, skipped checks)
- List anything skipped

## Gate Decision

- If any `severity: error` exist → output: "❌ Do not push. Fix errors first."
- If only warnings/info → output: "✅ Clear to push. Warnings noted for follow-up."
- If no issues → output: "✅ Clean. No issues found."

## Cache Behavior

The @code-reviewer returns a `commit` hash in its JSON output.
On re-runs, compare the new commit hash against the previous run's hash.
Only surface issues that are NEW relative to the last review.
This prevents re-flagging already-reviewed items across multiple pushes.

## Notes

- This skill orchestrates; @code-reviewer does the AI analysis
- Linter passes are always re-run (deterministic, fast)
- AI review is skipped if the diff is empty
- Use your preferred tools first; Megalinter fills gaps for missing linters
- All three options produce equivalent results — choose based on your workflow
