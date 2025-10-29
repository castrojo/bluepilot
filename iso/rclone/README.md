# Rclone Configuration Directory

This directory contains example rclone configuration files for uploading ISO images to various cloud storage providers.

## Available Configurations

- **cloudflare-r2.conf** - Cloudflare R2 (S3-compatible, zero egress fees)
- **aws-s3.conf** - Amazon S3 (highly reliable, standard pricing)
- **backblaze-b2.conf** - Backblaze B2 (affordable, low egress fees)
- **sftp.conf** - SFTP/SSH upload to any server
- **scp.conf** - SCP upload to any server

## How to Use

### 1. Choose Your Storage Provider

Select the configuration file that matches your preferred storage provider. Each file contains:
- Setup instructions
- Required GitHub secrets
- Provider-specific configuration options

### 2. Set Up GitHub Secrets

For the ISO build workflow to upload files, you need to configure GitHub secrets:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the secrets required by your chosen provider (listed in the config file)

### 3. Choose Your Upload Method

The build-disk.yml workflow supports two upload methods:

#### Method A: Using rclone configs (Recommended)

This method uses the configuration files in this directory:

```yaml
# In .github/workflows/build-disk.yml, the workflow will:
# 1. Read the config from this directory
# 2. Substitute secrets automatically
# 3. Upload using rclone
```

To use this method, specify which config to use when triggering the workflow.

#### Method B: Direct environment variables (Legacy)

The workflow also supports direct environment variable configuration for backward compatibility.

### 4. Triggering the Workflow

The `build-disk.yml` workflow is triggered manually:

1. Go to **Actions** tab in your repository
2. Select **Build disk images** workflow
3. Click **Run workflow**
4. Select the platform (amd64 or arm64)
5. Enable **Upload to cloud storage** if you want to upload the ISO

## Configuration File Format

All configuration files use the rclone INI format with placeholders for secrets:

```ini
[remote-name]
type = provider_type
access_key_id = ${SECRET_NAME}
secret_access_key = ${ANOTHER_SECRET}
```

The workflow automatically replaces `${SECRET_NAME}` with the corresponding GitHub secret value.

## Customizing Configurations

You can modify these configuration files to suit your needs:

1. Edit the configuration file for your provider
2. Update the secret names in `${...}` placeholders
3. Add the corresponding secrets to your GitHub repository
4. Commit the changes

**Important:** Never commit actual credentials or secrets to the repository. Always use `${SECRET_NAME}` placeholders and GitHub secrets.

## Provider Comparison

| Provider | Setup Complexity | Cost | Egress Fees | Notes |
|----------|------------------|------|-------------|-------|
| Cloudflare R2 | Medium | $ | Free | Best for frequent downloads |
| AWS S3 | Medium | $$ | $$ | Most reliable, global reach |
| Backblaze B2 | Easy | $ | $ | Good balance of price/features |
| SFTP/SCP | Medium | Free* | Free | Requires your own server |

*Requires existing server infrastructure

## Troubleshooting

### "Permission denied" errors
- Check that your access keys are correct
- Verify IAM permissions (for AWS)
- Ensure the bucket exists and is accessible

### "Endpoint not found" errors
- Verify the endpoint URL is correct
- Check region settings
- For Cloudflare R2, ensure you're using the correct Account ID

### Upload fails silently
- Enable workflow debug logging in GitHub Actions
- Check that secrets are properly set
- Verify the rclone config syntax

## Additional Resources

- [Rclone Documentation](https://rclone.org/docs/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Backblaze B2 Documentation](https://www.backblaze.com/b2/docs/)

## Need Help?

If you encounter issues:
1. Check the workflow logs in the Actions tab
2. Review the rclone documentation for your provider
3. Ask in the [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
4. Post in the [Universal Blue Forums](https://universal-blue.discourse.group/)
