# finpilot

A template for building custom bootc operating system images based on the lessons from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io). It is designed to be used manually, but is optimized to be bootstraped by GitHub Copilot. After set up you'll have your own custom Linux. 

> Be the one who moves, not the one who is moved.

## Get Started

1. Click the green button use this as a template and create a new repository
2. Select your owner, pick a repo name for your OS, and a description
3. In the "Jumpstart your project with Copilot (optional)" add this, modify to your liking):

```
Use @castrojo/finpilot as a template, name the OS the repository name. Ensure the entire operating system is bootstrapped. Ensure all github actions are enabled and running.  Ensure the README has the github setup instructions for cosign and the other steps required to finish the task.
```

## What's Included

### Build System
- Automated builds via GitHub Actions on every commit to main
- Awesome self hosted Renovate setup that keeps all your images and actions up to date.
- Automatic cleanup of old images (90+ days) to keep it tidy
- Pull request workflow - test changes before merging to main
  - PRs build and validate before merge
  - `main` branch builds `:stable` images
- Validates your files on pull requests so you never break a build:
  - Brewfile, Justfile, ShellCheck, Renovate config, and it'll even check to make sure the flatpak you add exists on FlatHub
- Production Grade Features
  - Container signing, SBOM Generation, and layer rechunking.
  - See checklist below to enable these as they take some manual configuration

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
- Optimizes container image layer distribution for better download resumability
- Based on [hhd-dev/rechunk](https://github.com/hhd-dev/rechunk) v1.2.4
- Disabled by default for faster initial builds
- Enable in `.github/workflows/build.yml` by uncommenting the rechunker steps (see comments in file)
- Recommended for production deployments after initial testing

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
5. `custom/ujust/README.md` (~line 175): `localhost/your-repo-name:stable`

### 3. Enable GitHub Actions

- Go to the "Actions" tab in your repository
- Click "I understand my workflows, go ahead and enable them"

Your first build will start automatically! 

Note: Image signing is disabled by default. Your images will build successfully without any signing keys. Once you're ready for production, see "Optional: Enable Image Signing" below.

### 4. Customize Your Image

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

### 5. Development Workflow

All changes should be made via pull requests:

1. Create a feature branch:
```bash
git checkout -b add-my-feature
# Make your changes
git add .
git commit -m "feat: add my feature"
git push origin add-my-feature
```

2. Open a pull request on GitHub targeting `main`
3. The PR will automatically trigger:
   - Build validation
   - Brewfile, Flatpak, Justfile, and shellcheck validation
   - Test image build
4. Once checks pass, merge the PR
5. Merging to `main` triggers the production build and publishes `:stable` image

### 6. Deploy Your Image

Switch to your image:
```bash
sudo bootc switch --transport registry ghcr.io/your-username/your-repo-name:stable
sudo systemctl reboot
```

## Optional: Enable Image Signing

Image signing is disabled by default to let you start building immediately. However, signing is strongly recommended for production use.

### Why Sign Images?

- Verify image authenticity and integrity
- Prevent tampering and supply chain attacks
- Required for some enterprise/security-focused deployments
- Industry best practice for production images

### Setup Instructions

1. Generate signing keys:
```bash
cosign generate-key-pair
```

This creates two files:
- `cosign.key` (private key) - Keep this secret
- `cosign.pub` (public key) - Commit this to your repository

2. Add the private key to GitHub Secrets:
   - Copy the entire contents of `cosign.key`
   - Go to your repository on GitHub
   - Navigate to Settings → Secrets and variables → Actions ([GitHub docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository))
   - Click "New repository secret"
   - Name: `SIGNING_SECRET`
   - Value: Paste the entire contents of `cosign.key`
   - Click "Add secret"

3. Replace the contents of `cosign.pub` with your public key:
   - Open `cosign.pub` in your repository
   - Replace the placeholder with your actual public key
   - Commit and push the change

4. Enable signing in the workflow:
   - Edit `.github/workflows/build.yml`
   - Find the "OPTIONAL: Image Signing with Cosign" section.
   - Uncomment the steps to install Cosign and sign the image (remove the `#` from the beginning of each line in that section).
   - Commit and push the change

5. Your next build will produce signed images!

Important: Never commit `cosign.key` to the repository. It's already in `.gitignore`.

## Love Your Image? Let's Go to Production

Ready to take your custom OS to production? Enable these features for enhanced security, reliability, and performance:

### Production Checklist

- [ ] **Enable Image Signing** (Recommended)
  - Provides cryptographic verification of your images
  - Prevents tampering and ensures authenticity
  - See "Optional: Enable Image Signing" section above for setup instructions
  - Status: **Disabled by default** to allow immediate testing

- [ ] **Enable Rechunker** (Recommended)
  - Optimizes image layer distribution for better download resumability
  - Improves reliability for users with unstable connections
  - To enable:
    1. Edit `.github/workflows/build.yml`
    2. Find the "Rechunk (OPTIONAL)" section around line 121
    3. Uncomment the "Run Rechunker" step
    4. Uncomment the "Load in podman and tag" step
    5. Comment out the "Tag for registry" step that follows
    6. Commit and push
  - Status: **Disabled by default** for faster initial builds

- [ ] **Enable SBOM Attestation** (Recommended)
  - Generates Software Bill of Materials for supply chain security
  - Provides transparency about what's in your image
  - Requires image signing to be enabled first
  - To enable:
    1. First complete image signing setup above
    2. Edit `.github/workflows/build.yml`
    3. Find the "OPTIONAL: SBOM Attestation" section around line 232
    4. Uncomment the "Add SBOM Attestation" step
    5. Commit and push
  - Status: **Disabled by default** (requires signing first)

### After Enabling Production Features

Your workflow will:
- Sign all images with your key
- Generate and attach SBOMs
- Optimize layers for better distribution
- Provide full supply chain transparency

Users can verify your images with:
```bash
cosign verify --key cosign.pub ghcr.io/your-username/your-repo-name:stable
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

This template provides security features for production use:
- Optional SBOM generation (Software Bill of Materials) for supply chain transparency
- Optional image signing with cosign for cryptographic verification
- Automated security updates via Renovate
- Build provenance tracking

These security features are disabled by default to allow immediate testing. When you're ready for production, see the "Love Your Image? Let's Go to Production" section above to enable them.

---

Template maintained by [Universal Blue Project](https://universal-blue.org/)

