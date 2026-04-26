cask "qodercli" do
  version "0.2.0-beta7"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-beta7/qodercli-darwin-arm64.tar.gz"
      sha256 "f6988ca5dd71937acf079d7838aa92632bfd64b7fa60c4c3d62df7ff894dc67f"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-beta7/qodercli-darwin-x64.tar.gz"
      sha256 "c76d1b421654cf8a44e42044359e87ebfb74952f85b79e71fc461fd835fa71eb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-beta7/qodercli-linux-arm64.tar.gz"
      sha256 "4be605f8ed653a89817f620466ff06389967c1d2fe71d362709c238f5da6c1c3"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-beta7/qodercli-linux-x64.tar.gz"
      sha256 "becffe302fc11606cd5eab3bca0e7f77b7c966cd6a65d602f94f18770442268d"
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
