cask "qodercli" do
  version "1.0.0-nightly.20260602.dba01eb"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/1.0.0-nightly.20260602.dba01eb/qodercli-darwin-arm64.tar.gz"
      sha256 "a05448c92e01c46609aa4c369bc33ba45d789686ad5fe497b243433a3959980c"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/1.0.0-nightly.20260602.dba01eb/qodercli-darwin-x64.tar.gz"
      sha256 "2186cfac53c2c9f7f1afdd174e0cd702e23f7d607ba40c6e61854b9a53d4241f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/1.0.0-nightly.20260602.dba01eb/qodercli-linux-arm64.tar.gz"
      sha256 "7e031aff96be86bede2b49b5326b9165809d7a6e72b0e0ea903337007af9c045"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/1.0.0-nightly.20260602.dba01eb/qodercli-linux-x64.tar.gz"
      sha256 "7ba7f96c9a85d53c14a42a222689d702f8f21528c55ca980a6429b2b7039d75c"
    end
  end

  binary "qodercli"

  postflight do
    require 'fileutils'
    require 'time'

    marker = staged_path/'.qodercli-install-resource'
    File.write(marker, "homebrew-cask")
    marker.chmod(0644)

    (staged_path/"qodercli").chmod(0755)

    bin_binary = HOMEBREW_PREFIX/"bin"/"qodercli"
    ENV['QODER_CLI_INSTALL'] = '1'

    begin
      log_dir = File.expand_path("~/.qoder/logs")
      FileUtils.mkdir_p(log_dir)

      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_file = File.join(log_dir, "qodercli_install_homebrew_#{timestamp}.log")

      log = File.open(log_file, 'w')
      log.puts "Installation started at #{Time.now.iso8601}"
      log.puts "Installation method: homebrew-cask"
      log.puts "Platform: #{RUBY_PLATFORM}"
      log.puts "Homebrew prefix: #{HOMEBREW_PREFIX}"
      log.puts "================================\n"
      log.flush

      latest_log = File.join(log_dir, "qodercli_install.log")
      File.unlink(latest_log) if File.exist?(latest_log) || File.symlink?(latest_log)
      File.symlink(log_file, latest_log)

      version_output = `#{bin_binary} --version 2>&1`.strip

      if $?.success?
        log.puts "Installation verified successfully"
        log.puts "Version: #{version_output}"
        puts "\nQoder CLI #{version_output} installed successfully!"
      else
        log.puts "[ERROR] Version check failed: #{version_output}"
        puts "\nInstallation completed but version check failed"
      end

      log.puts "\nInstallation completed at #{Time.now.iso8601}"
      log.close

      puts "Get started: qodercli --help"
      puts "Installation log: #{log_file}\n"

    rescue => e
      puts "\nQoder CLI installed successfully!"
      puts "Get started: qodercli --help"
      puts "(Note: Installation log could not be created: #{e.message})\n"
    end
  end
end