ARG image
ARG update
ARG shell

FROM $image
ARG shell
ARG update
WORKDIR /tests
COPY . ./

RUN <<EOF
  packages_mandatory="jq psmisc wget curl time sudo"
  packages_optional="parallel moreutils ncat wget2 nodejs npm python3 python3-pip gcc default-jdk-headless jdk"
  if type apt-get; then
    apt-get update
    [ "$update" = TRUE ] && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y || true
    type "$shell" || DEBIAN_FRONTEND=noninteractive apt-get install -y "$shell"
    DEBIAN_FRONTEND=noninteractive apt-get install -y $packages_mandatory debconf debconf-utils python3-venv
    DEBIAN_FRONTEND=noninteractive apt-get install -y $packages_optional || true
    DEBIAN_FRONTEND=noninteractive apt-get install -y ./package.deb && rm ./package.deb
  elif type dnf; then
    [ "$update" = TRUE ] && dnf -y upgrade --refresh
    type "$shell" || dnf -y install "$shell"
    dnf -y install --allowerasing $packages_mandatory
    for package in $packages_optional; do dnf -y install --allowerasing $package || true; done
    dnf -y install ./package.rpm
  elif type yum; then
    [ "$update" = TRUE ] && yum -y upgrade
    type "$shell" || yum -y install "$shell"
    yum -y install --allowerasing $packages_mandatory
    for package in $packages_optional; do yum -y install --allowerasing $package || true; done
    yum -y install ./package.rpm
  elif type zypper; then
    [ "$update" = TRUE ] && zypper --non-interactive update
    type "$shell" || zypper --non-interactive install "$shell"
    zypper --non-interactive install $packages_mandatory
    for package in $packages_optional; do zypper --non-interactive install $package || true; done
    zypper --non-interactive install --allow-unsigned-rpm ./package.rpm
  else
    exit 1
  fi
EOF

ENV shell="$shell"

CMD ! type "$shell" || bash run_tests.sh "$shell"
