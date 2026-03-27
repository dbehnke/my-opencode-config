# Playwright MCP Server Integration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Playwright MCP server documentation to README.md and AGENTS.md

**Architecture:** Add a new "MCP Servers" section to README.md and corresponding reference in AGENTS.md context-mode section. No code changes.

**Tech Stack:** Markdown documentation

---

## Chunk 1: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read current README.md around line 200-315 (ECC Skills section)**

Run: `read README.md offset=200 limit=120`
Purpose: Find exact insertion point after ECC Skills section

- [ ] **Step 2: Read current README.md around line 506-520 (Repository Structure section)**

Run: `read README.md offset=506 limit=20`
Purpose: Find if repository structure section needs updating

- [ ] **Step 3: Insert MCP Servers section in README.md after line 309**

Insert after the "## 3. ECC Skills" section (after line ~309 where it ends before "## 4. Code Review Agent")

The section to insert (will be provided in next step based on step 1 results)

- [ ] **Step 4: Verify README.md changes**

Run: `grep -n "MCP Servers" README.md`
Expected: Line number where new section starts

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: add MCP Servers section with Playwright"
```

---

## Chunk 2: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Read AGENTS.md context-mode section (lines 52-67)**

Run: `read AGENTS.md offset=52 limit=20`
Purpose: Find exact location of MCP tools table

- [ ] **Step 2: Read AGENTS.md around line 230-245 (after context-mode section)**

Run: `read AGENTS.md offset=230 limit=20`
Purpose: Find where to add MCP servers reference

- [ ] **Step 3: Add MCP servers reference to context-mode section**

Insert MCP tools table entry for Playwright after line 66 (after the semgrep entry in the table)

- [ ] **Step 4: Verify AGENTS.md changes**

Run: `grep -n "playwright" AGENTS.md`
Expected: Lines where Playwright is mentioned

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md
git commit -m "docs: add Playwright MCP server reference to AGENTS.md"
```

---

## Chunk 3: Final Verification

**Files:**
- Modify: `README.md`, `AGENTS.md`

- [ ] **Step 1: Verify both files have changes**

Run: `git diff --stat`
Expected: README.md and AGENTS.md with changes

- [ ] **Step 2: Final review of README.md MCP Servers section**

Run: `grep -A 30 "## 4. MCP Servers" README.md`
Expected: Full MCP Servers section renders correctly

- [ ] **Step 3: Final review of AGENTS.md MCP reference**

Run: `grep -B 2 -A 2 "playwright" AGENTS.md`
Expected: MCP tools table includes Playwright

---

## Files Summary

| File | Change |
|------|--------|
| `README.md` | Add "## 4. MCP Servers" section with Playwright setup |
| `AGENTS.md` | Add Playwright entry to MCP tools table in context-mode section |

## No Changes To

- `ecc-config/skills-list.txt`
- `install-ecc-skills.sh`
- `install-agents.sh`
- `scripts/integrate-ecc.sh`
- Any code files
