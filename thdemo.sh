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
	export LZH_DEC="7z -y x "
	export ZIP_DEC=${LZH_DEC}
elif lhz >/dev/null; then
	export LZH_DEC="lhz xf "
else
	zenity --error --title "No lzh support?" --text "没找到解压 lzh 需要的 7z 或者 lhz 诶"
	exit 1
fi
if [ "$ZIP_DEC" = "" ]; then
       if ! bsdtar --version >/dev/null; then
	       zenity --error --title "No zip support?" --text "没找到解压 zip 需要的 7z 或者 bsdtar 诶"
	       exit 1
       fi
       export ZIP_DEC="bsdtar -xf "
fi
if ! convmv --list >/dev/null; then
	zenity --error --title "No convmv" --text "没找到 convmv 诶"
	exit 1
fi

if ! timidity >/dev/null; then
	zenity --warning --title "No timidity" --text "紅魔郷 妖々夢 永夜抄 花映塚 体验版需要 timidity 播放背景音乐"
fi


export WINEPREFIX="${WORK_DIR}/wine"
export WINEDLLOVERRIDES='mscoree,mshtml='
export WINEARCH='win32'

[ -d "$WORK_DIR" ] || mkdir -p "$WORK_DIR"

TH_NAMES='th06 "東方紅魔郷　～ the Embodiment of Scarlet Devil."
	th07 "東方妖々夢　～ Perfect Cherry Blossom."
	th08 "東方永夜抄　～ Imperishable Night."
	th09 "東方花映塚　～ Phantasmagoria of Flower View."
	th10 "東方風神録　～ Mountain of Faith."
	th11 "東方地霊殿　～ Subterranean Animism."
	th12 "東方星蓮船　～ Undefined Fantastic Object."
	th13 "東方神霊廟　～ Ten Desires."
	th14 "東方輝針城　～ Double Dealing Character."
	th15 "東方紺珠伝　～ Legacy of Lunatic Kingdom."'

while true; do
	game=$(eval zenity --list --hide-header --window-icon $SCRIPT_DIR/thdemo.xpm --print-column=1 --column com --column name $TH_NAMES)
	[ "$game" = "" ] && break

	echo ${game} selected
	${SCRIPT_DIR}/${game}.sh
done

exit 0

