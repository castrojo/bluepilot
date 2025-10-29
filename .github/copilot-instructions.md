# Copilot Instructions for Customizing bootc Image Template

**Situation**
The assistant is supporting a user who maintains a custom bootc (bootable container) image repository built from the ghcr.io/ublue-os/bluefin:stable base image. Bootc images are used to create bootable operating system environments from OCI containers, requiring adherence to container best practices, security standards, and proper image configuration.

**Task**
The assistant should help maintain and improve the bootc image repository by reviewing Containerfile configurations, suggesting optimizations, identifying security vulnerabilities, and ensuring the implementation follows industry-standard container and security practices specific to Podman and Buildah workflows.

**Objective**
Ensure the bootc image repository remains secure, efficient, and aligned with best practices for container development using Podman and Buildah, enabling reliable and safe bootable container deployments.

**Knowledge**
Bootc images combine traditional operating system concepts with container technology, requiring special attention to:
- Base image selection and minimal attack surface (building from ghcr.io/ublue-os/bluefin:stable)
- Layer optimization and image size management
- Security scanning and vulnerability management
- Proper file permissions and user configurations
- Systemd integration and boot process requirements
- Immutable infrastructure principles
- Supply chain security and image provenance
- Update and rollback mechanisms

The assistant should evaluate the user's Containerfile against:
- Containerfile structure and efficiency
- Security configurations (SELinux, seccomp, capabilities)
- Package management and dependency handling
- Secrets management and credential handling
- Image signing and verification
- CI/CD pipeline security
- Documentation completeness

The assistant should then:
- Identify specific security risks with severity levels
- Provide actionable remediation steps with code examples using Podman/Buildah commands
- Explain the rationale behind each recommendation
- Prioritize changes based on security impact and implementation effort
- Consider bootc-specific requirements that differ from standard containers
- Validate configurations against CIS benchmarks and security frameworks where applicable
- Ensure compatibility with the ghcr.io/ublue-os/bluefin:stable base image
- Recommend Podman and Buildah command-line options that enhance security and efficiency but only if they are recommended by @bootc-dev

## CRITICAL: Strict Linting Before Commits

**BEFORE COMMITTING ANY CHANGES, YOU MUST:**

1. **Validate all YAML files** - Use `python3 -c "import yaml; yaml.safe_load(open('file.yml'))"`
   - Check all workflow files in `.github/workflows/`
   - Verify renovate.json5 and other config files
   - Ensure proper indentation (YAML is whitespace-sensitive)

2. **Run shellcheck on all shell scripts** - Use `shellcheck script.sh`
   - Check all files in `build/` directory
   - Verify all `.sh` files including examples
   - Fix or suppress warnings with appropriate directives

3. **Verify JSON/JSON5 syntax** - Use `python3 -m json.tool` or appropriate validator
   - Check renovate.json5
   - Validate any JSON configuration files

4. **Test Justfile syntax** - Run `just --list` to verify
   - Ensure all recipes are valid
   - Check for typos in recipe names

**Never commit files with syntax errors. This breaks CI/CD and user workflows.**

## CRITICAL: Template Initialization

**WHEN THIS REPOSITORY IS USED AS A TEMPLATE, YOU MUST:**

### Step 1: Rename the Project

1. **Immediately check the repository name** from the user or from `github.event.repository.name`
2. **Rename ALL instances of `finpilot`** to match the new repository name
3. **Update these 5 files in order:**
   - `Containerfile` (line 9): `# Name: new-repo-name`
   - `Justfile` (line 1): `export image_name := env("IMAGE_NAME", "new-repo-name")`
   - `README.md` (line 1): `# new-repo-name`
   - `artifacthub-repo.yml` (line 5): `repositoryID: new-repo-name`
   - `custom/ujust/README.md` (~line 175): `localhost/new-repo-name:latest`
   - `.github/workflows/ghcr-pruner.yml` (line 22): `IMAGE_NAME: new-repo-name`

4. **Never leave `finpilot` as the name** in a templated repository - it's only an example

### Step 2: Set Up Release Workflow with Testing Branch

**IMMEDIATELY after renaming, you MUST set up the testing branch workflow:**

1. **Enable GitHub Actions permissions** (REQUIRED):
   - Guide user to: Settings → Actions → General
   - Enable: "Allow GitHub Actions to create and approve pull requests"
   - This allows Release Please to create PRs automatically

2. **Create and push the testing branch**:
   ```bash
   git checkout -b testing
   git push -u origin testing
   ```

3. **Explain the workflow** to the user:
   - **testing branch**: Development happens here, builds `:testing` images
   - **main branch**: Production releases only, builds `:latest` images
   - **Release Please**: Automatically tracks changes and creates release PRs
   - **Conventional Commits**: Required for automatic versioning
     - `feat:` = minor version bump (1.X.0)
     - `fix:` = patch version bump (1.0.X)
     - `feat!:` or `BREAKING CHANGE:` = major version bump (X.0.0)

4. **Guide first release**:
   ```bash
   git checkout testing
   git commit --allow-empty -m "feat: initial release"
   git push origin testing
   ```
   - This triggers the testing build workflow
   - Release Please creates a release PR
   - Merging the PR triggers:
     - GitHub Release creation
     - Auto-merge to main branch
     - Production `:latest` image build

5. **Explain image signing is OPTIONAL**:
   - Signing is disabled by default in workflows
   - First builds will succeed without signing keys
   - This allows immediate testing and development
   - Strongly recommend enabling signing for production
   - Point user to "Optional: Enable Image Signing" section in README

### Step 3: Verify Setup

**Confirm with user that:**
- [ ] Repository is renamed from finpilot
- [ ] Testing branch is created and pushed
- [ ] GitHub Actions permissions are enabled
- [ ] First commit is made to testing
- [ ] Build workflows are running successfully
- [ ] Release Please PR is created (if first commit made)

**This is NOT optional.** Every new template repository MUST:
1. Be renamed from `finpilot`
2. Have a `testing` branch for development
3. Have GitHub Actions permissions enabled
4. Understand the release workflow

### Key Workflow Files

**Release Workflow Files (already in template):**
- `.github/workflows/release-please.yml` - Creates release PRs and auto-merges to main
- `.github/workflows/build.yml` - Builds `:latest` images on main branch
- `.github/workflows/build-testing.yml` - Builds `:testing` images on testing branch
- `release-please-config.json` - Release Please configuration
- `.release-please-manifest.json` - Version tracking (starts at 1.0.0)

**Documentation (already in template):**
- `RELEASE_WORKFLOW.md` - Complete workflow guide
- `.github/SETUP_CHECKLIST.md` - Setup checklist
- `README.md` - Quick start with release workflow section

**DO NOT modify these workflow files unless specifically requested.** They are production-ready.

## CRITICAL: Follow Bluefin Conventions

**ALWAYS ensure you follow the conventions established in @ublue-os/bluefin when implementing build scripts.**

### Mandatory Practices:
- **COPR Repositories**: Always enable → install → **DISABLE** COPRs immediately after use
- **Package Management**: Use `dnf5` exclusively (never `dnf` or `yum`)
- **Non-interactive**: Always use `-y` flag for all package operations
- **Build Scripts**: Follow numbered script pattern (10-*, 20-*, etc.)
- **Cleanup**: Remove temporary files and repositories after installation

### Before Deviating from Patterns:
- **Confirm with the user** before implementing approaches that differ from Bluefin
- **Check Bluefin repository** for established patterns when uncertain
- **Explain the deviation** and why it's necessary if approved
- **Always Refer to the documentation** for bootc at @bootc-dev - always check their documentation for best practices

### Examples of Enforced Patterns:
```bash
# CORRECT: COPR usage
dnf5 -y copr enable username/repo-name
dnf5 -y install package-name
dnf5 -y copr disable username/repo-name  # CRITICAL: Always disable

# WRONG: Leaving COPR enabled
dnf5 -y copr enable username/repo-name
dnf5 -y install package-name
# Missing disable - this is WRONG
```

**This consistency ensures compatibility with Universal Blue ecosystem and prevents issues.**

## Overview
This repository is a Universal Blue bootc image template for creating custom Linux operating systems. When users ask for customizations, follow this guide to make efficient, correct decisions without exploring multiple options.

## Repository Structure

```
.
├── Containerfile              # Main build file defining the base image and build process
├── Justfile                   # Build automation with recipes for local testing
├── README.md                  # User documentation
├── artifacthub-repo.yml       # Optional ArtifactHub metadata
├── build/
│   └── 10-build.sh              # Script for installing packages and system modifications
├── custom/                    # User customization files
│   ├── brew/                 # Homebrew Brewfiles for package installation
│   │   ├── default.Brewfile
│   │   ├── development.Brewfile
│   │   └── fonts.Brewfile
│   ├── flatpaks/             # Flatpak preinstall configurations
│   │   └── default.preinstall
│   └── ujust/                # User-facing just commands
│       ├── custom-apps.just
│       └── custom-system.just
├── iso/                      # ISO and disk image configurations
│   ├── disk.toml            # Configuration for QCOW2/RAW disk images (local testing)
│   ├── iso.toml             # ISO configuration for Anaconda installer (local testing)
│   └── rclone/              # rclone configuration for manual ISO uploads
│       ├── README.md         # rclone configuration guide
│       ├── cloudflare-r2.conf # Cloudflare R2 example config
│       ├── aws-s3.conf       # AWS S3 example config
│       ├── backblaze-b2.conf # Backblaze B2 example config
│       ├── sftp.conf         # SFTP upload example config
│       └── scp.conf          # SCP upload example config
└── .github/workflows/
    └── build.yml            # CI/CD for building and publishing container images
```

## Core Customization Workflows

### 1. CHANGING THE BASE IMAGE

**When**: User wants to change from one Universal Blue image to another (Bazzite, Bluefin, Aurora) or use a different base (Fedora, CentOS).

**Where**: Edit `Containerfile`

**How**: Modify the `FROM` line (line 5):
```dockerfile
FROM ghcr.io/ublue-os/bazzite:stable
```

**Common Base Images**:
- Bazzite: `ghcr.io/ublue-os/bazzite:stable` (gaming-focused)
- Bluefin: `ghcr.io/ublue-os/bluefin:stable` (developer-focused)
- Aurora: `ghcr.io/ublue-os/aurora:stable` (KDE Plasma desktop)
- Universal Blue Base: `ghcr.io/ublue-os/base-main:latest` (minimal)
- Fedora: `quay.io/fedora/fedora-bootc:42` (upstream)
- CentOS: `quay.io/centos-bootc/centos-bootc:stream10` (enterprise)

**Image Tag Options**:
- `:stable` - Recommended for production
- `:latest` - Bleeding edge, may have issues
- `:gts` - Fedora GTS (older but stable)
- Specific NVIDIA variants available by appending `-nvidia` (e.g., `bluefin-nvidia:stable`)

**Decision Logic**:
- Gaming/Steam Deck → Bazzite
- Development/Docker/DevContainers/GNOME → Bluefin
- KDE Plasma preference → Aurora
- Minimal custom build → base-main
- Enterprise/RHEL compatibility → CentOS bootc
- Pure Fedora upstream → fedora-bootc

### 2. INSTALLING PACKAGES

**When**: User wants to install system packages, enable services, or modify the OS.

**Where**: Edit `build/10-build.sh`

**How**: Add commands to the script. The script runs with DNF5 (Fedora's package manager).

**Package Installation Examples**:

```bash
# Single package from Fedora repos
dnf5 install -y vim

# Multiple packages
dnf5 install -y neovim git htop

# From RPMfusion (enabled by default on UBlue images)
dnf5 install -y vlc ffmpeg

# Enable a COPR repository (temporarily)
dnf5 -y copr enable username/repo-name
dnf5 -y install package-name
dnf5 -y copr disable username/repo-name  # CRITICAL: Always disable COPRs

# Group install
dnf5 group install -y "Development Tools"

# Remove packages
dnf5 remove -y package-name
```

**Service Management Examples**:
```bash
# Enable systemd services
systemctl enable podman.socket
systemctl enable sshd.service

# Mask unwanted services
systemctl mask bluetooth.service
```

**File System Operations**:
```bash
# Create directories
mkdir -p /etc/custom-config

# Copy files (from build context)
cp /ctx/configs/myapp.conf /etc/myapp.conf

# Download files
curl -L https://example.com/binary -o /usr/local/bin/binary
chmod +x /usr/local/bin/binary
```

**Decision Logic**:
- Always use `dnf5` (not `dnf` or `yum`)
- Always use `-y` flag for non-interactive installs
- Always disable COPRs after use to prevent them from persisting
- Keep modifications minimal for faster builds
- Test package availability on RPMfusion before asking user: https://mirrors.rpmfusion.org/

### 3. CHANGING IMAGE NAME

**When**: User wants to customize the repository/image name.

**Where**: The project name is defined in the `Containerfile` comment section (line 9):
```dockerfile
# Name: finpilot
```

**Critical**: This is the **single source of truth** for the project name. All other references must match this name.

**Files that must be updated when changing the project name:**
1. **Containerfile** (line 9): `# Name: your-new-name`
2. **Justfile** (line 1): `export image_name := env("IMAGE_NAME", "your-new-name")`
3. **README.md** (line 1): `# your-new-name`
4. **artifacthub-repo.yml** (line 5): `repositoryID: your-new-name`
5. **custom/ujust/README.md** (~line 175): `localhost/your-new-name:latest` (in bootc switch example)

**How to Change**:
```bash
# 1. Update the Containerfile comment (line 9)
# Name: my-awesome-image

# 2. Update Justfile
export image_name := env("IMAGE_NAME", "my-awesome-image")

# 3. Update README.md title
# my-awesome-image

# 4. Update artifacthub-repo.yml
repositoryID: my-awesome-image

# 5. Update custom/ujust/README.md
sudo bootc switch --target localhost/my-awesome-image:latest
```

**Additional Notes**:
- The GitHub Actions workflow automatically uses repository name via `${{ github.event.repository.name }}`
- If user wants different CI/CD name, edit `.github/workflows/build.yml` env var `IMAGE_NAME`
- The Containerfile comment serves as documentation for where the name is used
- Always keep all 5 files synchronized with the same name

### 4. CONFIGURING DISK IMAGE BUILDS (LOCAL TESTING ONLY)

**When**: User wants to customize ISO or VM disk images for local testing.

**Where**: Edit files in `iso/` directory

**Important**: This template no longer includes automated ISO/disk building workflows. 
Disk images are built locally using the `just` commands for testing purposes only.

**Decision Matrix**:

| Use Case | File to Edit | Just Command |
|----------|--------------|--------------|
| VM images (QCOW2, RAW) | `iso/disk.toml` | `just build-qcow2` |
| ISO installer | `iso/iso.toml` | `just build-iso` |

**disk.toml Configuration**:
```toml
[[customizations.filesystem]]
mountpoint = "/"
minsize = "20 GiB"  # Minimum root partition size
```

**iso.toml Configuration**:

The `iso.toml` file contains:
1. **Kickstart commands** - Post-installation automation
2. **Anaconda modules** - Which installer screens to show

**Critical**: Always update the `bootc switch` command in iso.toml to match your repository:
```toml
[customizations.installer.kickstart]
contents = """
%post
bootc switch --mutate-in-place --transport registry ghcr.io/USERNAME/REPO:latest
%end
"""
```

**Decision Logic**:
- Use `disk.toml` for VM testing (QCOW2/RAW images)
- Use `iso.toml` for creating bootable installation media
- Both are for local testing only - no automated builds in CI/CD

### 5. HOMEBREW/BREWFILE INTEGRATION

**When**: User wants to provide runtime package installation options for users.

**Where**: Edit files in `custom/brew/` directory

**How**: Add packages to Brewfiles using Ruby syntax:
```ruby
# Add a tap (third-party repository)
tap "homebrew/cask"

# Install a formula (CLI tool)
brew "bat"
brew "eza"
brew "ripgrep"
```

**Example Files**:
- `custom/brew/default.Brewfile` - Essential command-line tools
- `custom/brew/development.Brewfile` - Development tools
- `custom/brew/fonts.Brewfile` - Programming fonts

**User Installation**:
Users install via: `brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile`
Or via ujust shortcuts: `ujust install-default-apps`

**Decision Logic**:
- Brewfiles are for **runtime** package installation, not build-time
- Build-time packages go in `build/10-build.sh`
- Create ujust shortcuts in `custom/ujust/custom-apps.just` for easy installation
- Brewfiles are copied to `/usr/share/ublue-os/homebrew/` during build

### 6. UJUST COMMAND SYSTEM

**When**: User wants to provide convenient commands for end users.

**Where**: Edit or create `.just` files in `custom/ujust/` directory

**How**: Create just recipes with user-friendly commands:
```just
# Install development tools via Brewfile
[group('Apps')]
install-dev-tools:
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile
```

**Example Files**:
- `custom/ujust/custom-apps.just` - Application installation commands
- `custom/ujust/custom-system.just` - System configuration commands

**Important Rules**:
- **NEVER** install packages via `dnf5` in ujust commands
- Use Brewfile shortcuts for package installation
- Use Flatpak for GUI applications
- All `.just` files are automatically consolidated during build

**Decision Logic**:
- ujust commands are for **runtime** user convenience
- Build-time operations go in `build/10-build.sh`
- Create shortcuts to Brewfiles, not direct package installs
- Use `[group('Category')]` to organize commands

### 7. FLATPAK PREINSTALL SYSTEM

**When**: User wants to pre-define Flatpak applications for first boot installation.

**Where**: Edit or create `.preinstall` files in `custom/flatpaks/` directory

**How**: Use INI format with Flatpak Preinstall sections:
```ini
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall org.gnome.Calculator]
Branch=stable
```

**Example Files**:
- `custom/flatpaks/default.preinstall` - Core applications from Bluefin

**Important Notes**:
- Flatpaks are **NOT** included in the ISO or container image
- They are **downloaded and installed on first boot** after user setup
- Requires internet connection
- Files are copied to `/etc/flatpak/preinstall.d/` during build
- Users can uninstall after installation if desired

**Decision Logic**:
- Use for GUI applications users will want
- Not for offline ISOs - requires network
- First boot will take longer while downloading
- Find Flatpak IDs at https://flathub.org/

### 8. CUSTOMIZING BUILD METADATA

**When**: User wants to customize image description, keywords, or branding.

**Where**: Edit `.github/workflows/build.yml` env variables (lines 14-16)

**How**:
```yaml
env:
  IMAGE_DESC: "My Awesome Custom OS"
  IMAGE_KEYWORDS: "bootc,gaming,developer,custom"
  IMAGE_LOGO_URL: "https://example.com/logo.png"
```

**For ArtifactHub listing**: Edit `artifacthub-repo.yml`:
```yaml
repositoryID: unique-id-from-artifacthub
owners:
  - name: User Name
    email: user@example.com
```

### 9. ADVANCED CONTAINERFILE MODIFICATIONS

**When**: User needs advanced customization beyond 10-build.sh.

**Scenarios**:

**A. Making /opt Immutable**:
Some packages (Chrome, Docker Desktop) write to `/opt`. On Fedora, it's symlinked to `/var/opt` (mutable). To make it immutable:

Uncomment in Containerfile (line 20):
```dockerfile
RUN rm /opt && mkdir /opt
```

**B. Adding Multiple Build Scripts**:
```dockerfile
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    /ctx/10-build.sh && \
    /ctx/post-install.sh
```

Then add `build_files/post-install.sh`.

**C. Copying Custom Files**:
```dockerfile
COPY --from=ctx /custom-configs /etc/
```

Files in `build_files/` are available at `/ctx/` during build.

**Decision Logic**:
- Use 10-build.sh for 95% of customizations
- Only edit Containerfile for:
  - Changing base image
  - Multi-stage builds
  - Advanced caching strategies

### 10. LOCAL TESTING WORKFLOW

**When**: User wants to test changes before pushing to GitHub.

**Prerequisites Check**:
- Running on a bootc-based system (Bazzite, Bluefin, Aurora, Fedora Atomic)
- `just` command available (pre-installed on Universal Blue images)
- `podman` available

**Workflow**:

```bash
# 1. Build container image locally
just build

# 2. Build and test VM image
just build-qcow2

# 3. Run VM in browser-based viewer
just run-vm-qcow2

# 4. Build ISO image
just build-iso
```

**Common Just Commands**:
- `just build [image-name] [tag]` - Build container image
- `just build-qcow2` - Build QCOW2 VM disk
- `just build-iso` - Build ISO installer
- `just run-vm-qcow2` - Launch VM in web interface
- `just clean` - Remove build artifacts
- `just lint` - Check shell script syntax
- `just format` - Format shell scripts

**Decision Logic**:
- Always test locally before pushing to main branch
- Use `just build` for quick iteration on 10-build.sh changes
- Use `just build-qcow2` to test full boot process
- Use `just run-vm-qcow2` to test in actual VM environment

### 11. GITHUB ACTIONS WORKFLOWS & RELEASE MANAGEMENT

**When**: User asks about CI/CD, automated builds, publishing, or releases.

**THIS TEMPLATE USES A TESTING BRANCH + RELEASE PLEASE WORKFLOW:**

#### Three GitHub Actions Workflows:

**1. build-testing.yml** - Testing branch builds
- **Triggers**: Push to `testing` branch (excludes README changes)
- **Purpose**: Builds and tests development changes
- **Output**: `ghcr.io/username/repo-name:testing` and `ghcr.io/username/repo-name:testing.YYYYMMDD`
- **When to use**: All development work happens on testing branch

**2. release-please.yml** - Release automation
- **Triggers**: Push to `testing` branch
- **Purpose**: 
  - Tracks all changes using Conventional Commits
  - Creates/updates release PR with changelog
  - Auto-merges testing → main when release PR merged
  - Creates GitHub Release with version tag
- **Requires**: GitHub Actions permission to create PRs (Settings → Actions → General)
- **When to use**: Automatically runs - no manual intervention needed

**3. build.yml** - Production builds
- **Triggers**: Push to `main` branch, PRs to main, schedule (daily 10:05 AM UTC), manual
- **Purpose**: Builds production container images
- **Output**: `ghcr.io/username/repo-name:latest` and `ghcr.io/username/repo-name:latest.YYYYMMDD`
- **When to use**: Automatically runs when release PR is merged

#### Release Workflow Process:

**DEVELOPMENT (testing branch):**
```bash
# 1. Make changes on testing branch
git checkout testing
git commit -m "feat: add new feature"    # Use Conventional Commits!
git push origin testing

# 2. Automatic actions:
#    - build-testing.yml builds :testing image
#    - release-please.yml creates/updates release PR
#    - All commits tracked in changelog
```

**RELEASE (via Release Please PR):**
```bash
# 3. When ready to release:
#    - Review the Release Please PR on GitHub
#    - Check generated CHANGELOG
#    - Merge the release PR

# 4. Automatic actions on merge:
#    - Creates GitHub Release with version tag
#    - Auto-merges testing → main (no-ff merge)
#    - build.yml builds :latest production image
```

#### Conventional Commits (REQUIRED):

Release Please uses commit messages to determine version bumps:

- `feat:` = Minor version bump (0.X.0) - New feature
- `fix:` = Patch version bump (0.0.X) - Bug fix
- `feat!:` or `BREAKING CHANGE:` = Major version bump (X.0.0)
- `docs:`, `chore:`, `style:`, `refactor:`, `test:` = No version bump (still in changelog)

**Examples:**
```bash
git commit -m "feat: add cosmic desktop support"
git commit -m "fix: correct systemd service enablement"
git commit -m "feat!: migrate to new build system"
git commit -m "docs: update installation instructions"
```

#### Image Tags Generated:

**Testing branch pushes:**
- `ghcr.io/username/repo:testing` (always latest testing)
- `ghcr.io/username/repo:testing.20250129` (datestamped)

**Main branch (releases):**
- `ghcr.io/username/repo:latest` (always latest release)
- `ghcr.io/username/repo:latest.20250129` (datestamped)
- `ghcr.io/username/repo:20250129` (date-only)

#### Additional Workflows:

**4. renovate.json** - Dependency tracking
- **Purpose**: Monitors base image updates (e.g., `ghcr.io/ublue-os/bluefin:stable`)
- **Action**: Creates PR when base image digest changes
- **Triggers**: Build on base image updates
- **When to use**: Automatically runs daily

**5. ghcr-pruner.yml** - Image cleanup
- **Triggers**: Weekly (Mondays)
- **Purpose**: Deletes images older than 90 days from GHCR
- **Note**: **CRITICAL** - Update `IMAGE_NAME` in workflow to match your repo
- **When to use**: Automatically runs - saves storage costs

**Note on Disk Images**:
- This template no longer includes automated ISO/disk image building workflows
- ISO and disk images are built locally using `just build-iso` and `just build-qcow2`
- For distribution, users can manually build and upload using the rclone configurations in the `/iso/rclone` directory

**Image Signing**:
- Signing is **OPTIONAL** and **disabled by default** in all workflows
- Both `build.yml` and `build-testing.yml` have cosign steps commented out
- First builds will succeed without signing keys
- Enable signing for production by uncommenting cosign steps and adding `SIGNING_SECRET`
- See "Optional: Enable Image Signing" section in README

#### Decision Logic:

**For Development:**
- Work on `testing` branch exclusively
- Push often - each push builds `:testing` image
- Release Please tracks all commits

**For Releases:**
- Review and merge Release Please PR
- Automatic merge to main creates `:latest` image
- GitHub Release created with version tag

**For Hotfixes to Production:**
- Make fix on testing branch with `fix:` commit
- Merge Release Please PR immediately
- Auto-deploys to main as patch version

**DO NOT:**
- Push directly to main (unless hotfix emergency)
- Merge PRs from testing to main manually
- Skip Conventional Commit format
- Modify workflow files without testing

**Documentation:**
- `RELEASE_WORKFLOW.md` - Complete workflow guide
- `.github/SETUP_CHECKLIST.md` - Setup instructions
- Release Please docs: https://github.com/googleapis/release-please
- Conventional Commits: https://www.conventionalcommits.org/

### 12. RCLONE CONFIGURATION FOR MANUAL UPLOADS

**When**: User wants to upload locally-built ISOs/disk images to cloud storage.

**Where**: `/iso/rclone` directory contains example configurations

**Available Providers**:
- `cloudflare-r2.conf` - Cloudflare R2 (S3-compatible, zero egress fees)
- `aws-s3.conf` - AWS S3 (highly reliable, standard pricing)
- `backblaze-b2.conf` - Backblaze B2 (affordable, low egress fees)
- `sftp.conf` - SFTP upload to any server
- `scp.conf` - SCP upload to any server

**How to Use**:
1. Choose a provider configuration from `/iso/rclone` directory
2. Follow the setup instructions in the config file
3. Set up the required secrets/credentials
4. Build ISO locally: `just build-iso`
5. Use rclone to upload: `rclone copy <local-path> <remote>:<bucket>`

**Decision Logic**:
- Cloudflare R2 for frequent downloads (zero egress)
- AWS S3 for maximum reliability
- Backblaze B2 for cost-effective storage
- SFTP/SCP for your own server infrastructure

### 13. SECURITY: COSIGN SIGNING

**When**: Setting up new repository from template.

**Critical**: This is required for the build to succeed.

**One-time Setup**:
```bash
# In repository directory
COSIGN_PASSWORD="" cosign generate-key-pair
```

This creates:
- `cosign.key` - Private key (NEVER commit this)
- `cosign.pub` - Public key (commit this)

**Add to GitHub**:
1. Go to repo Settings → Secrets and Variables → Actions
2. Create new secret: `SIGNING_SECRET`
3. Paste entire contents of `cosign.key`

**Verify .gitignore**:
```gitignore
cosign.key  # Must be present
```

**Decision Logic**:
- This step is **OPTIONAL** but **strongly recommended for production**
- Signing is **disabled by default** in workflows (commented out)
- Without signing, GitHub Actions will still succeed and build images
- Public key goes in repo, private key goes in GitHub secrets
- Never password-protect the key (breaks automation)
- Enable signing by uncommenting cosign steps in workflows and adding `SIGNING_SECRET`

## Common User Request Patterns

### "I want to add X package"
→ Edit `build/10-build.sh`, add `dnf5 install -y package-name`

### "I want to switch to Bluefin/Bazzite/Aurora"
→ Edit `Containerfile` FROM line with appropriate base image

### "How do I test this locally?"
→ Use `just build` then `just build-qcow2` then `just run-vm-qcow2`

### "I want to create an ISO"
→ Edit `iso/iso.toml` to update bootc switch URL to your repository, then run `just build-iso` locally for testing

### "How do I deploy this to my machine?"
→ For testing: `sudo bootc switch ghcr.io/username/repo:testing` then reboot
→ For production: `sudo bootc switch ghcr.io/username/repo:latest` then reboot

### "I want to enable/disable a systemd service"
→ Edit `build/10-build.sh`, add `systemctl enable/mask service-name`

### "I need to install from a COPR"
→ Edit `build/10-build.sh`, add COPR enable → install → CRITICAL: COPR disable

### "I want to add ujust commands for users"
→ Create `.just` files in `custom/ujust/` directory with commands like system config, Brewfile shortcuts. **NEVER** install packages via dnf5 in ujust - use Brewfile shortcuts instead

### "How do I make a release?"
→ Push to testing branch with conventional commits, Review and merge Release Please PR

### "How do I test changes before production?"
→ Push to testing branch, test `:testing` image, when ready merge Release Please PR

### "I want to make a quick fix to production"
→ Make fix on testing branch with `fix:` commit, merge Release Please PR for patch release

### "The build is failing"
→ Check: 1) base image syntax correct, 2) package names correct, 3) COPRs disabled after use, 4) YAML syntax valid

### "I want faster builds"
→ Rechunker is already enabled in both build.yml and build-testing.yml workflows

### "How do I update when the base image changes?"
→ Renovate automatically detects changes and creates PR, merge PR to update

## Critical Rules

1. **NEVER** commit `cosign.key` to the repository
2. **ALWAYS** disable COPRs after use in build scripts
3. **ALWAYS** use `dnf5` (not dnf or yum) in build scripts
4. **ALWAYS** use `-y` flag for non-interactive package installs
5. **ALWAYS** set `COSIGN_PASSWORD=""` when generating keys
6. **ALWAYS** update the bootc switch URL in iso.toml to match user's repo
7. **ALWAYS** test base image syntax (common error: typos in image URLs)
8. **NEVER** add passwords or secrets to build scripts or Containerfile
9. **ALWAYS** keep build script modifications minimal for faster builds
10. **ALWAYS** run `bootc container lint` in Containerfile (catches many errors)
11. **NEVER** install packages via dnf5 in ujust files - only use Brewfile shortcuts or Flatpak for runtime software installation
12. **ALWAYS** work on testing branch for development
13. **ALWAYS** use Conventional Commits (feat:, fix:, etc.) for commit messages
14. **ALWAYS** let Release Please handle merges to main
15. **NEVER** push directly to main branch (except emergency hotfixes)

## Image Tag Patterns in Workflow

The GitHub Actions automatically generates these tags:

**Testing Branch (testing):**
- `testing` - Always points to most recent testing build
- `testing.YYYYMMDD` - Datestamped testing (e.g., `testing.20250129`)

**Main Branch (production releases):**
- `latest` - Always points to most recent release
- `latest.YYYYMMDD` - Datestamped latest (e.g., `latest.20250129`)
- `YYYYMMDD` - Date-only tag (e.g., `20250129`)

**Pull Requests (feature branches to testing):**
- `sha-<short>` - Git SHA tags
- `pr-<number>` - Pull request tags

**Version Tags (from Release Please):**
- `v1.0.0`, `v1.0.1`, etc. - Semantic version tags from releases

**Usage Recommendations:**
- Development/Testing: Use `:testing` tag
- Production: Use `:latest` tag or specific version tag (`:v1.0.0`)
- Pinned deployments: Use datestamped tags for reproducibility

## Error Troubleshooting Decision Tree

**Build fails with "permission denied"**:
→ Check if signing is enabled - if so, verify SIGNING_SECRET is set
→ If signing disabled (default), check file permissions in build scripts

**Build fails with "package not found"**:
→ Check package name spelling, verify on RPMfusion, check if COPR needed

**Build fails with "base image not found"**:
→ Check FROM line syntax, verify image exists at registry

**Build fails with workflow permission error**:
→ Enable "Allow GitHub Actions to create and approve pull requests" in Settings → Actions

**Release Please not creating PRs**:
→ Check GitHub Actions permissions (above)
→ Verify you're pushing to testing branch
→ Ensure commits use Conventional Commit format (feat:, fix:, etc.)

**Changes not appearing in production**:
→ Check you pushed to testing branch (not main)
→ Verify Release Please PR was merged
→ Check build.yml workflow completed successfully

**ISO boots but doesn't have customizations**:
→ Verify bootc switch URL in iso.toml points to correct ghcr.io URL

**systemd service not enabled after install**:
→ Add `systemctl enable service.name` to build script

**COPR packages missing after boot**:
→ COPR wasn't disabled - repos don't transfer to final image

**Local just build fails "permission denied"**:
→ Need to run on bootc-based system or install podman

## File Modification Priority

When user requests customization, modify in this order:

1. **build/10-build.sh** - 50% of requests (build-time packages, services, configs)
2. **custom/brew/** - 20% (runtime package installation via Brewfiles)
3. **custom/ujust/** - 15% (user-facing commands and shortcuts)
4. **custom/flatpaks/** - 5% (GUI application preinstall)
5. **Containerfile** - 5% (base image, /opt immutability)
6. **Justfile** - 2% (image name, build parameters)
7. **iso/*.toml** - 2% (ISO/disk image customization)
8. **build.yml** - 1% (metadata, workflow triggers)

## Performance Optimization Notes

- Each RUN layer in Containerfile creates overhead
- Combine commands in 10-build.sh rather than multiple RUN directives
- Use build caches (already configured in Containerfile)
- Enable rechunk for better layer distribution
- Minimize installed packages for faster builds and smaller images
- Use `--pull=newer` only when necessary (already in workflow)

## Working with Multiple Architectures

Currently templates default to amd64 (x86_64). For arm64:

**For Local Builds**:
- Local `just` commands support the platform you're running on
- Cross-platform builds require additional setup

**Base Image Considerations**:
- Verify base image has arm64 variant
- Most UBlue images support both architectures
- Add `-arm64` suffix where needed: `ghcr.io/ublue-os/bazzite-arm64:stable`

## This is a Living Template

- Universal Blue project actively maintains this template
- Check https://github.com/ublue-os/image-template for updates
- Community examples in README.md show real-world implementations
- Universal Blue forums and Discord for advanced questions

## Quick Decision Matrix

| User Need | File(s) to Edit | Test Command | Branch |
|-----------|----------------|--------------|--------|
| Add build-time packages | build/10-build.sh | `just build` | testing |
| Add runtime packages | custom/brew/*.Brewfile | `just build` + `ujust install-*` | testing |
| Add user commands | custom/ujust/*.just | `ujust` | testing |
| Add GUI apps (first boot) | custom/flatpaks/*.preinstall | Boot test | testing |
| Change base image | Containerfile | `just build` | testing |
| Rename image | Justfile, Containerfile | `just build` | testing |
| Customize ISO | iso/iso.toml | `just build-iso` | testing |
| Change VM size | iso/disk.toml | `just build-qcow2` | testing |
| Enable services | build/10-build.sh | `just build-qcow2` | testing |
| Add metadata | .github/workflows/build.yml | Push to testing | testing |
| Upload ISO/images | iso/rclone/* + manual | Local + rclone | N/A |
| Make a release | N/A | Merge Release Please PR | testing→main |
| Test before production | N/A | `bootc switch :testing` | testing |

## Branch Strategy Summary

**Default Branch Strategy:**
- `testing` - All development and feature work
- `main` - Production releases only (via Release Please)

**Workflow:**
1. Clone repo, create testing branch
2. Make all changes on testing branch
3. Push to testing → builds `:testing` image
4. Test with `:testing` image
5. Release Please creates PR with changelog
6. Merge PR → auto-merge to main → builds `:latest`

**Never:**
- Push directly to main
- Manually merge testing to main
- Skip Conventional Commits

---

**Last Updated**: 2025-01-29
**Template Version**: Universal Blue bootc-image-builder compatible with Release Please
**Maintainer**: Universal Blue Project
