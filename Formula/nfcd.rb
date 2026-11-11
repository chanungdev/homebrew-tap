class Nfcd < Formula
  desc "Watch directories and convert NFD filenames to NFC in real time"
  homepage "https://github.com/chanungdev/nfcd"
  url "https://github.com/chanungdev/nfcd/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "e784347651a50671732ae30c36f94c92c70ed4180f2ec37f25b2a3527faa59c5"
  license "MIT"
  head "https://github.com/chanungdev/nfcd.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args(path: "nfcd")
    system "cargo", "install", *std_cargo_args(path: "nfcd-watcher")
  end

  test do
    # 1. Version checks
    assert_match version.to_s, shell_output("#{bin}/nfcd --version")
    assert_match version.to_s, shell_output("#{bin}/nfcd-watcher --version")

    # 2. Watcher functional test
    watch_dir = testpath/"watch"
    ignore_dir = watch_dir/"ignored"
    mkdir_p ignore_dir

    config_dir = testpath/".config/nfcd"
    mkdir_p config_dir
    (config_dir/"config.toml").write <<~TOML
      [[paths]]
      path = "#{watch_dir}"
      mode = "recursive"
      ignore = ["/ignored/"]

      [[paths]]
      path = "#{testpath}/other"
      mode = "children"
    TOML

    spawn bin/"nfcd-watcher" do |watcher_pid|
      sleep 2

      # NFD: Korean "가" decomposed (ᄀ + ᅡ); NFC: composed
      nfd_name = "\u{1100}\u{1161}"
      nfc_name = "\u{AC00}"
      # APFS lookups ignore normalization, so compare the names stored on disk.
      names = ->(dir) { Dir.children(dir).map { |n| n.dup.force_encoding("UTF-8") } }

      # File in watch_dir is converted NFD→NFC
      (watch_dir/nfd_name).write("test")
      sleep 1
      assert_includes names.call(watch_dir), nfc_name

      # File in the ignored directory stays NFD
      (ignore_dir/nfd_name).write("test")
      sleep 1
      assert_includes names.call(ignore_dir), nfd_name
    ensure
      Process.kill("TERM", watcher_pid)
      Process.wait(watcher_pid)
    end

    # 3. TUI Config tab test
    require "pty"
    mkdir_p testpath/"Library/LaunchAgents"
    # Pre-create a dummy plist so the TUI skips launchctl bootstrap
    (testpath/"Library/LaunchAgents/io.github.chanungdev.nfcd.plist").write("")

    PTY.spawn(bin/"nfcd") do |r, w, _pid|
      # Switch to Config tab, delete both entries, save, quit
      "2ddsq".each_char { |key| w.write(key) }
      begin
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end

    # All entries deleted — no [[paths]] should remain
    refute_match "[[paths]]", (config_dir/"config.toml").read
  end
end
