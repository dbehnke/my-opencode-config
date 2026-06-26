# ECC v2 Curated Migration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make ECC `v2.0.0` the curated default for this repo's selected OpenCode skills and agents without adopting ECC v2 hooks, control-pane, plugin, command, or full harness-profile surfaces.

**Architecture:** Keep the existing memory/hook-free installer model. The installer continues to copy only allowlisted `skills/` directories and selected `agents/*.md` files, then registers installed `SKILL.md` files through OpenCode's `instructions` array. Doctor and upgrade scripts treat `v2.0.0` as the curated stable line and protect against accidental drift.

**Tech Stack:** Bash installers, OpenCode JSON configuration, curated ECC skill list, `git`-based upstream tag install, `shellcheck`, repo doctor.

---

## Scenario Contract

1. **Happy path:** `./install-ecc-skills.sh v2.0.0` installs curated ECC v2 skills and selected agents into a temporary `HOME` and writes `version.txt` with `v2.0.0`.
   - Real surface: Bash command using temp `HOME`.
   - Pass condition: command exits 0, all curated skills install, version file first line is `v2.0.0`.

2. **Edge path:** `./scripts/upgrade-ecc.sh --check-only` with installed `v1.10.0` reports `v2.0.0` available without failing.
   - Real surface: Bash command using current install or controlled temp state.
   - Pass condition: command exits 0 and prints `Update available: v2.0.0`.

3. **Migration guard path:** `./scripts/upgrade-ecc.sh --auto` from `v1.10.0` may install `v2.0.0` only after this migration is implemented, not before.
   - Real surface: Bash command using temp `HOME`.
   - Pass condition after migration: command exits 0 and installed version is `v2.0.0`.

4. **Adjacent regression:** repo integration boundaries remain valid.
   - Real surface: `./scripts/doctor.sh`.
   - Pass condition: exits 0 with `Doctor passed: 0 failures, 0 warning(s)`.

---

## Files

- Modify: `install-ecc-skills.sh`
- Modify: `scripts/doctor.sh`
- Modify: `scripts/upgrade-ecc.sh`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `EXAMPLES.md`
- Inspect only: `ecc-config/skills-list.txt`

---

## Chunk 1: Version Policy

### Task 1: Update curated default version

**Files:**
- Modify: `install-ecc-skills.sh`
- Modify: `scripts/doctor.sh`
- Modify: `scripts/upgrade-ecc.sh`

- [ ] **Step 1: Write RED verification command**

Run before edits:

```bash
grep -n 'ECC_VERSION="${1:-v2.0.0}"' install-ecc-skills.sh
```

Expected: FAIL, because the default is still `v1.10.0`.

- [ ] **Step 2: Update installer default and usage text**

Change `install-ecc-skills.sh` default from `v1.10.0` to `v2.0.0`. Update usage examples that name `v1.10.0` as the specific version example.

- [ ] **Step 3: Update doctor stable-version policy**

Change `scripts/doctor.sh` so `v2.0.0` passes as the curated stable version. Keep prerelease warning behavior for `rc`, `alpha`, and `beta` versions.

- [ ] **Step 4: Update upgrade script major-version behavior**

Change `scripts/upgrade-ecc.sh` so `v1.10.0 -> v2.0.0` is no longer blocked by the major-upgrade guard. Keep the guard available for future major jumps beyond `v2`.

- [ ] **Step 5: Run GREEN verification**

```bash
grep -n 'ECC_VERSION="${1:-v2.0.0}"' install-ecc-skills.sh
bash -n install-ecc-skills.sh scripts/doctor.sh scripts/upgrade-ecc.sh
shellcheck install-ecc-skills.sh scripts/doctor.sh scripts/upgrade-ecc.sh
```

Expected: grep finds the v2 default, syntax passes, ShellCheck produces no new issues.

---

## Chunk 2: Safe Install Surface

### Task 2: Verify curated skill compatibility against ECC v2

**Files:**
- Inspect: `ecc-config/skills-list.txt`
- Modify only if needed: `ecc-config/skills-list.txt`

- [ ] **Step 1: Run compatibility check**

```bash
tmp=$(mktemp -d)
git clone --depth 1 --branch v2.0.0 https://github.com/affaan-m/everything-claude-code.git "$tmp/ecc"
while IFS= read -r skill || [ -n "$skill" ]; do
  case "$skill" in ''|'#'*) continue;; esac
  test -d "$tmp/ecc/skills/$skill" || printf 'missing %s\n' "$skill"
done < ecc-config/skills-list.txt
rm -rf "$tmp"
```

Expected: no `missing` lines.

- [ ] **Step 2: Verify selected agents exist**

```bash
tmp=$(mktemp -d)
git clone --depth 1 --branch v2.0.0 https://github.com/affaan-m/everything-claude-code.git "$tmp/ecc"
for agent in go-reviewer.md typescript-reviewer.md python-reviewer.md rust-reviewer.md security-reviewer.md docs-lookup.md; do
  test -f "$tmp/ecc/agents/$agent" || printf 'missing %s\n' "$agent"
done
rm -rf "$tmp"
```

Expected: no `missing` lines.

---

## Chunk 3: Real Install Verification

### Task 3: Exercise installer in a temporary HOME

**Files:**
- No source changes expected.

- [ ] **Step 1: Run temp-home install**

```bash
tmp_home=$(mktemp -d)
mkdir -p "$tmp_home/.config/opencode"
printf '{"plugin":["context-mode","oh-my-openagent"],"instructions":[]}\n' > "$tmp_home/.config/opencode/opencode.json"
HOME="$tmp_home" ./install-ecc-skills.sh
head -1 "$tmp_home/.config/opencode/ecc-skills/version.txt"
find "$tmp_home/.config/opencode/ecc-skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l
rm -rf "$tmp_home"
```

Expected: install exits 0, version is `v2.0.0`, skill count matches the curated list count.

- [ ] **Step 2: Run current-user doctor**

```bash
./scripts/doctor.sh
```

Expected: exits 0 with no warnings after the real install is upgraded or after doctor is updated to accept the current intended state during transition.

---

## Chunk 4: Documentation

### Task 4: Update user and agent guidance

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `EXAMPLES.md`

- [ ] **Step 1: Replace deferral language**

Update docs that currently say ECC v2 migration is deferred. New wording: ECC `v2.0.0` is the curated default for selected skills and agents only; full ECC v2 hooks/control-pane/plugin surfaces remain out of scope by default.

- [ ] **Step 2: Preserve boundary language**

Ensure docs still say context-mode owns memory/session continuity and OMO owns model routing.

- [ ] **Step 3: Verify docs references**

```bash
rg -n 'defer migration|research the ECC 2.0 migration later|default installer on `v1.10.0`|v1.10.0 by default' README.md AGENTS.md EXAMPLES.md scripts install-ecc-skills.sh
```

Expected: no stale deferral/default references remain, except historical notes if explicitly marked as history.

---

## Chunk 5: Final Gate

### Task 5: Run final verification and review

**Files:**
- All changed files.

- [ ] **Step 1: Run full verification**

```bash
bash -n install-ecc-skills.sh scripts/doctor.sh scripts/upgrade-ecc.sh
shellcheck install-ecc-skills.sh scripts/doctor.sh scripts/upgrade-ecc.sh
./scripts/upgrade-ecc.sh --check-only
./scripts/doctor.sh
```

Expected: commands exit 0.

- [ ] **Step 2: Run reviewer gate**

Invoke `@code-reviewer` on the current diff with focus on installer safety, version policy, docs accuracy, and OpenCode integration boundaries.

Expected: unconditional `APPROVE` before commit/push.

- [ ] **Step 3: Commit only intended files**

```bash
git status --short
git diff --stat
git add install-ecc-skills.sh scripts/doctor.sh scripts/upgrade-ecc.sh README.md AGENTS.md EXAMPLES.md ecc-config/skills-list.txt
git commit -m "Migrate curated ECC skills to v2"
```

Expected: one focused commit, no untracked artifacts included.
