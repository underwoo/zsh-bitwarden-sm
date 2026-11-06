#!/usr/bin/env zsh
# Bitwarden Secrets Manager plugin for oh-my-zsh
# Works with the Bitwarden Secrets Manager CLI (bws)

# Check if bws is installed (silently)
if ! command -v bws &> /dev/null; then
  # Don't echo during shell init; just skip loading
  return 1
fi

# Check if jq is installed (silently)
if ! command -v jq &> /dev/null; then
  # Don't echo during shell init; just skip loading
  return 1
fi

#
# Aliases
#

# bwss - List secrets (table format)
alias bwss='bws secret list -o table'

# bwse - List secrets as environment variables
alias bwse='bws secret list -o env'

# bwsj - List secrets as JSON
alias bwsj='bws secret list -o json'

# bwsp - List projects
alias bwsp='bws project list -o table'

# bwsc - Show config
alias bwsc='bws config'

#
# Functions
#

# bwsget - Get specific secret value by key
# Usage: bwsget <secret-key>
bwsget() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwsget <secret-key>"
    echo "Get the value of a secret by its key name"
    return 1
  fi
  
  bws secret list -o json 2>/dev/null | command jq -r ".[] | select(.key == \"$1\") | .value"
}

# bwsgetid - Get secret value by ID
# Usage: bwsgetid <secret-id>
bwsgetid() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwsgetid <secret-id>"
    echo "Get the value of a secret by its UUID"
    return 1
  fi
  
  bws secret get "$1" -o json 2>/dev/null | command jq -r '.value'
}

# bwscopy - Get secret and copy to clipboard
# Usage: bwscopy <secret-key>
bwscopy() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwscopy <secret-key>"
    echo "Copy a secret's value to clipboard by key name"
    return 1
  fi
  
  local secret=$(bws secret list -o json 2>/dev/null | command jq -r ".[] | select(.key == \"$1\") | .value")
  
  if [[ -n "$secret" ]]; then
    echo -n "$secret" | clipcopy
    echo "✓ Secret '$1' copied to clipboard"
  else
    echo "✗ Secret '$1' not found"
    echo "Available secrets:"
    bws secret list -o table 2>/dev/null | head -20
    return 1
  fi
}

# bwsexp - Export secrets as environment variables
# Usage: bwsexp [project-id]
bwsexp() {
  local project_id="$1"
  
  if [[ -n "$project_id" ]]; then
    eval "$(bws secret list "$project_id" -o env 2>/dev/null)"
  else
    eval "$(bws secret list -o env 2>/dev/null)"
  fi
  
  if [[ $? -eq 0 ]]; then
    local count=$(bws secret list -o json 2>/dev/null | command jq 'length')
    echo "✓ Exported $count secrets to current shell"
  else
    echo "✗ Failed to export secrets"
    echo "Ensure BWS_ACCESS_TOKEN is set or configured"
    return 1
  fi
}

# bwsrun - Run command with secrets injected
# Usage: bwsrun <command> [args...]
bwsrun() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwsrun <command> [args...]"
    echo "Run a command with secrets injected as environment variables"
    return 1
  fi
  
  bws run "$@"
}

# bwssearch - Search secrets by key name
# Usage: bwssearch <pattern>
bwssearch() {
  if [[ -z "$1" ]]; then
    echo "Usage: bwssearch <pattern>"
    echo "Search secrets by key name (case-insensitive regex)"
    return 1
  fi
  
  bws secret list -o json 2>/dev/null | command jq -r ".[] | select(.key | test(\"$1\"; \"i\")) | \"\(.key)\t\(.id)\""
}

# bwstoken - Check if access token is configured
# Usage: bwstoken
bwstoken() {
  if [[ -n "$BWS_ACCESS_TOKEN" ]]; then
    echo "✓ BWS_ACCESS_TOKEN is set (environment variable)"
  elif [[ -f ~/.config/bws/config ]]; then
    echo "✓ Config file exists: ~/.config/bws/config"
    echo "Current profile: ${BWS_PROFILE:-default}"
  else
    echo "✗ No access token configured"
    echo ""
    echo "Set BWS_ACCESS_TOKEN environment variable:"
    echo "  export BWS_ACCESS_TOKEN='your-token-here'"
    echo ""
    echo "Or configure via:"
    echo "  bws config"
    return 1
  fi
}

# Tab completion for bws (commented out to avoid conflicts)
# Uncomment if you need bash-style completion:
# if [[ -n ${ZSH_VERSION-} ]]; then
#   autoload -U +X bashcompinit && bashcompinit
#   complete -C bws bws 2>/dev/null || true
# fi
