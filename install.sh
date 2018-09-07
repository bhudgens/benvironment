main() {
  URL_PATH_TO_ENV_FILES="https://raw.githubusercontent.com/bhudgens/benvironment/master"
  FILE=".benvironment"
  curl -s "${URL_PATH_TO_ENV_FILES}/${FILE}" -o "${HOME}/${FILE}"
  ENVS=".zshrc .bashrc"
  for env_file in $(echo $ENVS); do
    if ! grep "${FILE}" "${HOME}/${env_file}" > /dev/null; then
      echo Installing benvironment into ${env_file}
      echo "source ${FILE}" >> "${HOME}/${env_file}"
    fi
  done
  echo All Done! Open a new window!
}

main
