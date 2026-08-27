class OpentelemetryShell < Formula
  desc "Generate OpenTelemetry traces, metrics, and logs from shell scripts fully automatically"
  homepage "https://github.com/plengauer/opentelemetry-bash"
  url "https://github.com/plengauer/Thoth/releases/download/v__VERSION__/opentelemetry-shell___VERSION__.tar.gz"
  sha256 "__SHA256__"
  version "__VERSION__"
  license "Apache-2.0"

  depends_on "coreutils"
  depends_on "findutils"
  depends_on "python@3.12"
  depends_on "grep"
  depends_on "gnu-sed"
  depends_on "gawk"
  depends_on "jq"
  depends_on "xxd" => :recommended

  def install
    prefix.install Dir["*"]
    arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
    dylib_dir = prefix/"usr/share/opentelemetry_shell/agent.instrumentation.http"
    dylib = dylib_dir/arch/"libinjecthttpheader.dylib"
    mv dylib, dylib_dir/"libinjecthttpheader.dylib" if dylib.exist?
    rm_rf dylib_dir/"arm64"
    rm_rf dylib_dir/"x86_64"
    bin.install_symlink prefix/"usr/bin/otel.sh"
    bin.install_symlink prefix/"usr/bin/otelapi.sh"
  end

  def post_install
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", "#{prefix}/opt/opentelemetry_shell/venv"
    system "#{prefix}/opt/opentelemetry_shell/venv/bin/pip3", "install", "-r", "#{prefix}/opt/opentelemetry_shell/requirements.txt"
  end

  def caveats
    <<~EOS
      To use OpenTelemetry in your shell scripts, source the file:
        . #{bin}/otel.sh

      Add GNU userland tool shims to your PATH:
        export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
        export PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/findutils/libexec/gnubin:/usr/local/opt/grep/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/gawk/libexec/gnubin:$PATH"

      For more information, see:
        https://github.com/plengauer/opentelemetry-bash
    EOS
  end

  test do
    system "/bin/sh", "-c", ". #{bin}/otel.sh"
  end
end
