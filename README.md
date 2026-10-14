# MacFanControl Homebrew tap

Homebrew packages for MacFanControl.

```bash
brew tap macfancontrol/tap
brew trust macfancontrol/tap
brew install macfancontrol
sudo macfancontrol install
```

Homebrew 7 does not load formulae from third-party taps until they are trusted; `brew trust` is needed once.

For updates and removal, see [MacFanControl](https://github.com/macfanpro/macfanpro).

On Apple Silicon with macOS 14 or later, Homebrew installs a prebuilt bottle, so no Xcode is needed; elsewhere the formula builds the tagged source. It bundles the CLI, app and license notices. Root service installation is explicit (`sudo macfancontrol install`); Homebrew never runs privileged setup inside its build sandbox.

## Maintenance

The [Update formula](.github/workflows/update-formula.yml) workflow follows MacFanControl's latest published release (drafts are ignored). Every hour it checks the release; when there is a new one it points the formula at the tag, builds a bottle, uploads it to a `macfancontrol-<version>` release in this repository, checks that Homebrew pours it and that `brew test` passes, and only then commits the formula. To run it right after publishing a release:

```bash
gh workflow run update-formula.yml -R macfancontrol/homebrew-tap
```

MacFanControl was formerly MacFanPro. Existing `macfanpro` installations migrate through Homebrew formula renaming; the old command and formula name remain compatibility aliases.

The tap moved from `macfanpro/homebrew-tap` to `macfancontrol/homebrew-tap`. GitHub redirects the old repository and release URLs. Existing `macfanpro/tap` checkouts can continue to update; no uninstall is required. New installations should use `macfancontrol/tap`.
