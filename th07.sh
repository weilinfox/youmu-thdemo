#!/bin/sh

TH07_DIR="${WORK_DIR}/th07"
TH07_INST="${TH07_DIR}/youmu"

TH07_FILE='youmu_tr011.lzh'
TH07_LINKS='"https://www16.big.or.jp/~zun/data/soft/youmu_tr011.lzh"
	"http://s1.gptwm.com/s_alice/th070/youmu_tr011.lzh"'
TH07_MD5='05360e859c1a3ca173b9d57d96a45b9b'

[ -d ${TH07_DIR} ] || mkdir ${TH07_DIR}

th07_check() {
	if [ -e "${TH07_DIR}/th07.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th07_run() {
	OLD_PWD=$(pwd)

	cd "${TH07_DIR}"

	if [ "$(ps -A | grep timidity)" = '' ] ; then
		timidity -iA &
		midi="1"
	fi

	LC_ALL="${TMP_LOCALE}" wine th07.exe

	if [ "${midi}" = "1" ]; then
		killall timidity
	fi

	cd ${OLD_PWD}
}

th07_setup() {
	while [ "$(eval md5sum "${TH07_DIR}/${TH07_FILE}" | cut -d' ' -f1)" != "${TH07_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH07_LINKS})
		[ "$link" = "" ] && break

		curl ${link} --output ${TH07_DIR}/${TH07_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH07_DIR}

	if [ -e ${TH07_FILE} ]; then
		eval LC_ALL=C ${LZH_DEC} ${TH07_FILE}
		rm ${TH07_FILE}
		convmv -f CP932 -t UTF-8 -r --notest .

		for f in "custom.exe" "th07.exe" "th07tr.dat" "マニュアル"; do
			ln -s "${TH07_INST}/${f}" "${TH07_DIR}/${f}"
		done

		echo AAABAAIABAD//////////wMAAAACAAcAWAJYAgIDAAIBAQEAAgABAAAAAAAAAAAAAAAAAAEAAAA= | base64 -d > th07.cfg
	fi

	cd ${OLD_PWD}
}

[ "$(th07_check)" = "0" ] && th07_setup
[ "$(th07_check)" = "1" ] && th07_run

exit 0

