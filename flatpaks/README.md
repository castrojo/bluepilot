# Flatpak Preinstall Integration

This directory contains Flatpak preinstall configuration files that will be copied into your custom image at `/etc/flatpak/preinstall.d/`.

## What is Flatpak Preinstall?

Flatpak preinstall is a feature that allows system administrators to define Flatpak applications that should be installed on first boot. These files are read by the Flatpak system integration and automatically install the specified applications.

## How It Works

1. **During Build**: Files in this directory are copied to `/etc/flatpak/preinstall.d/` in the image
2. **On First Boot**: The system reads these files and installs the specified Flatpaks
3. **User Experience**: Applications appear pre-installed without manual intervention

## File Format

Each file uses the INI format with `[Flatpak Preinstall NAME]` sections:

```ini
[Flatpak Preinstall org.mozilla.firefox]
Branch=stable

[Flatpak Preinstall org.gnome.Calculator]
Branch=stable
```

**Keys:**
- `Install` - (boolean) Whether to install (default: true)
- `Branch` - (string) Branch name (default: "master", commonly "stable")
- `IsRuntime` - (boolean) Whether this is a runtime (default: false for apps)
- `CollectionID` - (string) Collection ID of the remote, if any

See: https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-preinstall

## Example Files

- `default.preinstall` - Default applications for all users

You can create additional `.preinstall` files for different purposes:
- `development.preinstall` - Additional development tools
- `gnome.preinstall` - GNOME-specific applications
- `gaming.preinstall` - Gaming applications

## Usage

### Adding Flatpaks to Your Image

1. Create or edit a `.preinstall` file in this directory
2. Add Flatpak references in INI format with `[Flatpak Preinstall NAME]` sections
3. Build your image - the files will be copied to `/etc/flatpak/preinstall.d/`
4. On first boot, Flatpaks will be automatically installed

### Finding Flatpak IDs

To find the ID of a Flatpak:
```bash
flatpak search app-name
```

Or browse Flathub: https://flathub.org/

## Bluefin Default Flatpaks

The included `default.preinstall` file mirrors the core default Flatpaks from Bluefin with browsers, utilities, and GNOME applications.

You can create additional `.preinstall` files for different categories (development tools, gaming, media editing, etc.).

## Important Notes

- Files must use the `.preinstall` extension
- Comments can be added with `#`
- Empty lines are ignored
- **Flatpaks are downloaded from Flathub on first boot** - not embedded in the image
- **Internet connection required** after installation for Flatpaks to install
- Installation happens automatically after user setup completes
- Users can still uninstall these applications if desired
- First boot will take longer while Flatpaks are being installed

## Customization

Edit the files to match your needs:
- Remove applications you don't want
- Add new applications from Flathub
- Create separate files for different user profiles

## Resources

- [Flatpak Documentation](https://docs.flatpak.org/)
- [Flatpak Preinstall Reference](https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-preinstall)
- [Flathub](https://flathub.org/)
