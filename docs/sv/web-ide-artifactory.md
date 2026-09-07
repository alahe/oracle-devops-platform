[ 🇬🇧 English ](../web-ide-artifactory.md) | [ 🇪🇪 Eesti ](../et/web-ide-artifactory.md) | [ 🇫🇮 Suomi ](../fi/web-ide-artifactory.md) | [ 🇸🇪 Svenska ](web-ide-artifactory.md) | [ 🇱🇻 Latviešu ](../lv/web-ide-artifactory.md) | [ 🇱🇹 Lietuvių ](../lt/web-ide-artifactory.md)

# Containerbaserad web IDE & enterprise tilläggsmarknad

Denna guide beskriver konfiguration och användning av **Containerbaserad Web IDE ( / )** i webbläsaren, integrering med **Artifactory / VS Code Marketplace**, tillägg för **Oracle SQL Developer, Google Antigravity och Microsoft Python**, samt **100% lokal och säker GitHub Actions-testning (offline)**.

---

## 1. Web IDE arkitektur & förinstallerade verktyg

Web IDE samlar en komplett Oracle-, AI- och CI/CD-utvecklingsmiljö i ett webbläsarbaserat VS Code-gränssnitt ():
- **Webbadress:**  (HTTP) eller  (HTTPS).
- **Förinstallerade verktyg:** OpenJDK 21, Oracle SQLcl 26.2, Liquibase, Git, Python3 (, ), GitHub CLI (Work seamlessly with GitHub from the command line.

USAGE
  gh <command> <subcommand> [flags]

CORE COMMANDS
  auth:          Authenticate gh and git with GitHub
  browse:        Open repositories, issues, pull requests, and more in the browser
  codespace:     Connect to and manage codespaces
  gist:          Manage gists
  issue:         Manage issues
  org:           Manage organizations
  pr:            Manage pull requests
  project:       Work with GitHub Projects.
  release:       Manage releases
  repo:          Manage repositories
  skill:         Install and manage agent skills (preview)

GITHUB ACTIONS COMMANDS
  cache:         Manage GitHub Actions caches
  run:           View details about workflow runs
  workflow:      View details about GitHub Actions workflows

ALIAS COMMANDS
  co:            Alias for "pr checkout"

ADDITIONAL COMMANDS
  agent-task:    Work with agent tasks (preview)
  alias:         Create command shortcuts
  api:           Make an authenticated GitHub API request
  attestation:   Work with artifact attestations
  completion:    Generate shell completion scripts
  config:        Manage configuration for gh
  copilot:       Run the GitHub Copilot CLI (preview)
  extension:     Manage gh extensions
  gpg-key:       Manage GPG keys
  label:         Manage labels
  licenses:      View third-party license information
  preview:       Execute previews for gh features
  ruleset:       View info about repo rulesets
  search:        Search for repositories, issues, and pull requests
  secret:        Manage GitHub secrets
  ssh-key:       Manage SSH keys
  status:        Print information about relevant issues, pull requests, and notifications across repositories
  variable:      Manage GitHub Actions variables

HELP TOPICS
  accessibility: Learn about GitHub CLI's accessibility experiences
  actions:       Learn about working with GitHub Actions
  environment:   Environment variables that can be used with gh
  exit-codes:    Exit codes used by gh
  formatting:    Formatting options for JSON data exported from gh
  mintty:        Information about using gh with MinTTY
  reference:     A comprehensive reference of all gh commands

FLAGS
  --help      Show help for command
  --version   Show gh version

EXAMPLES
  $ gh issue create
  $ gh repo clone cli/cli
  $ gh pr checkout 321

LEARN MORE
  Use `gh <command> <subcommand> --help` for more information about a command.
  Read the manual at https://cli.github.com/manual
  Learn about exit codes using `gh help exit-codes`
  Learn about accessibility experiences using `gh help accessibility`), Nektos  CLI runner,  och .
- **Förinstallerade VS Code-tillägg:**
  1. 🗄️ **Oracle SQL Developer for VS Code** (, Oracle)
  2. 🤖 **Google Antigravity** (, Google)
  3. 🐍 **Python Suite** (, , , Microsoft)
  4. ⚙️ **GitHub Actions** (, GitHub)
  5. 📄 **Red Hat YAML** (, Red Hat)
- **Automatisk  Filkoppling:**
  - Alla , ,  och  filer öppnas automatiskt direkt i **Oracle SQL Developer Editor / SQL Arbetsblad**.
