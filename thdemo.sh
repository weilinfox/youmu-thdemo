#!/bin/sh

# https://www16.big.or.jp/~zun/
# http://s1.gptwm.com/s_alice/index.html

SCRIPT_DIR=$(cd $(dirname "$0"); pwd)
APP_NAME="th-demo"

export WORK_DIR="${HOME}/.local/share/${APP_NAME}"

if ! zenity --version >/dev/null; then
	echo It needs zenity to show dialog.
	exit 1
fi
if ! curl --version >/dev/null; then
	zenity --error --title "No Curl?" --text "没找到 curl 诶"
	exit 1
fi
if ! wine --version >/dev/null; then
	zenity --error --title "No wine?" --text "没找到 Wine 诶"
	exit 1
fi
if 7z >/dev/null; then
	export LZH_DEC="7z x"
elif lhz >/dev/null; then
	export LZH_DEC="lhz x"
else
	zenity --error --title "No lzh support?" --text "没找到解压 lzh 需要的 7z 或者 lhz 诶"
fi
if ! convmv --list >/dev/null; then
	zenity --error --title "No convmv" --text "没找到 convmv 诶"
	exit 1
fi

if ! timidity >/dev/null; then
	zenity --warning --title "No timidity" --text "妖々夢 紅魔郷 体验版需要 timidity 播放背景音乐"
fi


export WINEPREFIX="${WORK_DIR}/wine"
export WINEDLLOVERRIDES='mscoree,mshtml='
export WINEARCH='win32'

[ -d "$WORK_DIR" ] || mkdir -p "$WORK_DIR"

TH_NAMES='th06 "東方紅魔郷　～ the Embodiment of Scarlet Devil."
	th07 "東方妖々夢　～ Perfect Cherry Blossom."
	th10 "東方風神録　～ Mountain of Faith."'

while true; do
	game=$(eval zenity --list --hide-header --window-icon $SCRIPT_DIR/thdemo.xpm --print-column=1 --column com --column name $TH_NAMES)
	[ "$game" = "" ] && break

	echo ${game} selected
	${SCRIPT_DIR}/${game}.sh
done

exit 0

