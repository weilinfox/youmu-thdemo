#!/bin/sh

TH08_DIR="${WORK_DIR}/th08"
TH08_INST="${TH08_DIR}/eiya"

TH08_FILE='eiya_tr003.lzh'
TH08_UPDATE_FILE='eiya_update003a.lzh'
TH08_LINKS='"http://s1.gptwm.com/s_alice/th080/eiya_tr003.lzh"'
TH08_UPDATE_LINKS='"http://www16.big.or.jp/~zun/data/soft/eiya_update003a.lzh"
	"http://s1.gptwm.com/s_alice/th080/eiya_update003a.lzh"'
TH08_MD5='c42647202a695bd1fdd2d88ce6615d53'
TH08_UPDATE_MD5='1e21a0489ccdc102e48bcdd91d060f64'

[ -d ${TH08_DIR} ] || mkdir ${TH08_DIR}

th08_check() {
	if [ -e "${TH08_DIR}/th08tr.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th08_run() {
	OLD_PWD=$(pwd)

	cd "${TH08_DIR}"

	if [ "$(ps -A | grep timidity)" = '' ] ; then
		timidity -iA &
		midi="1"
	fi

	LC_ALL="${TMP_LOCALE}" wine th08tr.exe

	if [ "${midi}" = "1" ]; then
		killall timidity
	fi

	cd ${OLD_PWD}
}

th08_custom() {
	OLD_PWD=$(pwd)

	cd "${TH08_DIR}"

	LC_ALL="${TMP_LOCALE}" wine custom.exe

	cd ${OLD_PWD}
}

th08_setup() {
	while [ "$(eval md5sum "${TH08_DIR}/${TH08_FILE}" | cut -d' ' -f1)" != "${TH08_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH08_LINKS})
		[ "$link" = "" ] && break

		curl ${link} --output ${TH08_DIR}/${TH08_FILE}
	done

	while [ "$(eval md5sum "${TH08_DIR}/${TH08_UPDATE_FILE}" | cut -d' ' -f1)" != "${TH08_UPDATE_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH08_UPDATE_LINKS})
		[ "$link" = "" ] && break

		curl ${link} --output ${TH08_DIR}/${TH08_UPDATE_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH08_DIR}

	if [ -e ${TH08_FILE} ] && [ -e ${TH08_UPDATE_FILE} ]; then
		eval LC_ALL=C ${LZH_DEC} ${TH08_FILE}
		eval LC_ALL=C ${LZH_DEC} ${TH08_UPDATE_FILE}
		rm ${TH08_FILE} ${TH08_UPDATE_FILE}
		convmv -f CP932 -t UTF-8 -r --notest .
		mv eiya_update003a.EXE "${TH08_INST}/"

		cd ${TH08_INST}
		LC_ALL="${TMP_LOCALE}" wine eiya_update003a.EXE

		for f in "custom.exe" "replayview.exe" "th08tr.exe" "th08tr.dat" "マニュアル"; do
			ln -s "${TH08_INST}/${f}" "${TH08_DIR}/${f}"
		done

		cd ${TH08_DIR}
		echo "AAABAAIABAD//////////wMAAAABAAgAWAJYAgIDAAIBAQEAAgAAZFAAAAAAAAAAAAAAAAAAAAAB
AAAA" | base64 -d > th08.cfg
	fi

	cd ${OLD_PWD}
}

if [ "$1" = "directory" ]; then
	xdg-open ${TH08_DIR}
elif [ "$1" = "custom" ]; then
	[ "$(th08_check)" = "0" ] && zenity --question --title "是否安装" --text "似乎没有安装诶，要先安装咩？" && th08_setup
	[ "$(th08_check)" = "1" ] && th08_custom
else
	[ "$(th08_check)" = "0" ] && th08_setup
	[ "$(th08_check)" = "1" ] && th08_run
fi

exit 0

