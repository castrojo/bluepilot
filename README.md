# finpilot

A template for building custom bootc operating system images based on [Universal Blue](https://universal-blue.org/).

## ✨ What's Included

This template provides everything you need to create a custom Linux operating system:

### 🏗️ **Build System**
- **Automated Builds**: GitHub Actions builds your image on every commit
- **Signed Images**: Automatic signing with cosign for security
- **Version Tracking**: Renovate automatically updates your base image
- **SBOM Generation**: Software Bill of Materials for supply chain security
- **Image Validation**: Automatic linting with `bootc container lint`

### 🍺 **Homebrew Integration** ([see custom/brew/README.md](custom/brew/README.md))
- Pre-configured Brewfiles for easy package installation
- Includes curated collections: development tools, fonts, CLI utilities
- Users install packages at runtime with `brew bundle`

### 📦 **Flatpak Support** ([see custom/flatpaks/README.md](custom/flatpaks/README.md))
- Pre-configured list of GUI applications
- Automatically installed on first boot after user setup
- Includes browsers, productivity apps, and GNOME utilities

### 🎮 **Handheld Daemon (HHD)**
- Optional support for gaming handhelds (Steam Deck, ROG Ally, Legion Go)
- Provides controller mappings and performance tweaks
- Enable by uncommenting in build scripts

### ⚡ **ujust Commands** ([see custom/ujust/README.md](custom/ujust/README.md))
- User-friendly command shortcuts via `ujust`
- Pre-configured examples for app installation and system maintenance
- Easily customizable for your specific needs

### 🔧 **Build Scripts**
- Modular numbered scripts (10-, 20-, 30-) run in order
- Example scripts included:
  - Third-party repositories (Chrome, 1Password)
  - Desktop environment replacement (COSMIC)
- Helper functions for safe COPR usage

## 🚀 Quick Start

### 1. Create Your Repository

Click "Use this template" → Create a new repository

### 2. Rename the Project

**IMPORTANT**: Change `finpilot` to your repository name in 5 files:

1. `Containerfile` (line 9): `# Name: your-repo-name`
2. `Justfile` (line 1): `export image_name := "your-repo-name"`
3. `README.md` (line 1): `# your-repo-name`
4. `artifacthub-repo.yml` (line 5): `repositoryID: your-repo-name`
5. `custom/ujust/README.md` (~line 175): `localhost/your-repo-name:latest`

### 3. Set Up Signing (Required)

Generate a signing key for your images:

```bash
cosign generate-key-pair
```

Add the **private key** (`cosign.key` contents) to GitHub:
- Go to: Settings → Secrets and variables → Actions
- Create secret: `SIGNING_SECRET`
- Paste the entire contents of `cosign.key`

**⚠️ Never commit `cosign.key` to the repository!**

### 4. Enable GitHub Actions

- Go to the "Actions" tab in your repository
- Click "I understand my workflows, go ahead and enable them"

### 5. Make It Yours

**Choose your base image** in `Containerfile` (line 23):
```dockerfile
FROM ghcr.io/ublue-os/bluefin:stable
```

Options:
- `bluefin:stable` - Developer-focused with GNOME
- `bazzite:stable` - Gaming-optimized 
- `aurora:stable` - KDE Plasma desktop

**Add your packages** in `build/10-build.sh`:
```bash
dnf5 install -y package-name
```

**Customize your apps**:
- Add Brewfiles in `custom/brew/` ([guide](custom/brew/README.md))
- Add Flatpaks in `custom/flatpaks/` ([guide](custom/flatpaks/README.md))
- Add ujust commands in `custom/ujust/` ([guide](custom/ujust/README.md))

### 6. Build and Deploy

**Commit and push** - GitHub Actions will build your image automatically.

**Switch to your image**:
```bash
sudo bootc switch ghcr.io/your-username/your-repo-name:latest
sudo systemctl reboot
```

## 📖 Detailed Guides

- **[Homebrew/Brewfiles](custom/brew/README.md)** - Runtime package management
- **[Flatpak Preinstall](custom/flatpaks/README.md)** - GUI application setup
- **[ujust Commands](custom/ujust/README.md)** - User convenience commands
- **[Build Scripts](build/README.md)** - Build-time customization

## 🧪 Local Testing

Test your changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## 🤝 Community

- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc Discussion](https://github.com/bootc-dev/bootc/discussions)

## 📚 Learn More

- [Universal Blue Documentation](https://universal-blue.org/)
- [bootc Documentation](https://containers.github.io/bootc/)
- [Video Tutorial by TesterTech](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## 🔐 Security

This template provides:
- **Image signing** with cosign (cryptographic verification)
- **SBOM generation** (Software Bill of Materials)
- **Provenance attestation** (build metadata)
- **Automated security updates** via Renovate

Your images are signed and can be verified with:
```bash
cosign verify --key cosign.pub ghcr.io/your-username/your-repo-name:latest
```

---

**Template maintained by**: [Universal Blue Project](https://universal-blue.org/)
