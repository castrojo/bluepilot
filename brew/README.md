# Homebrew Integration

This directory contains Brewfile declarations that will be copied into your custom image at `/usr/share/ublue-os/homebrew/`.

## What are Brewfiles?

Brewfiles are Homebrew's way of declaring packages in a declarative format. They allow you to specify which packages, taps, and casks you want installed.

## Usage

### Adding Brewfiles to Your Image

1. Create `.Brewfile` files in this directory
2. Add your desired packages using Brewfile syntax
3. Build your image - the Brewfiles will be copied to `/usr/share/ublue-os/homebrew/`

### Installing Packages from Brewfiles

After booting into your custom image, install packages with:

```bash
brew bundle --file /usr/share/ublue-os/homebrew/example.Brewfile
```

Or install all Brewfiles in the directory:

```bash
cd /usr/share/ublue-os/homebrew/
for file in *.Brewfile; do
    brew bundle --file "$file"
done
```

## Brewfile Syntax

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

## Example Brewfiles

### Developer Tools (`dev.Brewfile`)
```ruby
brew "gh"           # GitHub CLI
brew "git"          # Git version control
brew "neovim"       # Modern Vim
brew "node"         # Node.js
```

### Productivity (`productivity.Brewfile`)
```ruby
brew "bat"          # cat with syntax highlighting
brew "eza"          # modern ls replacement
brew "fd"           # modern find replacement
brew "ripgrep"      # modern grep replacement
brew "zoxide"       # smarter cd command
```

## Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [Brewfile Documentation](https://github.com/Homebrew/homebrew-bundle)
- [Bluefin Homebrew Guide](https://docs.projectbluefin.io/administration#homebrew)
