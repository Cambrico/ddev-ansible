setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/ddev-ansible
  mkdir -p $TESTDIR
  export PROJNAME=ddev-ansible
  export DDEV_NONINTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  # Ensure the ansible commands are available
  ddev exec "ansible --version" | grep "executable location = /usr/bin/ansible"
  ddev exec "ansible-community --version" | grep "Ansible community version"
  ddev exec "ansible-config --version" | grep "executable location = /usr/bin/ansible-config"
  ddev exec "ansible-connection --version" | grep "executable location = /usr/bin/ansible-connection"
  ddev exec "ansible-console --version" | grep "executable location = /usr/bin/ansible-console"
  ddev exec "ansible-doc --version" | grep "executable location = /usr/bin/ansible-doc"
  ddev exec "ansible-galaxy --version" | grep "executable location = /usr/bin/ansible-galaxy"
  ddev exec "ansible-inventory --version" | grep "executable location = /usr/bin/ansible-inventory"
  ddev exec "ansible-playbook --version" | grep "executable location = /usr/bin/ansible-playbook"
  ddev exec "ansible-pull --version" | grep "executable location = /usr/bin/ansible-pull"
  ddev exec "ansible-test --version" | grep "ansible-test version"
  ddev exec "ansible-vault --version" | grep "executable location = /usr/bin/ansible-vault"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev add-on get facine/ddev-ansible with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get facine/ddev-ansible
  ddev restart >/dev/null
  health_checks
}
