#checkov:skip=CKV_DOCKER_3:This image is intended for local test execution and tests run as root
ARG image
ARG update
ARG shell

FROM $image
ARG shell
ARG update
WORKDIR /tests
COPY . ./

# this is a throwaway test image for many distributions, so apt packages are intentionally unpinned
# this is a throwaway test image for many distributions, so the apt lists are intentionally not deleted
# this is a throwaway test image for many distributions, so the apk cache rule is intentionally not applied
# this is a throwaway test image for many distributions, so yum caches are intentionally not cleaned
# this is a throwaway test image for many distributions, so yum packages are intentionally unpinned
# this is a throwaway test image for many distributions, so zypper packages are intentionally unpinned
# this is a throwaway test image for many distributions, so dnf caches are intentionally not cleaned
# this is a throwaway test image for many distributions, so dnf packages are intentionally unpinned
# this is a throwaway test image for many distributions, so pipefail is intentionally not set
# this is a throwaway test image for many distributions, so the word splitting of the package lists is intended
# hadolint ignore=DL3015,DL3008,DL3009,DL3019,DL3032,DL3033,DL3037,DL3040,DL3041,DL4006,SC2086
RUN <<EOF
  packages_mandatory="jq psmisc wget curl time sudo bash"
  packages_optional="parallel moreutils ncat wget2 nodejs npm python3 python3-pip gcc default-jdk-headless jdk"
  if type apt-get; then
    apt-get update
    [ "$update" = TRUE ] && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y || true
    type "$shell" || DEBIAN_FRONTEND=noninteractive apt-get install -y "$shell"
    DEBIAN_FRONTEND=noninteractive apt-get install -y $packages_mandatory debconf debconf-utils python3-venv
    DEBIAN_FRONTEND=noninteractive apt-get install -y $packages_optional || true
    DEBIAN_FRONTEND=noninteractive apt-get install -y ./opentelemetry-shell_*_"$(arch | sed s/x86_64/amd64/g | sed s/aarch64/arm64/g | sed 's/le$/el/g')".deb
  elif type dnf; then
    [ "$update" = TRUE ] && dnf -y upgrade --refresh
    type "$shell" || dnf -y install "$shell"
    dnf -y install --allowerasing $packages_mandatory
    for package in $packages_optional; do dnf -y install --allowerasing $package || true; done
    dnf -y install ./opentelemetry-shell-*."$(arch)".rpm
  elif type yum; then
    [ "$update" = TRUE ] && yum -y upgrade
    type "$shell" || yum -y install "$shell"
    yum -y install --allowerasing $packages_mandatory
    for package in $packages_optional; do yum -y install --allowerasing $package || true; done
    yum -y install ./opentelemetry-shell-*."$(arch)".rpm
  elif type zypper; then
    [ "$update" = TRUE ] && zypper --non-interactive update
    type "$shell" || zypper --non-interactive install "$shell"
    zypper --non-interactive install $packages_mandatory
    for package in $packages_optional; do zypper --non-interactive install $package || true; done
    zypper --non-interactive install --allow-unsigned-rpm ./opentelemetry-shell-*."$(arch)".rpm
    zypper clean --all
  elif type apk; then
    [ "$update" = TRUE ] && apk upgrade
    type "$shell" || apk add "$shell"
    for package in $packages_mandatory; do apk add $package || true; done
    for package in $packages_optional; do apk add $package || true; done
    apk add --allow-untrusted ./*.apk
  else
    exit 1
  fi
EOF

ENV shell="$shell"

# the exit code of the test run must depend on the shell being available, which needs shell syntax
# hadolint ignore=DL3025
CMD ! type "$shell" || bash run_tests.sh "$shell"

HEALTHCHECK NONE
