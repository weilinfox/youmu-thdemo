#!/bin/sh

# 白玉楼製作所

# https://www16.big.or.jp/~zun/
# http://s1.gptwm.com/s_alice/index.html

[ -f "$0" ] && SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
if [ -h "$0" ]; then
	rpath="$(dirname $(readlink "$0"))"
	if [ "${rpath##/*}" != "" ]; then
		SCRIPT_DIR="$(cd "$(dirname "$0")/${rpath}"; pwd)"
	else
		SCRIPT_DIR="$(cd "${rpath}"; pwd)"
	fi
fi

APP_NAME="th-demo"

export WORK_DIR="${HOME}/.${APP_NAME}"

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
if ! iconv --help >/dev/null; then
	zenity --error --title "No iconv" --text "没找到 iconv 诶"
	exit 1
fi

if ! timidity >/dev/null; then
	zenity --warning --title "No timidity" --text "紅魔郷 妖々夢 永夜抄 花映塚 体验版需要 timidity 播放背景音乐"
fi

if ! xdg-open --help >/dev/null; then
	zenity --warning --title "No xdg-open" --text "没有找到 xdg-open 诶"
fi

if [ "$(locale -a | grep "ja_JP.utf8")" != "" ]; then
	export TMP_LOCALE="ja_JP.UTF-8"
elif [ "$(locale -a | grep "zh_CN.utf8")" != "" ]; then
	export TMP_LOCALE="zh_CN.UTF-8"
else
	zenity --error --title "No locale support" --text "没有支持的 locale"
	exit 1
fi

export WINEPREFIX="${WORK_DIR}/wine"
export WINEDLLOVERRIDES='mscoree,mshtml='
# export WINEARCH='win32'
# export WINEDEBUG=+font

# Setup wine environment
if [ ! -d "${WINEPREFIX}" ]; then
	mkdir -p "${WINEPREFIX}"

	# 1. Font
	#   th06 use PMingLiU
	#   th07+ use ＭＳ ゴシック
	# 2. Grab cursor when full screen
	font=$(fc-match ':lang=ja' -f '%{family[0]}')
	cat >"${WINEPREFIX}/thcfg_utf-8.reg"<<EOF
REGEDIT4

[HKEY_CURRENT_USER\\Software\\Wine\\Fonts\\Replacements]
"PMingLiU"="${font}"
"ＭＳ ゴシック"="${font}"

[HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver]
"GrabFullscreen"="Y"
EOF
	echoe=
	[ "$(echo -n -e)" != "-e" ] && echoe="-e"
	echo -n ${echoe} "\0777\0776" > "${WINEPREFIX}/thcfg.reg"
	iconv --from-code UTF-8 --to-code UTF-16LE "${WINEPREFIX}/thcfg_utf-8.reg" >> "${WINEPREFIX}/thcfg.reg"
	rm "${WINEPREFIX}/thcfg_utf-8.reg"

	wine regedit "${WINEPREFIX}/thcfg.reg"
fi

MENU='"game" "启动游戏"
	"custom" "启动 custom.exe"
	"game-dir" "打开游戏目录"
	"wine" "显示 Wine 配置"
	"wine-dir" "打开 Wine 目录"
	"about" "关于"'

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
	func=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --print-column=1 --hide-column=1 --column Print --column Menu $MENU)
	[ "$func" = "" ] && break

	param=
	game=
	if [ "$func" = "wine" ]; then
		winecfg
	elif [ "$func" = "wine-dir" ]; then
		xdg-open $WINEPREFIX
	elif [ "$func" = "about" ]; then
		zenity --info --title "白玉楼製作所" --text "白玉楼製作所 thdemo\nyoumu c 2022"
	else
		[ "$func" = "custom" ] && param="custom"
		[ "$func" = "game-dir" ] && param="directory"
		game=$(eval zenity --list --hide-header --window-icon $SCRIPT_DIR/thdemo.xpm --print-column=1 --column com --column name $TH_NAMES)
	fi
	[ "$game" = "" ] && continue

	echo ${game} selected
	${SCRIPT_DIR}/${game}.sh $param
done

exit 0

