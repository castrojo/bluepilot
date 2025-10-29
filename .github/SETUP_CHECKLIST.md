# Setup Checklist for Finpilot Template

After creating a repository from this template, follow these steps:

## Initial Setup

- [ ] **Repository Settings**
  - [ ] Enable GitHub Actions in repository settings
  - [ ] Enable "Allow GitHub Actions to create and approve pull requests" in Settings → Actions → General
  - [ ] Set repository visibility (Public recommended for GHCR)

- [ ] **Branch Protection** (Optional but recommended)
  - [ ] Protect `main` branch: Settings → Branches → Add rule
    - Require pull request reviews
    - Require status checks (build workflow)
    - Do NOT allow direct pushes
  - [ ] Protect `testing` branch: Settings → Branches → Add rule
    - Require status checks (build-testing workflow)
    - Allow force pushes (for maintainers)

## Customization

- [ ] **Update Project Name**
  - [ ] Change `finpilot` in `Containerfile` (line 9: `# Name: finpilot`)
  - [ ] Update `image_name` in `Justfile` (line 1)
  - [ ] Update README.md title
  - [ ] Update `artifacthub-repo.yml` repositoryID
  - [ ] Update example in `custom/ujust/README.md`

- [ ] **Customize Base Image** (Optional)
  - [ ] Edit `Containerfile` FROM line (line 24) if you want a different base
  - [ ] Update renovate.json to match if needed

- [ ] **Add Your Changes**
  - [ ] Modify `build/10-build.sh` to install packages
  - [ ] Add custom Brewfiles in `custom/brew/`
  - [ ] Add flatpak preinstall files in `custom/flatpaks/`
  - [ ] Add custom ujust commands in `custom/ujust/`

## Optional: Enable Image Signing

Signing is disabled by default to allow initial builds to succeed.

- [ ] **Generate Signing Keys**
  ```bash
  cd your-repo
  COSIGN_PASSWORD="" cosign generate-key-pair
  ```

- [ ] **Add Secret to GitHub**
  - [ ] Go to Settings → Secrets and variables → Actions → [New repository secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
  - [ ] Name: `SIGNING_SECRET`
  - [ ] Value: Paste contents of `cosign.key` file

- [ ] **Commit Public Key**
  ```bash
  git add cosign.pub
  git commit -m "chore: add cosign public key"
  git push
  ```

- [ ] **Enable Signing in Workflow**
  - [ ] Edit `.github/workflows/build.yml`
  - [ ] Uncomment the cosign signing steps
  - [ ] Edit `.github/workflows/build-testing.yml`
  - [ ] Uncomment the cosign signing steps if desired
  - [ ] Commit and push changes

## Create Testing Branch

- [ ] **Create and Push Testing Branch**
  ```bash
  git checkout -b testing
  git push -u origin testing
  ```

- [ ] **Set Default Branch** (Optional)
  - [ ] Go to Settings → Branches → Default branch
  - [ ] Change to `testing` if you want it as default for PRs

## First Release

- [ ] **Make First Commit**
  ```bash
  git checkout testing
  git commit --allow-empty -m "feat: initial release"
  git push origin testing
  ```

- [ ] **Verify Builds**
  - [ ] Check Actions tab for build-testing workflow
  - [ ] Verify `:testing` image published to GHCR

- [ ] **Create First Release**
  - [ ] Wait for Release Please to create PR
  - [ ] Review and merge the release PR
  - [ ] Verify merge to `main` and `:latest` image build

## Test Your Image

- [ ] **Test Testing Image**
  ```bash
  sudo bootc switch --transport registry ghcr.io/YOUR_USERNAME/YOUR_REPO_NAME:testing
  sudo systemctl reboot
  ```

- [ ] **Test Production Image** (after first release)
  ```bash
  sudo bootc switch --transport registry ghcr.io/YOUR_USERNAME/YOUR_REPO:latest
  sudo systemctl reboot
  ```

## Documentation

- [ ] Update README.md with:
  - [ ] Your project name and description
  - [ ] Installation instructions
  - [ ] Customization you've made
  - [ ] Your branding/logo

- [ ] Update `artifacthub-repo.yml` if listing on ArtifactHub
  - [ ] repositoryID
  - [ ] owner name and email

## Verification

- [ ] GitHub Actions are running successfully
- [ ] Images are publishing to GHCR
- [ ] Release Please PR is created on testing branch
- [ ] SBOM attestations are attached to images
- [ ] Renovate is tracking base image updates (if enabled)

## Need Help?

- [Release Workflow Documentation](../RELEASE_WORKFLOW.md)
- [Universal Blue Discord](https://discord.gg/universal-blue)
- [bootc Documentation](https://containers.github.io/bootc/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
