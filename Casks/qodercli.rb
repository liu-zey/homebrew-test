cask "qodercli" do
  version "0.2.0-nightly.20260516.32da3aa"
  desc "Terminal-based AI assistant for code development"
  homepage "https://qoder.com"

  on_macos do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-nightly.20260516.32da3aa/qodercli-darwin-arm64.tar.gz"
      sha256 "99bb06ee2a3bc6b99bf4ab4b31df9cda83c2ed0789a66e3a481e08a49eb03c7a"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-nightly.20260516.32da3aa/qodercli-darwin-x64.tar.gz"
      sha256 "968334614e723058fe5525f901774b9ecf3d56710bf03d177fd63c8b67e317a4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-nightly.20260516.32da3aa/qodercli-linux-arm64.tar.gz"
      sha256 "c828221e878b32f828573fd663e311cb3740223615a9ac9e86c7e0c1644e437b"
    else
      url "https://qs-cli-dev.oss-cn-hangzhou.aliyuncs.com/qodercli/releases/0.2.0-nightly.20260516.32da3aa/qodercli-linux-x64.tar.gz"
      sha256 "951ee6aec261b1fb76ac7851d4908f715b137b20bf0f73e8a4fbfa20ed0fbc63"
    end
  end

  binary "qodercli"

  postflight do
    set_permissions "#{staged_path}/qodercli", "0755"

    # Write install marker
    File.write("#{staged_path}/.qodercli-install-resource", "homebrew-cask")
    set_permissions "#{staged_path}/.qodercli-install-resource", "0644"

    ENV["QODER_CLI_INSTALL"] = "1"

    begin
      log_dir = File.expand_path("~/.qoder/logs")
      FileUtils.mkdir_p(log_dir)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_file = "#{log_dir}/install_#{timestamp}.log"
      log_content = [
        "Install Time: #{Time.now}",
        "Version: #{version}",
        "Platform: #{RUBY_PLATFORM}",
        "Install Method: homebrew-cask",
        "Staged Path: #{staged_path}",
      ].join("\n")
      File.write(log_file, log_content)
      FileUtils.ln_sf(log_file, "#{log_dir}/qodercli_install.log")

      # Verify installation
      output = `"#{staged_path}/qodercli" --version 2>&1`.strip
      puts "qodercli #{version} installed successfully (#{output})"
    rescue => e
      opoo "Post-install logging failed: #{e.message}"
    end
  end
end
