# Brew Support

This directory contains Brewfiles that will be included in your custom image. These files are copied to `/usr/share/ublue-os/homebrew/` during the image build process.

## What are Brewfiles?

Brewfiles are configuration files for [Homebrew](https://brew.sh/) that list packages you want to install. On Universal Blue systems, Homebrew is used to install CLI tools, fonts, and other software packages.

## How to Use

1. **Edit existing Brewfiles**: Modify the example Brewfiles in this directory to add or remove packages
2. **Create new Brewfiles**: Add new `.Brewfile` files with your custom package lists
3. **Organize by theme**: Group related packages together (e.g., development tools, fonts, AI tools)

## Example Brewfiles

- `default.Brewfile` - Common CLI tools and utilities
- `development.Brewfile` - Development and programming tools (mostly commented out)
- `fonts.Brewfile` - Nerd Fonts for terminal use

## Syntax

```ruby
# Install a package
brew "package-name"

# Install a GUI application (cask)
cask "application-name"

# Add a tap (third-party repository)
tap "username/repo"
```

## Adding Packages

To find packages:
- Search at [brew.sh](https://brew.sh/)
- Use `brew search <package>` command
- Visit [formulae.brew.sh](https://formulae.brew.sh/)

## Notes

- All `.Brewfile` files in this directory will be copied to your image
- Users can then apply these Brewfiles using `brew bundle --file=/usr/share/ublue-os/homebrew/filename.Brewfile`
- Brewfiles are NOT automatically installed - they serve as templates/presets for users
- On Universal Blue systems, you can use `ujust` commands to manage brew installations

## Example Usage on Your System

After deploying your custom image:

```bash
# Install packages from a specific Brewfile
brew bundle --file=/usr/share/ublue-os/homebrew/default.Brewfile

# Or use ujust shortcuts (if available on your base image)
ujust brew-install
```

## Learn More

- [Homebrew Documentation](https://docs.brew.sh/)
- [Brewfile Documentation](https://github.com/Homebrew/homebrew-bundle)
- [Universal Blue Homebrew Setup](https://universal-blue.org/)
