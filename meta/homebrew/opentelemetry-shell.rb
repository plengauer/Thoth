class OpentelemetryShell < Formula
  desc "Generate OpenTelemetry traces, metrics, and logs from shell scripts fully automatically"
  homepage "https://github.com/plengauer/opentelemetry-bash"
  url "https://github.com/plengauer/Thoth/releases/download/v__VERSION__/opentelemetry-shell___VERSION__.tar.gz"
  sha256 "__SHA256__"
  version "__VERSION__"
  license "Apache-2.0"

  depends_on "coreutils"
  depends_on "findutils"
  depends_on "python@3.9" => :recommended
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
    system "#{prefix}/opt/opentelemetry_shell/venv/bin/python3", "-m", "venv", "#{prefix}/opt/opentelemetry_shell/venv"
    system "#{prefix}/opt/opentelemetry_shell/venv/bin/pip3", "install", "-r", "#{prefix}/opt/opentelemetry_shell/requirements.txt"
  end

  def caveats
    <<~EOS
      To use OpenTelemetry in your shell scripts, source the file:
        . #{bin}/otel.sh

      For more information, see:
        https://github.com/plengauer/opentelemetry-bash
    EOS
  end

  test do
    system "#{bin}/otel.sh", "--version"
  end
end
