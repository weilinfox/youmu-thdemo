#!/bin/sh

TH06_DIR="${WORK_DIR}/th06"
TH06_INST="${TH06_DIR}/東方紅魔郷　体験版"

TH06_FILE='kouma_tr013.lzh'
TH06_LINKS='"https://www16.big.or.jp/~zun/data/soft/kouma_tr013.lzh"
	"http://s1.gptwm.com/s_alice/th060/kouma_tr013.lzh"'
TH06_MD5='7ea4be414a7f256429a2c5e4666c9881'

[ -d ${TH06_DIR} ] || mkdir ${TH06_DIR}

function th06_check {
	if [ -e "${TH06_DIR}/東方紅魔郷.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

function th06_run {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH06_DIR}"
	if [ "$(ps -A | grep timidity)" == '' ] ; then
		timidity -iA &
		midi="1"
	fi

	LANG="ja_JP.UTF-8"

	wine 東方紅魔郷.exe

	if [ "${midi}" == "1" ]; then
		killall timidity
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

function th06_setup {
	while [ "$(eval md5sum "${TH06_DIR}/${TH06_FILE}" | cut -d' ' -f1)" != "${TH06_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH06_LINKS})
		[ "$link" = "" ] && break

		curl ${link} --output ${TH06_DIR}/${TH06_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH06_DIR}

	if [ -e ${TH06_FILE} ]; then
		eval LC_ALL=C ${LZH_DEC} ${TH06_FILE}
		rm ${TH06_FILE}
		convmv -f CP932 -t UTF-8 -r --notest .

		ln -s "${TH06_INST}/custom.exe" "${TH06_DIR}/"
		ln -s "${TH06_INST}/東方紅魔郷.exe" "${TH06_DIR}/"
		for i in CM IN MD ST TL; do
			ln -s "${TH06_INST}/紅魔郷$i.DAT" "${TH06_DIR}/"
		done

		echo AAABAAAA////////////////AAACAQAAAgMAAgEBAQBYAlgCAAAAAAAAAAAAAAAAAAAAAAEAAAA= | base64 -d > 東方紅魔郷.cfg
	fi

	cd ${OLD_PWD}
}

[ "$(th06_check)" = "0" ] && th06_setup
[ "$(th06_check)" = "1" ] && th06_run

exit 0

