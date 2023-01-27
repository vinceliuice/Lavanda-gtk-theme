#! /usr/bin/env bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${REPO_DIR}/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_NAME=Lavanda
COLOR_VARIANTS=('' '-Light' '-Dark')
SIZE_VARIANTS=('' '-Compact')

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-28"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="42-0"
fi

usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

  -c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: All variants))

  -s, --size VARIANT      Specify size variant [standard|compact] (Default: standard variant)

  -l, --libadwaita        Link installed gtk-4.0 theme to config folder for all libadwaita app use this theme

  -r, --remove,
  -u, --uninstall         Uninstall/Remove installed themes or links

  -h, --help              Show help
EOF
}

install() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local size="${4}"

  [[ "${color}" == '-Light' ]] && local ELSE_LIGHT="${color}"
  [[ "${color}" == '-Dark' ]] && local ELSE_DARK="${color}"

  local THEME_DIR="${1}/${2}${3}${4}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                                   "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                  "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                           "${THEME_DIR}/index.theme"
  echo "Name=${2}${3}${4}" >>                                                                "${THEME_DIR}/index.theme"
  echo "Comment=An Clean Gtk+ theme based on Elegant Design" >>                              "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                   "${THEME_DIR}/index.theme"
  echo "" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                              "${THEME_DIR}/index.theme"
  echo "GtkTheme=${2}${3}${4}" >>                                                            "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${2}${3}${4}" >>                                                       "${THEME_DIR}/index.theme"
  echo "IconTheme=Tela-circle${ELSE_DARK:-}" >>                                              "${THEME_DIR}/index.theme"
  echo "CursorTheme=${2}-cursors" >>                                                         "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                        "${THEME_DIR}/index.theme"

  mkdir -p                                                                                   "${THEME_DIR}/gnome-shell"
  cp -r "${SRC_DIR}/main/gnome-shell/pad-osd.css"                                            "${THEME_DIR}/gnome-shell"
  sassc $SASSC_OPT "${SRC_DIR}/main/gnome-shell/gnome-shell${color}.scss"                    "${THEME_DIR}/gnome-shell/gnome-shell.css"

  cp -r "${SRC_DIR}/assets/gnome-shell/common-assets"                                        "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/assets${ELSE_DARK:-}/"*.svg                           "${THEME_DIR}/gnome-shell/assets"

  cd "${THEME_DIR}/gnome-shell"
  ln -s assets/no-events.svg no-events.svg
  ln -s assets/process-working.svg process-working.svg
  ln -s assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                                   "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/main/gtk-2.0/gtkrc${ELSE_DARK:-}"                                        "${THEME_DIR}/gtk-2.0/gtkrc"
  cp -r "${SRC_DIR}/main/gtk-2.0/common/"*'.rc'                                              "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets-common${ELSE_DARK:-}"                              "${THEME_DIR}/gtk-2.0/assets"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets${ELSE_DARK:-}/"*"png"                              "${THEME_DIR}/gtk-2.0/assets"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk/assets${ctype}"                                               "${THEME_DIR}/gtk-3.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/scalable"                                                     "${THEME_DIR}/gtk-3.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${ELSE_DARK:-}.png"                       "${THEME_DIR}/gtk-3.0/thumbnail.png"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk${color}.scss"                                "${THEME_DIR}/gtk-3.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk-Dark.scss"                                   "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/assets${ctype}"                                               "${THEME_DIR}/gtk-4.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/scalable"                                                     "${THEME_DIR}/gtk-4.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${ELSE_DARK:-}.png"                       "${THEME_DIR}/gtk-4.0/thumbnail.png"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk${color}.scss"                                "${THEME_DIR}/gtk-4.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk-Dark.scss"                                   "${THEME_DIR}/gtk-4.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/cinnamon"
  cp -r "${SRC_DIR}/assets/cinnamon/common-assets"                                           "${THEME_DIR}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/assets${ELSE_DARK:-}/"*'.svg'                            "${THEME_DIR}/cinnamon/assets"
  sassc $SASSC_OPT "${SRC_DIR}/main/cinnamon/cinnamon${color}.scss"                          "${THEME_DIR}/cinnamon/cinnamon.css"
  cp -r "${SRC_DIR}/assets/cinnamon/thumbnails/thumbnail${color}.png"                        "${THEME_DIR}/cinnamon/thumbnail.png"

  mkdir -p                                                                                   "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme-3.xml"                                    "${THEME_DIR}/metacity-1/metacity-theme-3.xml"
  cp -r "${SRC_DIR}/assets/metacity-1/assets"                                                "${THEME_DIR}/metacity-1/assets"
  cp -r "${SRC_DIR}/assets/metacity-1/thumbnail${ELSE_DARK:-}.png"                           "${THEME_DIR}/metacity-1/thumbnail.png"
  cd "${THEME_DIR}/metacity-1" && ln -s metacity-theme-3.xml metacity-theme-1.xml && ln -s metacity-theme-3.xml metacity-theme-2.xml

  mkdir -p                                                                                   "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${ELSE_LIGHT:-}/"*.png                                "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${ELSE_LIGHT:-}"                                       "${THEME_DIR}/xfwm4/themerc"
  mkdir -p                                                                                   "${THEME_DIR}-hdpi/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${ELSE_LIGHT:-}-hdpi/"*.png                           "${THEME_DIR}-hdpi/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${ELSE_LIGHT:-}"                                       "${THEME_DIR}-hdpi/xfwm4/themerc"
  sed -i "s/button_offset=6/button_offset=9/"                                                "${THEME_DIR}-hdpi/xfwm4/themerc"
  mkdir -p                                                                                   "${THEME_DIR}-xhdpi/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${ELSE_LIGHT:-}-xhdpi/"*.png                          "${THEME_DIR}-xhdpi/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${ELSE_LIGHT:-}"                                       "${THEME_DIR}-xhdpi/xfwm4/themerc"
  sed -i "s/button_offset=6/button_offset=12/"                                               "${THEME_DIR}-xhdpi/xfwm4/themerc"

  mkdir -p                                                                                   "${THEME_DIR}/plank"
  if [[ "$color" == '-Light' ]]; then
    cp -r "${SRC_DIR}/main/plank/theme-Light/"*                                              "${THEME_DIR}/plank"
  else
    cp -r "${SRC_DIR}/main/plank/theme-Dark/"*                                               "${THEME_DIR}/plank"
  fi
}

colors=()
lcolors=()
sizes=()

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "Destination directory does not exist. Let's make a new one..."
        mkdir -p ${dest}
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -r|--remove|-u|--uninstall)
      uninstall="true"
      shift
      ;;
    -l|--libadwaita)
      libadwaita="true"
      shift
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            lcolors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            lcolors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            lcolors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--size)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          compact)
            sizes+=("${SIZE_VARIANTS[1]}")
            compact='true'
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '${1:-}'."
            echo "Try '$0 --help' for more information."
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
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#lcolors[@]}" -eq 0 ]] ; then
  lcolors=("${COLOR_VARIANTS[1]}")
fi

if [[ "${#sizes[@]}" -eq 0 ]] ; then
  sizes=("${SIZE_VARIANTS[0]}")
fi

#  Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

#  Install needed packages
install_package() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo sassc needs to be installed to generate the css.
    if has_command zypper; then
      sudo zypper in sassc
    elif has_command apt-get; then
      sudo apt-get install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command pacman; then
      sudo pacman -S --noconfirm sassc
    fi
  fi
}


gnome_shell_version() {
  cp -rf ${SRC_DIR}/sass/gnome-shell/_common.scss ${SRC_DIR}/sass/gnome-shell/_common-temp.scss

  sed -i "/\widgets/s/40-0/${GS_VERSION}/" ${SRC_DIR}/sass/gnome-shell/_common-temp.scss

  if [[ "${GS_VERSION}" == '3-28' ]]; then
    sed -i "/\extensions/s/40-0/${GS_VERSION}/" ${SRC_DIR}/sass/gnome-shell/_common-temp.scss
  fi
}

uninstall_link() {
  rm -rf "${HOME}/.config/gtk-4.0/"{assets,gtk.css,gtk-dark.css}
}

link_libadwaita() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local size="${4}"

  local THEME_DIR="${1}/${2}${3}${4}"

  echo -e "\nLink '$THEME_DIR/gtk-4.0' to '${HOME}/.config/gtk-4.0' for libadwaita..."

  mkdir -p                                                                      "${HOME}/.config/gtk-4.0"
  ln -sf "${THEME_DIR}/gtk-4.0/assets"                                          "${HOME}/.config/gtk-4.0/assets"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css"                                         "${HOME}/.config/gtk-4.0/gtk.css"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk-dark.css"                                    "${HOME}/.config/gtk-4.0/gtk-dark.css"
}

link_theme() {
  for color in "${lcolors[@]}"; do
    for size in "${sizes[@]}"; do
      link_libadwaita "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$color" "$size"
    done
  done
}

install_theme() {
  for color in "${colors[@]}"; do
    for size in "${sizes[@]}"; do
      install "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$color" "$size"
    done
  done

  if [[ "$DESKTOP_SESSION" == 'xfce' ]]; then
    sed -i "s|.*menu-opacity=.*|menu-opacity=95|" "$HOME/.config/xfce4/panel/whiskermenu"*".rc"
  fi
}

uninstall() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local size="${4}"

  local THEME_DIR="${1}/${2}${3}${4}"

  if [[ -d "${THEME_DIR}" ]]; then
    echo -e "Uninstall ${THEME_DIR}... "
    rm -rf "${THEME_DIR}"
  fi
}

uninstall_theme() {
  for color in "${colors[@]}"; do
    for size in "${sizes[@]}"; do
      uninstall "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$color" "$size"
    done
  done
}

if [[ "$uninstall" == 'true' ]]; then
  if [[ "$libadwaita" == 'true' ]]; then
    echo -e "\nUninstall ${HOME}/.config/gtk-4.0 links ..."
    uninstall_link
  else
    echo && uninstall_theme && uninstall_link
  fi
else
  install_package && gnome_shell_version && install_theme
  if [[ "$libadwaita" == 'true' ]]; then
    uninstall_link && link_theme
  fi
fi

echo
echo Done.
