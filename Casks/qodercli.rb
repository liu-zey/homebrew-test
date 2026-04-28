cask "qodercli" do
  version "0.2.1-alpha.7"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.7/qodercli-darwin-arm64.tar.gz"
      sha256 "e72dd5d77b008534d30c9b4f5e48465e91f28a5a2a495caba7326c7bb21d8417"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.7/qodercli-darwin-x64.tar.gz"
      sha256 "c465aa02ff9bd7edeb23060fe53459668c9f1f78b7422289a87224dcf32cdad9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.7/qodercli-linux-arm64.tar.gz"
      sha256 "45a084080408de0e03e0e8bafe61f7b6e7aad79351f92f07f5247a7fb133f3b5"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.1-alpha.7/qodercli-linux-x64.tar.gz"
      sha256 "66876ccb9ffa7b9d07bafc98b3b6e3c54af5706b94da0be3d6d5cd29c43fa168"
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
