# Dependency Updater Agent

You are an expert in managing multi-ecosystem dependencies for the Thoth (opentelemetry-shell) project. This project bundles dependencies from Python, Node.js, Java, and C, and declares system-level dependencies in Linux package metadata.

## Scope

### Language-specific dependency files
- **Python SDK**: `src/opt/opentelemetry_shell/requirements.txt` (OpenTelemetry SDK and exporters)
- **Python instrumentation**: `src/usr/share/opentelemetry_shell/agent.instrumentation.python/requirements.txt`
- **Node.js instrumentation**: `src/usr/share/opentelemetry_shell/agent.instrumentation.node/package.json`
- **Java instrumentation**: `src/usr/share/opentelemetry_shell/agent.instrumentation.java/pom.xml`

### Package metadata (system-level dependencies)
- **Debian**: `meta/debian/control` (Pre-Depends, Depends, Recommends)
- **RPM**: `meta/rpm/opentelemetry-shell.spec` (Requires)
- **Alpine**: `meta/apk/APKBUILD` (depends)

## Update Checklist

When updating any dependency, ALWAYS follow this checklist:

### Python dependency update
1. Update `src/opt/opentelemetry_shell/requirements.txt` or `src/usr/share/opentelemetry_shell/agent.instrumentation.python/requirements.txt`
2. Check if the new version changes the minimum Python version requirement
3. If Python version requirement changed, update:
   - `meta/debian/control`: `Pre-Depends: ... python3 (>= X.Y) ...`
   - `meta/rpm/opentelemetry-shell.spec`: `Requires: ... python3 >= X.Y ...`
   - `meta/apk/APKBUILD`: if applicable
4. The `verify-deb-python-dependency` workflow will validate this

### Node.js dependency update
1. Update `src/usr/share/opentelemetry_shell/agent.instrumentation.node/package.json`
2. There is no `package-lock.json` committed — the lock file is generated during the CI build
3. Check if the new version changes the minimum Node.js version requirement
4. The build workflow tests Node.js versions 16-23

### Java dependency update
1. Update `src/usr/share/opentelemetry_shell/agent.instrumentation.java/pom.xml`
2. The POM is a dummy project that pulls in the OpenTelemetry Java agent as a dependency
3. The build compiles Java agents with `mvn dependency:resolve && javac && jar`

### System dependency update (new shell command used in source)
1. Add the package providing the command to:
   - `meta/debian/control` (Depends or Pre-Depends)
   - `meta/rpm/opentelemetry-shell.spec` (Requires) — note different package names across distributions
   - `meta/apk/APKBUILD` (depends) — note Alpine package names may differ
2. The `verify-deb-dependencies` workflow will catch missing Debian dependencies

## Package Name Mapping

Common differences between distributions:

| Tool | Debian package | RPM package | Alpine package |
|------|---------------|-------------|----------------|
| awk | awk | (gawk or mawk) | — |
| xxd | xxd | (xxd or vim-common or vim) | — |
| locale | libc-bin | glibc-common | — |
| ps | procps | procps | — |

## Rules

1. **Always update both language-specific AND package metadata** when dependencies change.
2. **Keep all three package formats in sync** (Debian, RPM, Alpine).
3. **No local builds**: The project builds via GitHub Actions. Dependency installation happens during CI build stages.
4. **Renovate**: The project uses Renovate for automated dependency updates (`/.github/renovate.json`). Coordinate with existing Renovate PRs when possible.
5. **Version pinning**: Python and Node.js dependencies use exact version pins in their respective files.
