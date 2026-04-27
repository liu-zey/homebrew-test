cask "qodercli" do
  version "0.2.1-pre"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-pre/qodercli-darwin-arm64.tar.gz"
      sha256 "f426b3122a7e01f0dbe9dd01d98706c70b4ffc917ea589aecd6968d958a7fa94"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-pre/qodercli-darwin-x64.tar.gz"
      sha256 "a5b0ef5656e6964f61e1e3522609198ec7034f10bb5becf9bd9287a9c7a4e56d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-pre/qodercli-linux-arm64.tar.gz"
      sha256 "0f87861b6ccd43aa567e20baeec6dfaf6b207762350d2acff7e3d15f084ad113"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-pre/qodercli-linux-x64.tar.gz"
      sha256 "155f6d760b267c2c5c5ecf99fb31f57b43222b7d54ee2fc490735a47218df126"
    end
  end

  binary "qodercli"

  # Create installation source marker after installation for update detection
  postflight do
    require 'fileutils'
    require 'time'

    # Core installation steps (must succeed)
    marker = staged_path/'.qodercli-install-resource'
    File.write(marker, "homebrew-cask")
    marker.chmod(0644)

    (staged_path/"qodercli").chmod(0755)

    bin_binary = HOMEBREW_PREFIX/"bin"/"qodercli"
    ENV['QODER_CLI_INSTALL'] = '1'

    # Logging and verification (failures here won't block installation)
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
