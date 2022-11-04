#!/bin/sh

TH09_DIR="${WORK_DIR}/th09"
TH09_INST="${TH09_DIR}/kaei"

TH09_FILE='kaei_ver002.lzh'
TH09_LINKS='"http://s1.gptwm.com/s_alice/th090/kaei_ver002.lzh"'
TH09_MD5='e07878f414404ba2157c4f646ccf3708'

[ -d ${TH09_DIR} ] || mkdir ${TH09_DIR}

th09_check() {
	if [ -e "${TH09_DIR}/th09tr.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th09_run() {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH09_DIR}"

	if [ "$(ps -A | grep timidity)" = '' ] ; then
		timidity -iA &
		midi="1"
	fi

	LANG="ja_JP.UTF-8"

	wine th09tr.exe

	if [ "${midi}" = "1" ]; then
		killall timidity
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

th09_setup() {
	while [ "$(eval md5sum "${TH09_DIR}/${TH09_FILE}" | cut -d' ' -f1)" != "${TH09_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH09_LINKS})
		[ "$link" = "" ] && break

		curl ${link} --output ${TH09_DIR}/${TH09_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH09_DIR}

	if [ -e ${TH09_FILE} ] && [ -e ${TH09_UPDATE_FILE} ]; then
		eval LC_ALL=C ${LZH_DEC} ${TH09_FILE}
		rm ${TH09_FILE}

		cd ${TH09_DIR}

		for f in "custom.exe" "replayview.exe" "th09tr.exe" "th09tr.dat" "manual"; do
			ln -s "${TH09_INST}/${f}" "${TH09_DIR}/${f}"
		done

		echo "AAABAAIABAD//////////wMAWgBYABAAGwAmACgAJQAnABEALAAtACoAAQDIANAAywDNAB0AAAAB
AAIABAD//////////wMAWgBYABAAGwAmACgAJQAnABEALAAtACoAAQDIANAAywDNAB0AAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAkAWAJY
AgAAAgEBAQACAAAAAAECZFAAAAAAAAAAAAAAAAAAAAAA" | base64 -d > th09.cfg
	fi

	cd ${OLD_PWD}
}

[ "$(th09_check)" = "0" ] && th09_setup
[ "$(th09_check)" = "1" ] && th09_run

exit 0

