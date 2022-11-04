#!/bin/sh

TH12_DIR="${WORK_DIR}/th12"
TH12_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方星蓮船体験版"

TH12_FILE='th12tr002a_setup.exe'
TH12_LINKS='"http://mirror.studio-ramble.com/upload/535/200907/th12tr002a_setup.exe"
	"http://s1.gptwm.com/s_alice/th120/th12tr002a_setup.exe"'
TH12_MD5='61a77c94c2ef64d7afda477dda0594eb'

[ -d ${TH12_DIR} ] || mkdir ${TH12_DIR}

th12_check() {
	if [ -e "${TH12_DIR}/th12.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th12_run() {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH12_DIR}"
	LANG="ja_JP.UTF-8"

	if [ -e "th12.exe" ]; then
		wine th12.exe
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

th12_setup() {
	while [ "$(eval md5sum "${TH12_DIR}/${TH12_FILE}" | cut -d' ' -f1)" != "${TH12_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH12_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH12_DIR}/${TH12_FILE}
	done

	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd ${TH12_DIR}

	if [ -e ${TH12_FILE} ]; then
		LANG='ja_JP.UTF-8'

		wine ${TH12_FILE}

		if [ -d "${TH12_INST}" ]; then
			rm ${TH12_FILE}
			for f in "custom.exe" "th12tr.dat" "th12.exe" "thbgm_tr.dat" "マニュアル"; do
				ln -s "${TH12_INST}/${f}" "${TH12_DIR}/${f}"
			done

			echo "AQASAAAAAQACAAQA//////////8DAFgCWAIAAQEDAAJkUAACAAAAAAAAAAAHAAAAAAAAAAAAAAAA
AAAA" | base64 -d > th12.cfg

			zenity --info --title "Success" --text "東方星蓮船 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
	LANG=${OLD_LANG}
}

[ "$(th12_check)" = "0" ] && th12_setup
[ "$(th12_check)" = "1" ] && th12_run

exit 0

