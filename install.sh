
function _osType() {
  local _type="$1"
  echo "$OSTYPE" | grep "$_type" > /dev/null
}

function _commandExists() {
  local _cmd="$1"
  which "$_cmd" > /dev/null
}

for _command in curl zsh git; do
  if _osType linux \
  && _commandExists apt-get \
  && ! _commandExists _command; then
    APPS_TO_INSTALL="$APPS_TO_INSTALL $_command"
  fi
done

if [ -n "$APPS_TO_INSTALL" ]; then
  [ "$EUID" -ne 0 ] && SUDO="sudo "
  eval "$SUDO apt-get update -y"
  eval "$SUDO apt-get install -y $APPS_TO_INSTALL"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

main() {
  URL_PATH_TO_ENV_FILES="https://raw.githubusercontent.com/bhudgens/benvironment/master"
  FILE=".benvironment"
  curl -s "${URL_PATH_TO_ENV_FILES}/${FILE}" -o "${HOME}/${FILE}"
  ENVS=".zshrc"
  for env_file in $(echo $ENVS); do
    if ! grep "${FILE}" "${HOME}/${env_file}" > /dev/null; then
      echo Installing benvironment into ${env_file}
      echo "source ${FILE}" >> "${HOME}/${env_file}"
    fi
  done
  echo All Done! Open a new window!
}

main
