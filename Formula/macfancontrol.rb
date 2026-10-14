class Macfancontrol < Formula
  desc "Apple Silicon fan control with a multilingual menu bar app"
  homepage "https://github.com/macfanpro/macfanpro"
  url "https://github.com/macfanpro/macfanpro.git", tag: "v0.2.3.64", revision: "7d8549613b15461ad9e4bc2e92c50f2dc28c5b63"
  license "MIT"
  # Keep package ordering stable for existing MacFanControl installations.
  version_scheme 1

  # Prebuilt for Apple Silicon; the binaries target macOS 14, so the sonoma bottle
  # serves every later macOS. Without it Homebrew builds from source with Xcode.
  bottle do
    root_url "https://github.com/macfancontrol/homebrew-tap/releases/download/macfancontrol-0.2.3.64"
    sha256 arm64_sonoma: "bf9e665a00c78a1aea2f5d18d58ad26ac33e286fb1a2f200e888d4670e426ff8"
  end



  depends_on xcode: ["16.0", :build]
  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox", "--force-resolved-versions"
    system ".build/release/macfancontrol", "build-app",
           "--binary", ".build/release/MacFanControlApp",
           "--icon", "MacFanControl.icns",
           "--dest", "#{prefix}/MacFanControl.app"
    system "codesign", "--force", "--deep", "--sign", "-", "#{prefix}/MacFanControl.app"
    bin.install ".build/release/macfancontrol"
    # Older installed updaters still call these names after brew upgrade.
    bin.install_symlink "macfancontrol" => "macfanpro"
    prefix.install_symlink "MacFanControl.app" => "MacFanPro.app"
    pkgshare.install "LICENSE", "NOTICE.md", "ThirdPartyNotices"
  end

  def caveats
    <<~EOS
      Install or synchronize the root-owned daemon and menu bar app:
        sudo #{opt_bin}/macfancontrol install

      Open /Applications/MacFanControl.app and enable Launch at Login if wanted.
      After brew upgrade, stop the app before synchronizing the daemon:
        #{opt_bin}/macfancontrol auto --stop-app
        sudo #{opt_bin}/macfancontrol install
        open /Applications/MacFanControl.app

      Before brew uninstall, remove the privileged runtime:
        sudo macfancontrol uninstall
      User profiles, calibration and logs are preserved unless --purge-data is used.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/macfancontrol --version").strip
    assert_match "Fan control", shell_output("#{bin}/macfancontrol --help")
    assert_match "--migrate-thermalforge", shell_output("#{bin}/macfancontrol install --help")
    app = prefix/"MacFanControl.app"
    bundle_id = shell_output("/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' #{app}/Contents/Info.plist").strip
    assert_equal "io.github.macfanpro.app", bundle_id
    assert_equal version.to_s, shell_output("#{bin}/macfanpro --version").strip
    assert_path_exists prefix/"MacFanPro.app"
    assert_path_exists app/"Contents/Resources/LICENSE"
    assert_path_exists app/"Contents/Resources/MacFanControl_MacFanControlLocalization.bundle"
    system "codesign", "--verify", "--deep", "--strict", app
  end
end
