cask "nfcd-app" do
  version "0.2.2"
  sha256 "bc5500441440398c105d2a2be10d8597f84b6875a17d911382fcd315882fdc1d"

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
