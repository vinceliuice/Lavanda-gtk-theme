#!/bin/bash

readonly ROOT_UID=0
readonly MAX_DELAY=20 # max delay for user to enter root password

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKGROUND_DIR="/usr/share/backgrounds"
PROPERTIES_DIR="/usr/share/gnome-background-properties"

THEME_VARIANTS=('-wave' '-mountain')
COLOR_VARIANTS=('' '-Sea')

NAME='Lavanda'

#COLORS
CDEF=" \033[0m"                               # default color
CCIN=" \033[0;36m"                            # info color
CGSC=" \033[0;32m"                            # success color
CRER=" \033[0;31m"                            # error color
CWAR=" \033[0;33m"                            # waring color
b_CDEF=" \033[1;37m"                          # bold default color
b_CCIN=" \033[1;36m"                          # bold info color
b_CGSC=" \033[1;32m"                          # bold success color
b_CRER=" \033[1;31m"                          # bold error color
b_CWAR=" \033[1;33m"                          # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -t, --theme VARIANT     Specify theme variant(s) [wave|mountain] (Default: All variants)s)
  -c, --color VARIANT     Specify color variant(s) [purple|sea] (Default: All variants)s)
  -u, --uninstall         Uninstall wallpappers
  -h, --help              Show help
EOF
}

install() {
  local theme="$1"
  local color="$2"

  prompt -i "\n * Install ${NAME}${theme}${color} version in ${BACKGROUND_DIR}... "

  cp -a --no-preserve=ownership "${REPO_DIR}/wallpaper${theme}${color}"{'-Light','-Dark'}.png "${BACKGROUND_DIR}/${NAME}"
  cp -a --no-preserve=ownership "${REPO_DIR}/xml-files/timed-xml-files/${NAME}${theme}${color}-timed.xml" "${BACKGROUND_DIR}/${NAME}"
}

pre_install() {
  [[ -d "${BACKGROUND_DIR}/${NAME}" ]] && rm -rf "${BACKGROUND_DIR}/${NAME}"
  [[ -f "${PROPERTIES_DIR}/${NAME}.xml" ]] && rm -rf "${PROPERTIES_DIR}/${NAME}.xml"

  mkdir -p "${BACKGROUND_DIR}/${NAME}"
  cp -a --no-preserve=ownership "${REPO_DIR}/xml-files/gnome-background-properties/${NAME}.xml" "${PROPERTIES_DIR}"
}

uninstall() {
  local theme="$1"
  prompt -i "\n * Uninstall ${theme}... "
  [[ -d "${BACKGROUND_DIR}/${theme}" ]] && rm -rf "${BACKGROUND_DIR}/${theme}"
  [[ -f "${PROPERTIES_DIR}/${theme}.xml" ]] && rm -rf "${PROPERTIES_DIR}/${theme}.xml"
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -u|--uninstall)
      uninstall='true'
      shift
      ;;
    -t|--theme)
      shift
      for theme in "$@"; do
        case "$theme" in
          wave)
            themes+=("${THEME_VARIANTS[0]}")
            shift 1
            ;;
          mountain)
            themes+=("${THEME_VARIANTS[1]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "$@"; do
        case "$color" in
          purple)
            colors+=("${COLOR_VARIANTS[0]}")
            shift 1
            ;;
          sea)
            colors+=("${COLOR_VARIANTS[1]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized color variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

themes=()
colors=()

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[@]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

install_wallpaper() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      install "$theme" "$color"
    done
  done
  echo
}

uninstall_wallpaper() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      uninstall "$theme"
    done
  done
  echo
}

if [[ $UID -ne $ROOT_UID ]];  then
  echo
  prompt -e "ERROR: Need root access! please run this script with sudo."
  echo
  exit 1
fi

if [[ "${uninstall}" != 'true' ]]; then
  pre_install && install_wallpaper
else
  uninstall_wallpaper
fi

prompt -s "Finished!"
