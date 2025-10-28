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
├── build_files/
│   └── build.sh              # Script for installing packages and system modifications
├── disk_config/
│   ├── disk.toml             # Configuration for QCOW2/RAW disk images (local testing)
│   └── iso.toml              # ISO configuration for Anaconda installer (local testing)
├── rclone/
│   ├── README.md             # rclone configuration guide
│   ├── cloudflare-r2.conf    # Cloudflare R2 example config
│   ├── aws-s3.conf           # AWS S3 example config
│   ├── backblaze-b2.conf     # Backblaze B2 example config
│   ├── sftp.conf             # SFTP upload example config
│   └── scp.conf              # SCP upload example config
└── .github/workflows/
    └── build.yml             # CI/CD for building and publishing container images
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

**Where**: Edit `build_files/build.sh`

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

**Where**: Edit `Justfile` (line 1)

**How**: Change the `image_name` variable:
```just
export image_name := env("IMAGE_NAME", "my-custom-image")
```

**Additional Changes Required**:
- The GitHub Actions workflow automatically uses repository name
- If user wants different CI/CD name, edit `.github/workflows/build.yml` env var `IMAGE_NAME`
- No need to change unless they want image name different from repo name

### 4. CONFIGURING DISK IMAGE BUILDS (LOCAL TESTING ONLY)

**When**: User wants to customize ISO or VM disk images for local testing.

**Where**: Edit files in `disk_config/` directory

**Important**: This template no longer includes automated ISO/disk building workflows. 
Disk images are built locally using the `just` commands for testing purposes only.

**Decision Matrix**:

| Use Case | File to Edit | Just Command |
|----------|--------------|--------------|
| VM images (QCOW2, RAW) | `disk_config/disk.toml` | `just build-qcow2` |
| ISO installer | `disk_config/iso.toml` | `just build-iso` |

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

### 5. CUSTOMIZING BUILD METADATA

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

### 6. ADVANCED CONTAINERFILE MODIFICATIONS

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

### 7. LOCAL TESTING WORKFLOW

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

### 8. GITHUB ACTIONS WORKFLOWS

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

### 9. RCLONE CONFIGURATION FOR MANUAL UPLOADS

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

### 10. SECURITY: COSIGN SIGNING

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
→ Edit `build_files/build.sh`, add `dnf5 install -y package-name`

### "I want to switch to Bluefin/Bazzite/Aurora"
→ Edit `Containerfile` FROM line with appropriate base image

### "How do I test this locally?"
→ Use `just build` then `just build-qcow2` then `just run-vm-qcow2`

### "I want to create an ISO"
→ Edit `disk_config/iso.toml` to update bootc switch URL to your repository, then run `just build-iso` locally for testing

### "How do I deploy this to my machine?"
→ After GitHub Actions builds successfully: `sudo bootc switch ghcr.io/username/repo:latest` then reboot

### "I want to enable/disable a systemd service"
→ Edit `build_files/build.sh`, add `systemctl enable/mask service-name`

### "I need to install from a COPR"
→ Edit `build_files/build.sh`, add COPR enable → install → CRITICAL: COPR disable

### "The build is failing"
→ Check: 1) SIGNING_SECRET exists, 2) base image syntax correct, 3) package names correct, 4) COPRs disabled after use

### "I want faster builds"
→ Enable rechunk in build.yml (uncomment lines 106-115 and 118-122)

## Critical Rules

1. **NEVER** commit `cosign.key` to the repository
2. **ALWAYS** disable COPRs after use in build.sh
3. **ALWAYS** use `dnf5` (not dnf or yum)
4. **ALWAYS** use `-y` flag for non-interactive package installs
5. **ALWAYS** set `COSIGN_PASSWORD=""` when generating keys
6. **ALWAYS** update the bootc switch URL in iso.toml to match user's repo
7. **ALWAYS** test base image syntax (common error: typos in image URLs)
8. **NEVER** add passwords or secrets to build.sh or Containerfile
9. **ALWAYS** keep build.sh modifications minimal for faster builds
10. **ALWAYS** run `bootc container lint` is in Containerfile (catches many errors)

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

1. **build.sh** - 80% of requests (packages, services, configs)
2. **Containerfile** - 10% (base image, /opt immutability)
3. **Justfile** - 5% (image name, build parameters)
4. **disk_config/*.toml** - 3% (ISO/disk image customization)
5. **build.yml** - 2% (metadata, workflow triggers)

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
| Add packages | build.sh | `just build` |
| Change base | Containerfile | `just build` |
| Rename image | Justfile | `just build` |
| Customize ISO | disk_config/iso.toml | `just build-iso` |
| Change VM size | disk_config/disk.toml | `just build-qcow2` |
| Enable services | build.sh | `just build-qcow2` |
| Add metadata | build.yml | Push to GitHub |
| Upload images | rclone configs + manual upload | Local + rclone |

---

**Last Updated**: 2025-10-28  
**Template Version**: Universal Blue bootc-image-builder compatible  
**Maintainer**: Universal Blue Project
