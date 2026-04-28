cask "qodercli" do
  version "0.2.1-alpha.6"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.6/qodercli-darwin-arm64.tar.gz"
      sha256 "f17161d040355a498dde509e18ece38ed34775bedc0fdddce371845ebc94f395"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.6/qodercli-darwin-x64.tar.gz"
      sha256 "763cc27a86b2225a9a8a2cb6b1c4e2b3d54912566b774b78cb7bf7b74d7dd49a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.6/qodercli-linux-arm64.tar.gz"
      sha256 "6687e9072b8846ade91482ccb124aba4ad8c356c1b9b5caca6c58e66beacbc9b"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.6/qodercli-linux-x64.tar.gz"
      sha256 "509f4c3d6a447a0b2483ca17745ee1129a93e8a83f42db0645004cd0e376b53a"
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
