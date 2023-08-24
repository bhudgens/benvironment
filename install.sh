
function _osType() {
  local _type="$1"
  echo "$OSTYPE" | grep "$_type" > /dev/null
}

function _commandExists() {
  local _cmd="$1"
  which "$_cmd" > /dev/null
}

main() {
  BENVIRONMENT_LOAD_FILE=".benvironment"
  if _osType linux \
    && _commandExists apt-get; then

  for _command in curl zsh git; do
    if ! _commandExists _command; then
      APPS_TO_INSTALL="$APPS_TO_INSTALL $_command"
    fi
  done

  if [ -n "$APPS_TO_INSTALL" ]; then
    [ "$EUID" -ne 0 ] && SUDO="sudo "
    eval "$SUDO apt-get update -y"
    eval "$SUDO apt-get install -y $APPS_TO_INSTALL"
  fi

  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  URL_PATH_TO_ENV_FILES="https://raw.githubusercontent.com/bhudgens/benvironment/master"
  if [ -f "./${BENVIRONMENT_LOAD_FILE}" ]; then
    cp "./${BENVIRONMENT_LOAD_FILE}" "${HOME}/${BENVIRONMENT_LOAD_FILE}"
  else
    curl -s "${URL_PATH_TO_ENV_FILES}/${BENVIRONMENT_LOAD_FILE}" -o "${HOME}/${BENVIRONMENT_LOAD_FILE}"
  fi

  echo Installing benvironment into ${env_file}
  echo "source ${BENVIRONMENT_LOAD_FILE}" >> "${HOME}/.zshrc"
  echo All Done! Open a new window!
}

main
