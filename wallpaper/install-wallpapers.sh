#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WALLPAPER_DIR="$HOME/.local/share/backgrounds"

THEME_VARIANTS=('-wave' '-mountain')
COLOR_VARIANTS=('-Light' '-Dark')
TYPE_VARIANTS=('' '-Sea')

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
  -u, --uninstall         Uninstall wallpappers
  -h, --help              Show help
EOF
}

install() {
  local theme="$1"
  local type="$2"
  local color="$3"

  local wallpaper="${WALLPAPER_DIR}/wallpaper${theme}${type}${color}.png"

  prompt -i "\n * Install wallpaper${theme}${type}${color}.png in ${WALLPAPER_DIR}... "

  mkdir -p "${WALLPAPER_DIR}"

  [[ -f "${wallpaper}" ]] && rm -rf "${wallpaper}"
  cp -a --no-preserve=ownership "${REPO_DIR}/wallpaper${theme}${type}${color}.png" "${WALLPAPER_DIR}"
}

uninstall() {
  local theme="$1"
  local color="$2"
  local type="$3"

  local wallpaper="${WALLPAPER_DIR}/wallpaper${theme}${type}${color}.png"

  prompt -i "\n * Uninstall wallpaper${theme}${type}${color}.png... "

  [[ -f "${wallpaper}" ]] && rm -rf "${wallpaper}"
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -u|--uninstall)
      uninstall='true'
      shift
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

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[@]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#types[@]}" -eq 0 ]] ; then
  types=("${TYPE_VARIANTS[@]}")
fi

install_wallpaper() {
  for theme in "${themes[@]}"; do
    for type in "${types[@]}"; do
      for color in "${colors[@]}"; do
        install "$theme" "$type" "$color"
      done
    done
  done
}

uninstall_wallpaper() {
  for theme in "${themes[@]}"; do
    for type in "${types[@]}"; do
      for color in "${colors[@]}"; do
        uninstall "$theme" "$type" "$color"
      done
    done
  done
}

if [[ "${uninstall}" != 'true' ]]; then
  install_wallpaper
else
  uninstall_wallpaper
fi
prompt -s "\n * All done!"
echo

