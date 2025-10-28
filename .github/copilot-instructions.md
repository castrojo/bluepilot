# Copilot Instructions for Customizing bootc Image Template

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
│   └── build.sh              # Script for installing packages and system modifications
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
│   └── iso.toml             # ISO configuration for Anaconda installer (local testing)
├── rclone/
│   ├── README.md            # rclone configuration guide
│   ├── cloudflare-r2.conf   # Cloudflare R2 example config
│   ├── aws-s3.conf          # AWS S3 example config
│   ├── backblaze-b2.conf    # Backblaze B2 example config
│   ├── sftp.conf            # SFTP upload example config
│   └── scp.conf             # SCP upload example config
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

**Where**: Edit `build/build.sh`

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
- Build-time packages go in `build/build.sh`
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
- Build-time operations go in `build/build.sh`
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

**When**: User needs advanced customization beyond build.sh.

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
    /ctx/build.sh && \
    /ctx/post-install.sh
```

Then add `build_files/post-install.sh`.

**C. Copying Custom Files**:
```dockerfile
COPY --from=ctx /custom-configs /etc/
```

Files in `build_files/` are available at `/ctx/` during build.

**Decision Logic**:
- Use build.sh for 95% of customizations
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
- Use `just build` for quick iteration on build.sh changes
- Use `just build-qcow2` to test full boot process
- Use `just run-vm-qcow2` to test in actual VM environment

### 11. GITHUB ACTIONS WORKFLOWS

**When**: User asks about CI/CD, automated builds, or publishing.

**Single Workflow**:

**build.yml** - Main image builder
- **Triggers**: Push to main, PRs, schedule (daily at 10:05 AM UTC), manual
- **Purpose**: Builds container image and publishes to GHCR
- **Output**: `ghcr.io/username/repo-name:latest`
- **Signing**: Uses cosign with `SIGNING_SECRET` repository secret. The user must know that they need to set this up.

**Note on Disk Images**:
- This template no longer includes automated ISO/disk image building workflows
- ISO and disk images are built locally using `just build-iso` and `just build-qcow2`
- For distribution, users can manually build and upload using the rclone configurations in the `/rclone` directory

**Decision Logic**:
- build.yml runs automatically - no changes needed for typical use
- For faster builds, consider enabling rechunk (commented in build.yml)
- Disk/ISO images are for local testing and manual distribution only

### 12. RCLONE CONFIGURATION FOR MANUAL UPLOADS

**When**: User wants to upload locally-built ISOs/disk images to cloud storage.

**Where**: `/rclone` directory contains example configurations

**Available Providers**:
- `cloudflare-r2.conf` - Cloudflare R2 (S3-compatible, zero egress fees)
- `aws-s3.conf` - AWS S3 (highly reliable, standard pricing)
- `backblaze-b2.conf` - Backblaze B2 (affordable, low egress fees)
- `sftp.conf` - SFTP upload to any server
- `scp.conf` - SCP upload to any server

**How to Use**:
1. Choose a provider configuration from `/rclone` directory
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
- This step is REQUIRED, not optional
- Without signing secret, GitHub Actions will fail
- Public key goes in repo, private key goes in GitHub secrets
- Never password-protect the key (breaks automation)

## Common User Request Patterns

### "I want to add X package"
→ Edit `build/build.sh`, add `dnf5 install -y package-name`

### "I want to switch to Bluefin/Bazzite/Aurora"
→ Edit `Containerfile` FROM line with appropriate base image

### "How do I test this locally?"
→ Use `just build` then `just build-qcow2` then `just run-vm-qcow2`

### "I want to create an ISO"
→ Edit `iso/iso.toml` to update bootc switch URL to your repository, then run `just build-iso` locally for testing

### "How do I deploy this to my machine?"
→ After GitHub Actions builds successfully: `sudo bootc switch ghcr.io/username/repo:latest` then reboot

### "I want to enable/disable a systemd service"
→ Edit `build/build.sh`, add `systemctl enable/mask service-name`

### "I need to install from a COPR"
→ Edit `build/build.sh`, add COPR enable → install → CRITICAL: COPR disable

### "I want to add ujust commands for users"
→ Create `.just` files in `custom/ujust/` directory with commands like system config, Brewfile shortcuts. **NEVER** install packages via dnf5 in ujust - use Brewfile shortcuts instead

### "The build is failing"
→ Check: 1) SIGNING_SECRET exists, 2) base image syntax correct, 3) package names correct, 4) COPRs disabled after use

### "I want faster builds"
→ Enable rechunk in build.yml (uncomment lines 106-115 and 118-122)

## Critical Rules

1. **NEVER** commit `cosign.key` to the repository
2. **ALWAYS** disable COPRs after use in build.sh
3. **ALWAYS** use `dnf5` (not dnf or yum) in build.sh
4. **ALWAYS** use `-y` flag for non-interactive package installs
5. **ALWAYS** set `COSIGN_PASSWORD=""` when generating keys
6. **ALWAYS** update the bootc switch URL in iso.toml to match user's repo
7. **ALWAYS** test base image syntax (common error: typos in image URLs)
8. **NEVER** add passwords or secrets to build.sh or Containerfile
9. **ALWAYS** keep build.sh modifications minimal for faster builds
10. **ALWAYS** run `bootc container lint` is in Containerfile (catches many errors)
11. **NEVER** install packages via dnf5 in ujust files - only use Brewfile shortcuts or Flatpak for runtime software installation

## Image Tag Patterns in Workflow

The GitHub Actions automatically generates these tags:
- `latest` - Always points to most recent build
- `latest.YYYYMMDD` - Datestamped latest (e.g., `latest.20250128`)
- `YYYYMMDD` - Date-only tag (e.g., `20250128`)
- `sha-<short>` - Git SHA tags (PR only)
- `pr-<number>` - Pull request tags

Users should reference `latest` tag unless they need pinned versions.

## Error Troubleshooting Decision Tree

**Build fails with "permission denied"**:
→ Check if SIGNING_SECRET is set in GitHub repo secrets

**Build fails with "package not found"**:
→ Check package name spelling, verify on RPMfusion, check if COPR needed

**Build fails with "base image not found"**:
→ Check FROM line syntax, verify image exists at registry

**ISO boots but doesn't have customizations**:
→ Verify bootc switch URL in iso.toml points to correct ghcr.io URL

**systemd service not enabled after install**:
→ Add `systemctl enable service.name` to build.sh

**COPR packages missing after boot**:
→ COPR wasn't disabled - repos don't transfer to final image

**Local just build fails "permission denied"**:
→ Need to run on bootc-based system or install podman

## File Modification Priority

When user requests customization, modify in this order:

1. **build/build.sh** - 50% of requests (build-time packages, services, configs)
2. **custom/brew/** - 20% (runtime package installation via Brewfiles)
3. **custom/ujust/** - 15% (user-facing commands and shortcuts)
4. **custom/flatpaks/** - 5% (GUI application preinstall)
5. **Containerfile** - 5% (base image, /opt immutability)
6. **Justfile** - 2% (image name, build parameters)
7. **iso/*.toml** - 2% (ISO/disk image customization)
8. **build.yml** - 1% (metadata, workflow triggers)

## Performance Optimization Notes

- Each RUN layer in Containerfile creates overhead
- Combine commands in build.sh rather than multiple RUN directives
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

| User Need | File(s) to Edit | Test Command |
|-----------|----------------|--------------|
| Add build-time packages | build/build.sh | `just build` |
| Add runtime packages | custom/brew/*.Brewfile | `just build` + `ujust install-*` |
| Add user commands | custom/ujust/*.just | `ujust` |
| Add GUI apps (first boot) | custom/flatpaks/*.preinstall | Boot test |
| Change base | Containerfile | `just build` |
| Rename image | Justfile | `just build` |
| Customize ISO | iso/iso.toml | `just build-iso` |
| Change VM size | iso/disk.toml | `just build-qcow2` |
| Enable services | build/build.sh | `just build-qcow2` |
| Add metadata | build.yml | Push to GitHub |
| Upload images | rclone configs + manual upload | Local + rclone |

---

**Last Updated**: 2025-10-28  
**Template Version**: Universal Blue bootc-image-builder compatible  
**Maintainer**: Universal Blue Project
