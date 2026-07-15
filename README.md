# WatchmenCLI Homebrew Tap

Token-gated Homebrew tap for **WatchmenCLI Enterprise**. The enterprise binary is private:
this tap contains only the formula — no binary bytes — and every install authenticates your
subscription against the cloud license check, which returns a short-lived, signed download.

## Install

```sh
brew tap trywatchmen/tap
HOMEBREW_WM_TOKEN=<your-download-token> brew install trywatchmen/tap/wm-enterprise
```

Mint a download token in your dashboard at **trywatchmen.cloud → Tokens → Enterprise
download token**. The variable is `HOMEBREW_WM_TOKEN` (Homebrew only forwards
`HOMEBREW_`-prefixed variables to a formula). Keep it out of your shell history; it is read
from the environment and never printed. Revoke it anytime from the dashboard.

## Upgrade

```sh
HOMEBREW_WM_TOKEN=<your-download-token> brew upgrade wm-enterprise
```

Each new version is fetched through the license check, so upgrades re-verify entitlement
and access follows your subscription.

## Community edition

The free Community edition is on the public tap:

```sh
brew install watchmencli/watchmen/wm
```
