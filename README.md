# finpilot

A template for building custom bootc operating system images based on the lessons from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io). It is designed and documented for use with Copilot to ease maintenance.

## Get Started

1. Click the green button use this as a template and create a new repository
2. Select your owner, pick a repo name for your OS, and a description
3. In the "Jumpstart your project with Copilot (optional)" add this, modify to your liking):

```
Make a new bootc custom operating system using this template named after the repository name. Replace the README with onboarding instructions that lists the tasks that I must accomplish to finish the task.
```

## What's Included

### Build System
- Automated builds via GitHub Actions on every commit you make
- Signed images with cosign for security
- Version tracking with Renovate for automatic base image updates, builds only when the base image upstream is updated
- SBOM generation for supply chain security
- Image validation with `bootc container lint`

### Homebrew Integration
- Pre-configured Brewfiles for easy package installation and customization
- Includes curated collections: development tools, fonts, CLI utilities. Go nuts.
- Users install packages at runtime with `brew bundle`, aliased to premade `ujust commands`
- See [custom/brew/README.md](custom/brew/README.md) for details

### Flatpak Support
- Ship your favorite flatpaks
- Automatically installed on first boot after user setup
- See [custom/flatpaks/README.md](custom/flatpaks/README.md) for details

### Rechunker
- Optimizes container image layer distribution for faster downloads
- Automatically enabled in GitHub Actions workflow
- Based on [hhd-dev/rechunk](https://github.com/hhd-dev/rechunk)
- No manual configuration required

### ujust Commands
- User-friendly command shortcuts via `ujust`
- Pre-configured examples for app installation and system maintenance for you to customize
- See [custom/ujust/README.md](custom/ujust/README.md) for details

### Build Scripts
- Modular numbered scripts (10-, 20-, 30-) run in order
- Example scripts included for third-party repositories and desktop replacement
- Helper functions for safe COPR usage
- See [build/README.md](build/README.md) for details

## Quick Start

### 1. Create Your Repository

Click "Use this template" to create a new repository from this template.

### 2. Rename the Project

Important: Change `finpilot` to your repository name in these 5 files:

1. `Containerfile` (line 9): `# Name: your-repo-name`
2. `Justfile` (line 1): `export image_name := "your-repo-name"`
3. `README.md` (line 1): `# your-repo-name`
4. `artifacthub-repo.yml` (line 5): `repositoryID: your-repo-name`
5. `custom/ujust/README.md` (~line 175): `localhost/your-repo-name:latest`

### 3. Set Up Signing

Generate a signing key for your images:

```bash
cosign generate-key-pair
```

This creates two files:
- `cosign.key` (private key) - Keep this secret
- `cosign.pub` (public key) - Commit this to your repository

Add the private key to GitHub Secrets:
1. Copy the entire contents of `cosign.key`
2. Go to your repository on GitHub
3. Navigate to Settings → Secrets and variables → Actions ([GitHub docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository))
4. Click "New repository secret"
5. Name: `SIGNING_SECRET`
6. Value: Paste the entire contents of `cosign.key`
7. Click "Add secret"

Replace the contents of `cosign.pub` with your public key:
1. Open `cosign.pub` in your repository
2. Replace the placeholder with your actual public key
3. Commit and push the change

Important: Never commit `cosign.key` to the repository. It's already in `.gitignore`.

### 4. Enable GitHub Actions

- Go to the "Actions" tab in your repository
- Click "I understand my workflows, go ahead and enable them"

### 5. Customize Your Image

Choose your base image in `Containerfile` (line 23):
```dockerfile
FROM ghcr.io/ublue-os/bluefin:stable
```

Options:
- `bluefin:stable` - Developer-focused with GNOME
- `bazzite:stable` - Gaming-optimized 
- `aurora:stable` - KDE Plasma desktop

Add your packages in `build/10-build.sh`:
```bash
dnf5 install -y package-name
```

Customize your apps:
- Add Brewfiles in `custom/brew/` ([guide](custom/brew/README.md))
- Add Flatpaks in `custom/flatpaks/` ([guide](custom/flatpaks/README.md))
- Add ujust commands in `custom/ujust/` ([guide](custom/ujust/README.md))

### 6. Build and Deploy

Commit and push your changes. GitHub Actions will build your image automatically.

Switch to your image:
```bash
sudo bootc switch ghcr.io/your-username/your-repo-name:latest
sudo systemctl reboot
```

## Detailed Guides

- [Homebrew/Brewfiles](custom/brew/README.md) - Runtime package management
- [Flatpak Preinstall](custom/flatpaks/README.md) - GUI application setup
- [ujust Commands](custom/ujust/README.md) - User convenience commands
- [Build Scripts](build/README.md) - Build-time customization

## Local Testing

Test your changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Community

- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc Discussion](https://github.com/bootc-dev/bootc/discussions)

## Learn More

- [Universal Blue Documentation](https://universal-blue.org/)
- [bootc Documentation](https://containers.github.io/bootc/)
- [Video Tutorial by TesterTech](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## Security

This template provides:
- Image signing with cosign for cryptographic verification
- SBOM generation (Software Bill of Materials)
- Provenance attestation with build metadata
- Automated security updates via Renovate

Your images are signed and can be verified with:
```bash
cosign verify --key cosign.pub ghcr.io/your-username/your-repo-name:latest
```

---

Template maintained by [Universal Blue Project](https://universal-blue.org/)
