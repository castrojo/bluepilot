# Copilot Instructions for finpilot bootc Image Template

## CRITICAL: Pre-Commit Checklist

**Execute before EVERY commit:**
1. **Shellcheck** - `shellcheck *.sh` on all modified shell files
2. **YAML validation** - `python3 -c "import yaml; yaml.safe_load(open('file.yml'))"` on all modified YAML
3. **Justfile syntax** - `just --list` to verify  
4. **Confirm with user** - Always confirm before committing and pushing

**Never commit files with syntax errors.**

---

## CRITICAL: Template Initialization

**When this repository is used as a template, you MUST:**

### 1. Rename ALL instances of `finpilot`

**Source of truth**: `Containerfile` line 9: `# Name: finpilot`

**Files to update:**
- `Containerfile` (line 9)
- `Justfile` (line 1)
- `README.md` (line 1)
- `artifacthub-repo.yml` (line 5)
- `custom/ujust/README.md` (~line 175)
- `.github/workflows/ghcr-pruner.yml` (line 22)

### 2. Explain signing is optional

Signing is DISABLED by default. First builds succeed immediately. Enable later for production (see README).

**These 2 steps are REQUIRED for every new template instance.**

---

## Development Workflow - Simplified

**All work happens via pull requests to main:**
- Create feature branches
- Open PRs to `main`
- PRs trigger automatic validation
- Merge to `main` builds `:stable` images

**No separate testing branch. No release-please automation.**
