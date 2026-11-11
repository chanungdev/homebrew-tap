cask "nfcd-app" do
  version "0.2.3"
  sha256 "016c80a7d16da240e7e3a3eff4ae8ce05f5dffd4cccedf94faa0bc7472a5e2c1"

  url "https://github.com/chanungdev/nfcd/releases/download/v#{version}/nfcd-app.zip"
  name "nfcd"
  desc "Menu bar app for nfcd, which renames NFD filenames to NFC"
  homepage "https://github.com/chanungdev/nfcd"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "chanungdev/tap/nfcd"
  depends_on macos: :ventura

  app "nfcd.app"

  uninstall launchctl: "io.github.chanungdev.nfcd.gui",
            quit:      "io.github.chanungdev.nfcd.gui"

  zap trash: [
    "~/Library/Application Support/io.github.chanungdev.nfcd.gui",
    "~/Library/Caches/io.github.chanungdev.nfcd.gui",
    "~/Library/LaunchAgents/io.github.chanungdev.nfcd.gui.plist",
    "~/Library/WebKit/io.github.chanungdev.nfcd.gui",
  ]
end
