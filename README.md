# image-template

This repository is meant to be a template for building your own custom [bootc](https://github.com/bootc-dev/bootc) image. This template is the recommended way to make customizations to any image published by the Universal Blue Project.

# Community

If you have questions about this template after following the instructions, try the following spaces:
- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc discussion forums](https://github.com/bootc-dev/bootc/discussions) - This is not an Universal Blue managed space, but is an excellent resource if you run into issues with building bootc images.

# How to Use

To get started on your first bootc image, simply read and follow the steps in the next few headings.
If you prefer instructions in video form, TesterTech created an excellent tutorial, embedded below.

[![Video Tutorial](https://img.youtube.com/vi/IxBl11Zmq5w/0.jpg)](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## Step 0: Prerequisites

These steps assume you have the following:
- A Github Account
- A machine running a bootc image (e.g. Bazzite, Bluefin, Aurora, or Fedora Atomic)
- Experience installing and using CLI programs

## Step 1: Preparing the Template

### Step 1a: Copying the Template

Select `Use this Template` on this page. You can set the name and description of your repository to whatever you would like, but all other settings should be left untouched.

Once you have finished copying the template, you need to enable the Github Actions workflows for your new repository.
To enable the workflows, go to the `Actions` tab of the new repository and click the button to enable workflows.

### Step 1b: Enabling Renovate (Recommended)

[Renovate](https://docs.renovatebot.com/) is a dependency update tool that will automatically keep your base image and other dependencies up to date. This template includes:

- **Automated Renovate workflow** (`.github/workflows/renovate.yml`) that runs every 6 hours
- Pre-configured rules (`.github/renovate.json5`) for tracking your base image
- Automatic merging of digest updates (security patches)
- Automatic build triggering when the upstream image changes

**Setup is automatic!** The included workflow uses `GITHUB_TOKEN` and runs every 6 hours. No additional configuration needed.

#### What Renovate Monitors

The automated workflow will track:

- **Base Image**: The `FROM` statement in your `Containerfile` (e.g., `ghcr.io/ublue-os/bluefin:stable`)
  - Digest updates (security patches) are auto-merged and trigger a rebuild
  - Version updates (e.g., `stable` → `latest`) require manual review
- **Bootc Image Builder**: The `bib_image` variable in the `Justfile`
- **GitHub Actions**: Workflow dependencies in `.github/workflows/`

When you change your base image in the `Containerfile`, Renovate will automatically start tracking the new image without requiring any configuration changes!

#### How It Works

1. **Every 6 hours**: Renovate checks for updates to your dependencies
2. **Digest updates**: When your base image gets security patches, Renovate:
   - Creates a PR with the new digest
   - Auto-merges the PR (labeled with `renovate` and `automerge`)
   - Triggers the build workflow automatically
3. **Version updates**: Creates a PR for manual review (e.g., switching from `stable` to `latest`)

#### Manual Trigger

You can manually trigger Renovate at any time:
- Go to the **Actions** tab
- Select **Renovate** workflow
- Click **Run workflow**

### Step 1c: Cloning the New Repository

Here I will defer to the much superior GitHub documentation on the matter. You can use whichever method is easiest.
[GitHub Documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)

Once you have the repository on your local drive, proceed to the next step.

## Step 2: Initial Setup

### Step 2a: Creating a Cosign Key

Container signing is important for end-user security and is enabled on all Universal Blue images. By default the image builds *will fail* if you don't.

First, install the [cosign CLI tool](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-install-cosign/#installing-cosign-with-the-cosign-binary)
With the cosign tool installed, run inside your repo folder:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

The signing key will be used in GitHub Actions and will not work if it is password protected.

> [!WARNING]
> Be careful to *never* accidentally commit `cosign.key` into your git repo. If this key goes out to the public, the security of your repository is compromised.

Next, you need to add the key to GitHub. This makes use of GitHub's secret signing system.

<details>
    <summary>Using the Github Web Interface (preferred)</summary>

Go to your repository settings, under `Secrets and Variables` -> `Actions`
![image](https://user-images.githubusercontent.com/1264109/216735595-0ecf1b66-b9ee-439e-87d7-c8cc43c2110a.png)
Add a new secret and name it `SIGNING_SECRET`, then paste the contents of `cosign.key` into the secret and save it. Make sure it's the .key file and not the .pub file. Once done, it should look like this:
![image](https://user-images.githubusercontent.com/1264109/216735690-2d19271f-cee2-45ac-a039-23e6a4c16b34.png)
</details>
<details>
<summary>Using the Github CLI</summary>

If you have the `github-cli` installed, run:

```bash
gh secret set SIGNING_SECRET < cosign.key
```
</details>

### Step 2b: Choosing Your Base Image

To choose a base image, simply modify the line in the container file starting with `FROM`. This will be the image your image derives from, and is your starting point for modifications.
For a base image, you can choose any of the Universal Blue images or start from a Fedora Atomic system. Below this paragraph is a dropdown with a non-exhaustive list of potential base images.

<details>
    <summary>Base Images</summary>

- Bazzite: `ghcr.io/ublue-os/bazzite:stable`
- Aurora: `ghcr.io/ublue-os/aurora:stable`
- Bluefin: `ghcr.io/ublue-os/bluefin:stable`
- Universal Blue Base: `ghcr.io/ublue-os/base-main:latest`
- Fedora: `quay.io/fedora/fedora-bootc:42`

You can find more Universal Blue images on the [packages page](https://github.com/orgs/ublue-os/packages).
</details>

If you don't know which image to pick, choosing the one your system is currently on is the best bet for a smooth transition. To find out what image your system currently uses, run the following command:
```bash
sudo bootc status
```
This will show you all the info you need to know about your current image. The image you are currently on is displayed after `Booted image:`. Paste that information after the `FROM` statement in the Containerfile to set it as your base image.

### Step 2c: Changing Names

Change the first line in the [Justfile](./Justfile) to your image's name.

To commit and push all the files changed and added in step 2 into your Github repository:
```bash
git add Containerfile Justfile cosign.pub
git commit -m "Initial Setup"
git push
```
Once pushed, go look at the Actions tab on your Github repository's page.  The green checkmark should be showing on the top commit, which means your new image is ready!

## Step 3: Switch to Your Image

From your bootc system, run the following command substituting in your Github username and image name where noted.
```bash
sudo bootc switch ghcr.io/<username>/<image_name>
```
This should queue your image for the next reboot, which you can do immediately after the command finishes. You have officially set up your custom image! See the following section for an explanation of the important parts of the template for customization.

## renovate.json5

The [renovate.json5](./.github/renovate.json5) file configures [Renovate](https://docs.renovatebot.com/) to automatically keep your dependencies up to date. The configuration includes:

- **Custom Managers**: Regex patterns to detect Docker images in the `Justfile` with digest pins
- **Automerge Rules**: Automatically merges digest updates for your base image and dependencies
- **Package Rules**: Specific rules for different types of updates and packages

The configuration is designed to automatically track whatever base image you choose in the `Containerfile`. When you change your base image, Renovate will automatically start monitoring the new image without requiring any configuration changes.

## Customization

### Brew (Homebrew) Support

This template includes support for [Homebrew](https://brew.sh/) package management. The `/brew` directory contains Brewfiles that will be included in your custom image and made available to users.

**What's included:**
- `default.Brewfile` - Common CLI tools and utilities (bat, eza, fd, ripgrep, gh, starship, etc.)
- `development.Brewfile` - Development tools (kubernetes, cloud tools, programming languages)
- `fonts.Brewfile` - Nerd Fonts for terminal use

**How to customize:**
1. Edit the example Brewfiles in the `/brew` directory to add or remove packages
2. Create new `.Brewfile` files for your specific needs
3. All `.Brewfile` files will be copied to `/usr/share/ublue-os/homebrew/` during build

**Using Brewfiles on your system:**
After switching to your custom image, install packages from a Brewfile:
```bash
brew bundle --file=/usr/share/ublue-os/homebrew/default.Brewfile
```

For more details, see the [brew directory README](/brew/README.md).

### Other Customizations

- **Package Installation**: Edit `build_files/build.sh` to install system packages using dnf5
- **System Services**: Enable or disable systemd services in `build_files/build.sh`
- **Advanced Changes**: Modify the `Containerfile` for advanced container customization
