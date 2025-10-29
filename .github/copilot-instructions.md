# Copilot Instructions for finpilot bootc Image Template

## CRITICAL: Pre-Commit Checklist

**Execute before EVERY commit:**
1. **Conventional Commits** - ALL commits MUST follow conventional commit format (see below)
2. **Shellcheck** - `shellcheck *.sh` on all modified shell files
3. **YAML validation** - `python3 -c "import yaml; yaml.safe_load(open('file.yml'))"` on all modified YAML
4. **Justfile syntax** - `just --list` to verify
5. **Confirm with user** - Always confirm before committing and pushing

**Never commit files with syntax errors.**

### REQUIRED: Conventional Commit Format

**ALL commits MUST use conventional commits format**

```
<type>[optional scope]: <description>
```

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

### 2. Create "What's Different" section in README

**CRITICAL**: Add this section near the top of README.md (after the title/intro, before detailed docs):

```markdown
## What Makes this Raptor Different?

Here are the changes from [Base Image Name]. This image is based on [Bluefin/Bazzite/Aurora/etc] and includes these customizations:

### Added Packages (Build-time)
- **System packages**: tmux, micro, mosh - [brief explanation of why]

### Added Applications (Runtime)
- **CLI Tools (Homebrew)**: neovim, helix - [brief explanation]
- **GUI Apps (Flatpak)**: Spotify, Thunderbird - [brief explanation]

### Removed/Disabled
- List anything removed from base image

### Configuration Changes
- Any systemd services enabled/disabled
- Desktop environment changes
- Other notable modifications

*Last updated: [date]*
```

**Maintenance requirement**: 
- **ALWAYS update this section when you modify packages or configuration**
- Keep descriptions brief and user-focused (explain "why", not just "what")
- Write for typical Linux users, not developers
- Update the "Last updated" date with each change

### 3. Explain signing is optional

Signing is DISABLED by default. First builds succeed immediately. Enable later for production (see README).

**These 3 steps are REQUIRED for every new template instance.**

---

## Repository Structure

```
├── Containerfile          # Main build definition (FROM image, /opt config)
├── Justfile              # Local build automation (image name, build commands)
├── build/                # Build-time scripts (10-build.sh, 20-chrome.sh, etc.)
│   └── *.sh              # Numbered scripts: dnf5 install, systemctl enable
├── custom/               # User customizations (NOT in container, installed at runtime/first boot)
│   ├── brew/            # Homebrew Brewfiles (CLI tools, dev tools)
│   ├── flatpaks/        # Flatpak preinstall (GUI apps, post-first-boot)
│   └── ujust/           # User commands (shortcuts to Brewfiles, system tasks)
├── iso/                  # Local testing only (no CI/CD)
│   ├── iso.toml         # ISO installer config (bootc switch URL)
│   └── rclone/          # Upload configs (Cloudflare R2, AWS S3, etc.)
└── .github/workflows/    # CI/CD
    ├── build-testing.yml      # Builds :testing on push to testing
    ├── release-please.yml     # Auto-creates release PRs, merges to main
    ├── build.yml              # Builds :stable on main
    └── clean.yml        # Deletes images >90 days old
```

---

## Core Principles

### Build-time vs Runtime
- **Build-time** (`build/`): Baked into container. Use `dnf5 install`. Services, configs, system packages.
- **Runtime** (`custom/`): User installs after deployment. Use Brewfiles, Flatpaks. CLI tools, GUI apps, dev environments.

### Bluefin Convention Compliance
**ALWAYS follow @ublue-os/bluefin patterns. Confirm before deviating.**
- Use `dnf5` exclusively (never `dnf`, `yum`, `rpm-ostree`)
- Always `-y` flag for non-interactive
- COPRs: enable → install → **DISABLE** (critical, prevents repo persistence)
- Use `copr_install_isolated` function pattern
- Numbered scripts: `10-build.sh`, `20-chrome.sh`, `30-cosmic.sh`
- Check @bootc-dev for container best practices

### Branch Strategy
- **main** = Production releases ONLY. Never push directly. Builds `:stable` images.
- **Conventional Commits** = REQUIRED. `feat:`, `fix:`, `chore:`, etc.

---

## Where to Add Packages

This section provides clear guidance on where to add different types of packages.

### System Packages (dnf5 - Build-time)

**Location**: `build/10-build.sh`

System packages are installed at build-time and baked into the container image. Use `dnf5` exclusively.

**Example**:
```bash
# In build/10-build.sh
dnf5 install -y vim git htop neovim tmux
```

**When to use**: 
- System utilities and services
- Dependencies required for other build-time operations
- Packages that need to be available immediately on first boot
- Services that need to be enabled with `systemctl enable`

**Important**: 
- Always use `dnf5` (never `dnf`, `yum`, or `rpm-ostree`)
- Always add `-y` flag for non-interactive installs
- For COPR repositories, use `copr_install_isolated` pattern and disable after use

### Homebrew Packages (Brew - Runtime)

**Location**: `custom/brew/*.Brewfile`

Homebrew packages are installed by users after deployment. Best for CLI tools and development environments.

**Files**:
- `custom/brew/default.Brewfile` - General purpose CLI tools
- `custom/brew/development.Brewfile` - Development tools and environments
- `custom/brew/fonts.Brewfile` - Font packages
- Create custom `*.Brewfile` as needed

**Example**:
```ruby
# In custom/brew/default.Brewfile
brew "bat"        # cat with syntax highlighting
brew "eza"        # Modern replacement for ls
brew "ripgrep"    # Faster grep
brew "fd"         # Simple alternative to find
```

**When to use**:
- CLI tools and utilities
- Development tools (node, python, go, etc.)
- User-specific tools that don't need to be in the base image
- Tools that update frequently

**Important**:
- Brewfiles use Ruby syntax
- Users install via `ujust` commands (e.g., `ujust install-default-apps`)
- Not installed in ISO/container - users install after deployment

### Flatpak Applications (GUI Apps - Runtime)

**Location**: `custom/flatpaks/*.preinstall`

Flatpak applications are GUI apps installed after first boot. Use INI format.

**Files**:
- `custom/flatpaks/default.preinstall` - Default GUI applications
- Create custom `*.preinstall` files as needed

**Example**:
```ini
# In custom/flatpaks/default.preinstall
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall com.visualstudio.code]
Branch=stable

[Flatpak Preinstall org.gnome.Calculator]
Branch=stable
```

**When to use**:
- GUI applications
- Desktop apps (browsers, editors, media players)
- Apps that users expect to have immediately available
- Apps from Flathub (https://flathub.org/)

**Important**:
- Installed post-first-boot (not in ISO/container)
- Requires internet connection
- Find app IDs at https://flathub.org/
- Use INI format with `[Flatpak Preinstall APP_ID]` sections
- Always specify `Branch=stable` (or another branch)

---

## Quick Reference: Common User Requests

| Request | Action |
|---------|--------|
| Add package (build-time) | `build/10-build.sh` → `dnf5 install -y pkg` |
| Add package (runtime) | `custom/brew/default.Brewfile` → `brew "pkg"` |
| Add GUI app | `custom/flatpaks/default.preinstall` → `[Flatpak Preinstall org.app.id]` |
| Add user command | `custom/ujust/*.just` → create shortcut (NO dnf5) |
| Switch base image | `Containerfile` line 5 → `FROM ghcr.io/ublue-os/bluefin:stable` |
| Test locally | `just build && just build-qcow2 && just run-vm-qcow2` |
| Deploy (testing) | `sudo bootc switch ghcr.io/user/repo:testing` |
| Deploy (production) | `sudo bootc switch ghcr.io/user/repo:stable` |
| Make release | Push to testing with `feat:`/`fix:` → merge Release Please PR |
| Enable service | `build/10-build.sh` → `systemctl enable service.name` |
| Add COPR | `build/10-build.sh` → enable → install → **DISABLE** |

---

## Detailed Workflows

### 1. Base Images

**File**: `Containerfile` line 5

**Common choices**:
```dockerfile
FROM ghcr.io/ublue-os/bluefin:stable      # Dev, GNOME, `:stable` or `:gts`
FROM ghcr.io/ublue-os/bazzite:stable      # Gaming, Steam Deck
FROM ghcr.io/ublue-os/aurora:stable       # KDE Plasma
FROM quay.io/fedora/fedora-bootc:42       # Upstream Fedora
FROM quay.io/centos-bootc/centos-bootc:stream10  # Enterprise
```

**Tags**: `:stable` (recommended), `:latest` (bleeding edge), `-nvidia` variants available

### 2. Build Scripts (`build/`)

**Pattern**: Numbered files (`10-build.sh`, `20-chrome.sh`, `30-cosmic.sh`) run in order.

**Example - `build/10-build.sh`**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Install packages
dnf5 install -y vim git htop neovim

# Enable services
systemctl enable podman.socket

# Download binaries
curl -L https://example.com/tool -o /usr/local/bin/tool
chmod +x /usr/local/bin/tool
```

**Example - COPR pattern** (see `build/20-onepassword.sh`):
```bash
#!/usr/bin/env bash
set -euo pipefail

source /ctx/copr-install-functions.sh

# Chrome
dnf config-manager addrepo --from-repofile=https://dl.google.com/linux/linux_signing_key.pub
dnf5 install -y google-chrome-stable

# 1Password via COPR (isolated)
copr_install_isolated username/repo package-name
```

**Example - Desktop swap** (see `build/30-cosmic.sh`):
```bash
#!/usr/bin/env bash
set -euo pipefail

# Remove GNOME, install COSMIC
dnf5 group remove -y "GNOME Desktop Environment"
dnf5 copr enable -y ryanabx/cosmic-epoch
dnf5 install -y cosmic-desktop
dnf5 copr disable -y ryanabx/cosmic-epoch
systemctl set-default graphical.target
```

**CRITICAL**: Use `copr_install_isolated` function. Always disable COPRs.

### 3. Homebrew (`custom/brew/`)

**Files**: `*.Brewfile` (Ruby syntax)

**Example - `custom/brew/default.Brewfile`**:
```ruby
# CLI tools
brew "bat"        # Better cat
brew "eza"        # Better ls
brew "ripgrep"    # Better grep
brew "fd"         # Better find

# Dev tools
tap "homebrew/cask"
brew "node"
brew "python"
```

**Users install via**: `ujust install-default-apps` (create shortcut in `custom/ujust/`)

### 4. ujust Commands (`custom/ujust/`)

**Files**: `*.just` (all auto-consolidated)

**Example - `custom/ujust/apps.just`**:
```just
[group('Apps')]
install-default-apps:
    #!/usr/bin/env bash
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile

[group('Apps')]
install-dev-tools:
    #!/usr/bin/env bash
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile
```

**RULES**:
- **NEVER** use `dnf5` in ujust - only Brewfile/Flatpak shortcuts
- Use `[group('Category')]` for organization
- All `.just` files merged during build

### 5. Flatpaks (`custom/flatpaks/`)

**Files**: `*.preinstall` (INI format, installed after first boot)

**Example - `custom/flatpaks/default.preinstall`**:
```ini
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall org.gnome.Calculator]
Branch=stable

[Flatpak Preinstall com.visualstudio.code]
Branch=stable
```

**Important**: Not in ISO/container. Installed post-first-boot. Requires internet. Find IDs at https://flathub.org/

### 6. ISO/Disk Images (`iso/`)

**For local testing only. No CI/CD.**

**Files**:
- `iso/disk.toml` - VM images (QCOW2/RAW): `just build-qcow2`
- `iso/iso.toml` - Installer ISO: `just build-iso`

**CRITICAL** - Update bootc switch URL in `iso/iso.toml`:
```toml
[customizations.installer.kickstart]
contents = """
%post
bootc switch --mutate-in-place --transport registry ghcr.io/USERNAME/REPO:stable
%end
"""
```

**Upload**: Use `iso/rclone/` configs (Cloudflare R2, AWS S3, Backblaze B2, SFTP)

### 7. Release Workflow

**Branches**:
- `main` - Production only. Builds `:stable` images. Never push directly.

**Workflows**:
- `build-testing.yml` - Builds `:testing` on push to testing
- `release-please.yml` - Auto-creates/updates release PRs, auto-merges to main
- `build.yml` - Builds `:stable` on main
- `renovate.json` - Monitors base image updates (every 6 hours)
- `clean.yml` - Deletes images >90 days (weekly)

### 8. Image Signing (Optional, Recommended for Production)

**Default**: DISABLED (commented out in workflows) to allow first builds.

**Enable**:
```bash
# Generate keys
COSIGN_PASSWORD="" cosign generate-key-pair
# Creates: cosign.key (SECRET), cosign.pub (COMMIT)

# Add to GitHub
# Settings → Secrets and Variables → Actions → New secret
# Name: SIGNING_SECRET
# Value: <paste entire contents of cosign.key>

# Uncomment signing sections in:
# - .github/workflows/build.yml
# - .github/workflows/build-testing.yml
```

**NEVER commit `cosign.key`**. Already in `.gitignore`.

---

## Critical Rules (Enforced)

1. **ALWAYS** use Conventional Commits format for ALL commits (required for Release Please)
   - Format: `<type>[scope]: <description>`
   - Valid types: `feat:`, `fix:`, `docs:`, `chore:`, `build:`, `ci:`, `refactor:`, `test:`
   - Breaking changes: Add `!` or `BREAKING CHANGE:` in footer
   - See `.github/commit-convention.md` for examples
2. **NEVER** commit `cosign.key` to repository
3. **ALWAYS** disable COPRs after use (`copr_install_isolated` function)
4. **ALWAYS** use `dnf5` exclusively (never `dnf`, `yum`, `rpm-ostree`)
5. **ALWAYS** use `-y` flag for non-interactive installs
6. **NEVER** use `dnf5` in ujust files - only Brewfile/Flatpak shortcuts
7. **ALWAYS** work on testing branch for development
8. **ALWAYS** let Release Please handle testing→main merges
9. **NEVER** push directly to main (only via Release Please)
10. **ALWAYS** confirm with user before deviating from @ublue-os/bluefin patterns
11. **ALWAYS** run shellcheck/YAML validation before committing
12. **ALWAYS** update bootc switch URL in `iso/iso.toml` to match user's repo
13. **ALWAYS** follow numbered script convention: `10-*.sh`, `20-*.sh`, `30-*.sh`
---

## Troubleshooting

| Symptom | Cause | Solution |
|---------|-------|----------|
| Build fails: "permission denied" | Signing misconfigured | Verify signing commented out OR `SIGNING_SECRET` set |
| Build fails: "package not found" | Typo or unavailable | Check spelling, verify on RPMfusion, add COPR if needed |
| Build fails: "base image not found" | Invalid FROM line | Check syntax in `Containerfile` line 5 |
| Release Please no PRs | Missing setup OR invalid commits | 1. Enable Actions permissions 2. MUST use conventional commits format 3. Push to testing branch |
| Release Please PR not updating | Invalid commit format | ALL commits MUST follow `<type>: <description>` format. Fix commit messages and force push |
| Commits not in changelog | Wrong commit type | Use `feat:` or `fix:` for changes. `docs:`, `chore:` etc. don't trigger releases |
| Changes not in production | Wrong workflow | Push to testing first, merge Release Please PR to get `:stable` |
| ISO missing customizations | Wrong bootc URL | Update `iso/iso.toml` bootc switch URL to match repo |
| COPR packages missing after boot | COPR not disabled | COPRs persist if not disabled - use `copr_install_isolated` |
| ujust commands not working | Wrong install location | Files must be in `custom/ujust/` and copied to `/usr/share/ublue-os/just/` |
| Flatpaks not installed | Expected behavior | Flatpaks install post-first-boot, not in ISO/container |
| Local build fails | Wrong environment | Must run on bootc-based system or have podman installed |

---

## Advanced Topics

### /opt Immutability
Some packages (Chrome, Docker Desktop) write to `/opt`. On Fedora, it's symlinked to `/var/opt` (mutable). To make immutable:

Uncomment `Containerfile` line 20:
```dockerfile
RUN rm /opt && mkdir /opt
```

### Multi-Architecture
- Local `just` commands support your platform
- Most UBlue images support amd64/arm64
- Add `-arm64` suffix if needed: `bluefin-arm64:stable`
- Cross-platform builds require additional setup

### Custom Build Functions
See `build/copr-install-functions.sh` for reusable patterns:
- `copr_install_isolated` - Enable COPR, install packages, disable COPR
- Follow @ublue-os/bluefin conventions exactly

### Rechunker (Optional)
Rechunker optimizes container layer distribution for better resumability.

**Default**: Disabled (faster initial builds)

**To enable**:
1. Edit `.github/workflows/build.yml`
2. Uncomment "Run Rechunker" step (~line 124)
3. Uncomment "Load in podman and tag" step (~line 151)
4. Comment out "Tag for registry" step (~line 159)

**Recommendation**: Enable for production after initial testing succeeds.

**Documentation**: https://github.com/hhd-dev/rechunk

---

## Image Tags Reference

**Main branch** (production releases):
- `stable` - Latest stable release (recommended)
- `stable.20250129` - Datestamped stable release
- `20250129` - Date only
- `v1.0.0` - Version from Release Please

**PR builds**:
- `pr-123` - Pull request number
- `sha-abc123` - Git commit SHA (short)

---

## File Modification Priority

When user requests customization, check in this order:

1. **`build/10-build.sh`** (50%) - Build-time packages, services, system configs
2. **`custom/brew/`** (20%) - Runtime CLI tools, dev environments
3. **`custom/ujust/`** (15%) - User convenience commands
4. **`custom/flatpaks/`** (5%) - GUI applications
5. **`Containerfile`** (5%) - Base image, /opt config, advanced builds
6. **`Justfile`** (2%) - Image name, build parameters
7. **`iso/*.toml`** (2%) - ISO/disk customization for testing
8. **`.github/workflows/`** (1%) - Metadata, triggers, workflow config

---

## Resources & Documentation

- **Bluefin patterns**: https://github.com/ublue-os/bluefin
- **bootc documentation**: https://github.com/containers/bootc
- **Release Please**: https://github.com/googleapis/release-please
- **Conventional Commits**: https://www.conventionalcommits.org/
- **RPMfusion packages**: https://mirrors.rpmfusion.org/
- **Flatpak IDs**: https://flathub.org/
- **Homebrew**: https://brew.sh/
- **Universal Blue**: https://universal-blue.org/

---

**Last Updated**: 2025-01-29  
**Template Version**: finpilot with Release Please + Renovate  
**Maintainer**: Universal Blue Project
