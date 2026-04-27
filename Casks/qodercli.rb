cask "qodercli" do
  version "0.2.1-beta2"
  desc "Qoder AI CLI tool - Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/releases/0.2.1-beta2/qodercli-darwin-arm64.tar.gz"
      sha256 "0fb508798f8f4b48ad844784405e6a23eea7e046d6b5a2ff81de4c67c8a3e7d8"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/releases/0.2.1-beta2/qodercli-darwin-x64.tar.gz"
      sha256 "c974cf70a6b1334ad0f2d63fcd658f59336717bb20afcd6c412e275aa72d2cb4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/releases/0.2.1-beta2/qodercli-linux-arm64.tar.gz"
      sha256 "65b9cacc650fcc02a76ff7ec5e120d3e4167e8d1aa2bc7f331294d8638ed4362"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/releases/0.2.1-beta2/qodercli-linux-x64.tar.gz"
      sha256 "f04e1d8915a6d834f4f85cc4ec9df5ed8a71d06cbb4b280310c06a4fd5d19cc6"
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
