class Macup < Formula
  desc "See what is outdated across Homebrew, npm, mise, and macOS"
  homepage "https://github.com/sd2389/macup"
  url "https://github.com/sd2389/macup/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "99c59475f6b4d5807404e33964d753dfe037722251be87de9a4892a73eb3ed6a"
  license "Apache-2.0"
  head "https://github.com/sd2389/macup.git", branch: "main"

  depends_on macos: :sonoma

  uses_from_macos "swift" => :build

  deny_network_access!

  # Dependencies are downloaded here; the build that follows runs offline.
  # SwiftPM's own sandbox cannot nest inside Homebrew's, which still confines
  # both phases (std_swift_args disables it for the build on macOS).
  # Package.resolved pins every dependency revision.
  def fetch
    system "swift", "package", "resolve", "--disable-sandbox", "--force-resolved-versions"
  end

  def install
    args = ["--force-resolved-versions", *std_swift_args]
    system "swift", "build", *args, "--product", "macup"
    bin.install "#{Utils.safe_popen_read("swift", "build", *args, "--show-bin-path").chomp}/macup"
    generate_completions_from_executable(bin/"macup", "--generate-completion-script")
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/macup --version").strip
    assert_match '"kind" : "configPaths"', shell_output("#{bin}/macup config path --json")
  end
end
