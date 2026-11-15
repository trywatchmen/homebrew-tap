# WatchmenCLI Enterprise — private, token-gated Homebrew formula.
#
# The enterprise binary is PRIVATE: it is never published to a public registry and no
# binary bytes live in this tap. Installation authenticates the customer's subscription
# against the cloud license check, which hands back a short-lived presigned download.
#
#   WM_TOKEN=<your-download-token> brew install trywatchmen/tap/wm-enterprise
#
# Mint a download token in your dashboard: Tokens -> Enterprise download token.

# Fetches the private binary through the cloud license check: the customer's WM_TOKEN is
# presented as a Bearer header so the server authenticates the subscription, then 302-
# redirects to a short-lived presigned S3 object. Homebrew strips the Authorization header
# on the cross-host redirect, so the token never reaches storage; Homebrew then verifies
# the sha256 declared below.
class WatchmenLicenseDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    # Homebrew scrubs non-HOMEBREW_ env vars from the formula environment, so the token
    # must be passed as HOMEBREW_WM_TOKEN (this is how brew handles registry secrets too).
    token = ENV["HOMEBREW_WM_TOKEN"].to_s
    if token.empty?
      raise CurlDownloadStrategyError, <<~MSG
        WatchmenCLI Enterprise needs a download token.
        Mint one in your dashboard (Tokens), then:
          HOMEBREW_WM_TOKEN=<token> brew install trywatchmen/tap/wm-enterprise
      MSG
    end

    # Point at a non-production deployment for testing; defaults to production.
    api = ENV["HOMEBREW_WM_API"].to_s
    url = url.sub("https://trywatchmen.cloud", api) unless api.empty?
    meta[:headers] ||= []
    meta[:headers] << "Authorization: Bearer #{token}"
    super
  end
end

class WmEnterprise < Formula
  desc "WatchmenCLI Enterprise - fleet security scanner, monitor, and MCP server"
  homepage "https://trywatchmen.cloud"
  version "3.2.0"

  on_macos do
    on_arm do
      url "https://trywatchmen.cloud/api/downloads/license-check?platform=mac&version=3.2.0",
          using: WatchmenLicenseDownloadStrategy
      sha256 "03307c5f4a1e243407c33ed24f0b2b1e79263e5dd79f365ede44f7323735c474"
    end
  end

  on_linux do
    on_intel do
      url "https://trywatchmen.cloud/api/downloads/license-check?platform=linux&version=3.2.0",
          using: WatchmenLicenseDownloadStrategy
      sha256 "48dbe83e31a42c9769a38f3b60e19874d39007852784946cfe871e560462f846"
    end
  end

  # Enterprise is the superset that REPLACES the community `wm` as one active binary; take
  # over the `wm` link even if the community formula owns it.
  link_overwrite "bin/wm"

  def install
    # The strategy fetches the raw binary (its basename is the S3 object name); install
    # the single downloaded file as `wm`.
    bin.install Dir["*"].first => "wm"
  end

  def caveats
    <<~EOS
      wm keeps its data in ~/.watchmen (scan history, the document index, keys).
      Before `brew uninstall`, run `wm uninstall` to remove its background service;
      `wm uninstall --purge` also deletes ~/.watchmen.
    EOS
  end

  test do
    assert_match "Watchmen", shell_output("#{bin}/wm version")
  end
end
