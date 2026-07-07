# zsh-bitwarden-sm

Oh My Zsh plugin for [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/) (`bws`).

Provides convenient aliases and functions for managing application secrets, API keys, and service credentials directly from the command line. Designed for both interactive use and automation workflows.

**For personal password management, see the companion plugin:** [zsh-bitwarden](https://github.com/underwoo/zsh-bitwarden)

## Table of Contents

- [Installation](#installation)
- [Requirements](#requirements)
- [Usage](#usage)
- [Aliases](#aliases)
- [Functions](#functions)
- [Examples](#examples)
- [Configuration](#configuration)
- [Related Plugins](#related-plugins)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins`:

   ```zsh
   git clone https://github.com/underwoo/zsh-bitwarden-sm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bitwarden-sm
   ```

2. Add `zsh-bitwarden-sm` to your plugins array in `~/.zshrc`:

   ```zsh
   plugins=(
     # ... other plugins
     zsh-bitwarden-sm
   )
   ```

3. Reload your shell:

   ```zsh
   source ~/.zshrc
   ```

### Manual

```zsh
git clone https://github.com/underwoo/zsh-bitwarden-sm ~/.zsh-bitwarden-sm
echo "source ~/.zsh-bitwarden-sm/bws.plugin.zsh" >> ~/.zshrc
source ~/.zshrc
```

## Requirements

- **Required**: [Bitwarden Secrets Manager CLI (`bws`)](https://bitwarden.com/help/secrets-manager-cli/)
- **Required**: `jq` - for JSON parsing
- **Required**: Bitwarden Secrets Manager subscription and service account access token
- **Oh My Zsh**: Recommended but not required

**Note:** For personal password management, see the companion plugin [zsh-bitwarden](https://github.com/underwoo/zsh-bitwarden).

### Installing Dependencies

**macOS (Homebrew):**
```zsh
brew install bitwarden/tap/bws jq
```

**Linux:**
```zsh
# Bitwarden Secrets Manager CLI
curl -L https://github.com/bitwarden/sdk/releases/latest/download/bws-x86_64-unknown-linux-gnu.zip -o bws.zip
unzip bws.zip && chmod +x bws && sudo mv bws /usr/local/bin/

# jq
sudo apt-get install jq  # Debian/Ubuntu
sudo dnf install jq      # Fedora/RHEL
```

### Getting an Access Token

1. Log in to your Bitwarden web vault
2. Go to **Settings** → **Secrets Manager**
3. Create a **Service Account**
4. Generate an **Access Token**
5. Save the token securely (you'll need it for configuration)

## Usage

### Quick Start

```zsh
# Set your access token (one-time)
export BWS_ACCESS_TOKEN='your-token-here'

# Test it
bwss                   # List secrets
bwsget API_KEY         # Get a specific secret
bwscopy DATABASE_URL   # Copy secret to clipboard
```

## Aliases

| Alias | Command | Description |
|:------|:--------|:------------|
| `bwss` | `bws secret list -o table` | List secrets (table format) |
| `bwse` | `bws secret list -o env` | List secrets (environment variables) |
| `bwsj` | `bws secret list -o json` | List secrets (JSON format) |
| `bwsp` | `bws project list -o table` | List projects |
| `bwsc` | `bws config` | Show configuration |

## Functions

### `bwsget <secret-key>`

Get secret value by key name.

```zsh
bwsget API_KEY         # Print API_KEY value
bwsget DATABASE_URL    # Print DATABASE_URL value
```

### `bwsgetid <secret-id>`

Get secret value by UUID.

```zsh
bwsgetid abc-123-def   # Get secret by ID
```

### `bwscopy <secret-key>`

Copy secret to clipboard.

```zsh
bwscopy AWS_SECRET_KEY # Copy to clipboard
```

### `bwsexp [project-id]`

Export secrets as environment variables.

```zsh
bwsexp                 # Export all accessible secrets
bwsexp <project-id>    # Export from specific project
```

### `bwsrun <command> [args...]`

Run command with secrets injected.

```zsh
bwsrun terraform apply
bwsrun npm run deploy
```

### `bwssearch <pattern>`

Search secrets by key name.

```zsh
bwssearch api          # Find all API-related secrets
bwssearch prod         # Find production secrets
```

### `bwstoken`

Check access token configuration.

```zsh
bwstoken               # Verify token is set
```

## Examples

### CI/CD Pipeline

```zsh
# In your deploy script
bwsexp production      # Load all production secrets
terraform apply
```

### Local Development

```zsh
# Export dev secrets
bwsexp development

# Run your app with secrets available
npm run dev
```

### One-off Commands

```zsh
# Run command with secrets injected
bwsrun docker-compose up

# Get specific secret for manual use
bwsget DATABASE_PASSWORD | pbcopy
```

### Scripting

```bash
#!/usr/bin/env zsh
# deploy.sh

# Get specific secrets
export API_KEY=$(bwsget OPENAI_API_KEY)
export DB_URL=$(bwsget DATABASE_URL)

if [[ -z "$API_KEY" ]] || [[ -z "$DB_URL" ]]; then
  echo "Failed to retrieve required secrets"
  exit 1
fi

# Deploy with secrets
./do-deployment.sh
```

## Configuration

### Environment Variable (Recommended for CI/CD)

```zsh
export BWS_ACCESS_TOKEN='your-token-here'
```

Add to `~/.zshenv` for persistence:

```zsh
echo 'export BWS_ACCESS_TOKEN="your-token-here"' >> ~/.zshenv
```

### Config File (Recommended for Local Development)

```zsh
# Configure interactively
bws config

# Or manually edit ~/.config/bws/config
```

### Profiles

Use multiple profiles for different environments:

```zsh
# Set active profile
export BWS_PROFILE=production

# List secrets from production
bwss
```

## Related Plugins

### Personal Password Management

For daily password retrieval and personal vault management:

**[zsh-bitwarden](https://github.com/underwoo/zsh-bitwarden)** - Bitwarden CLI (`bw`) plugin

Key differences:
- **`bw` (separate plugin)**: Personal passwords, interactive authentication
- **`bws` (this plugin)**: Application secrets, token-based authentication

Use both together:

```zsh
plugins=(
  zsh-bitwarden     # Personal vault (bw)
  zsh-bitwarden-sm  # Secrets Manager (bws)
)
```

## Troubleshooting

### Command not found: bws

```zsh
# Check installation
which bws

# Install on macOS
brew install bitwarden/tap/bws

# Verify
bws --version
```

### No access token configured

```zsh
# Check token status
bwstoken

# Set token
export BWS_ACCESS_TOKEN='your-token-here'

# Or configure via file
bws config
```

### jq not found

```zsh
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

### Permission denied errors

Ensure your service account has access to the secrets/projects you're trying to access in the Bitwarden web vault.

## Contributing

Contributions welcome! Please submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Bitwarden](https://bitwarden.com/) for Secrets Manager
- [Oh My Zsh](https://ohmyz.sh/) for the plugin framework

## Related Projects

- [zsh-bitwarden](https://github.com/underwoo/zsh-bitwarden) - Companion plugin for personal passwords
- [Bitwarden Secrets Manager](https://github.com/bitwarden/sdk) - Official SDK and CLI

---

**Author**: [Seth Underwood](https://github.com/underwoo)

**Repository**: [github.com/underwoo/zsh-bitwarden-sm](https://github.com/underwoo/zsh-bitwarden-sm)

**Issues**: [github.com/underwoo/zsh-bitwarden-sm/issues](https://github.com/underwoo/zsh-bitwarden-sm/issues)

