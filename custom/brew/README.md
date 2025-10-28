# Homebrew Integration

This directory contains Brewfile declarations that will be copied into your custom image at `/usr/share/ublue-os/homebrew/`.

## What are Brewfiles?

Brewfiles are Homebrew's way of declaring packages in a declarative format. They allow you to specify which packages, taps, and casks you want installed.

## How It Works

1. **During Build**: Files in this directory are copied to `/usr/share/ublue-os/homebrew/` in the image
2. **After Installation**: Users install packages by running `brew bundle` commands
3. **User Experience**: Declarative package management via Homebrew

## Usage

### Adding Brewfiles to Your Image

1. Create `.Brewfile` files in this directory
2. Add your desired packages using Brewfile syntax
3. Build your image - the Brewfiles will be copied to `/usr/share/ublue-os/homebrew/`

**Example Files in this directory:**
- [`default.Brewfile`](default.Brewfile) - Essential command-line tools
- [`development.Brewfile`](development.Brewfile) - Development tools and languages
- [`fonts.Brewfile`](fonts.Brewfile) - Programming fonts

### Installing Packages from Brewfiles

After booting into your custom image, install packages with:

```bash
brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile
```

Or use the convenient ujust commands defined in [`custom/ujust/custom-apps.just`](../ujust/custom-apps.just):
```bash
ujust install-default-apps
ujust install-dev-tools
ujust install-fonts
```

## File Format

Brewfiles use Ruby syntax:

```ruby
# Add a tap (third-party repository)
tap "homebrew/cask"

# Install a formula (CLI tool)
brew "bat"
brew "eza"
brew "ripgrep"

# Install a cask (GUI application, macOS only)
cask "visual-studio-code"
```

## Customization

Edit the existing Brewfiles or create new ones:
- **[`default.Brewfile`](default.Brewfile)** - Modify for your essential tools
- **[`development.Brewfile`](development.Brewfile)** - Add your dev stack
- **[`fonts.Brewfile`](fonts.Brewfile)** - Add preferred fonts
- **Create new files** - `gaming.Brewfile`, `media.Brewfile`, etc.

When you add new Brewfiles, create corresponding ujust commands in [`custom/ujust/custom-apps.just`](../ujust/custom-apps.just) for easy installation.

## Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [Brewfile Documentation](https://github.com/Homebrew/homebrew-bundle)
- [Bluefin Homebrew Guide](https://docs.projectbluefin.io/administration#homebrew)
