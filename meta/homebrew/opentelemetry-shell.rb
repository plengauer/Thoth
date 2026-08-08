class OpentelemetryShell < Formula
  desc "Generate OpenTelemetry traces, metrics, and logs from shell scripts fully automatically"
  homepage "https://github.com/plengauer/opentelemetry-bash"
  url "https://github.com/plengauer/Thoth/releases/download/v__VERSION__/opentelemetry-shell___VERSION__.tar.gz"
  sha256 "__SHA256__"
  version "__VERSION__"
  license "Apache-2.0"

  depends_on "coreutils"
  depends_on "findutils"
  depends_on "python@3" => :recommended
  depends_on "grep"
  depends_on "gnu-sed"
  depends_on "gawk"
  depends_on "jq"
  depends_on "xxd" => :recommended

  def install
    prefix.install Dir["*"]
    bin.install_symlink prefix/"usr/bin/otel.sh"
    bin.install_symlink prefix/"usr/bin/otelapi.sh"
  end

  def post_install
    # the venv doesn't exist yet, so it has to be created with the dependency's python3 (on PATH
    # during the build), not the venv's own not-yet-created python3
    system "python3", "-m", "venv", "#{prefix}/opt/opentelemetry_shell/venv"
    system "#{prefix}/opt/opentelemetry_shell/venv/bin/pip3", "install", "-r", "#{prefix}/opt/opentelemetry_shell/requirements.txt"
  end

  def caveats
    <<~EOS
      To use OpenTelemetry in your shell scripts, source the file:
        . #{bin}/otel.sh

      Note: this formula's scripts look for their own files under the fixed path
      /usr/local/share/opentelemetry_shell rather than #{prefix}, so on Apple Silicon
      (where Homebrew's prefix is #{HOMEBREW_PREFIX}, not /usr/local) that lookup will
      fail unless /usr/local/share/opentelemetry_shell also exists, e.g. as a symlink to
      #{prefix}/usr/share/opentelemetry_shell.

      For more information, see:
        https://github.com/plengauer/opentelemetry-bash
    EOS
  end

  test do
    system "#{bin}/otel.sh", "--version"
  end
end
