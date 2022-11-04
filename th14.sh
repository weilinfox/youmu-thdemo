#!/bin/sh

TH14_DIR="${WORK_DIR}/th14"
TH14_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方輝針城体験版"
TH14_DATA="${WINEPREFIX}/drive_c/users/${USER}/AppData/Roaming/ShanghaiAlice/th14tr"

TH14_FILE='setup_th14_001b.zip'
TH14_LINKS='"http://oic.storage-service.jp:8080/shanghaialice/setup_th14_001b.zip"
	"http://kokoron.madoka.org/mirror/D/t/touhoukishinjou/setup_th14_001b.zip"
	"http://s1.gptwm.com/s_alice/th140/setup_th14_001b.zip"'
TH14_MD5='51ec6d98a1b0c8186442857fcfe91274'

[ -d ${TH14_DIR} ] || mkdir ${TH14_DIR}
[ -d ${TH14_DATA} ] || mkdir ${TH14_DATA}

function th14_check {
	if [ -e "${TH14_DIR}/th14.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

function th14_run {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH14_DIR}"
	LANG="ja_JP.UTF-8"

	if [ -e "th14.exe" ]; then
		wine th14.exe
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

function th14_setup {
	while [ "$(eval md5sum "${TH14_DIR}/${TH14_FILE}" | cut -d' ' -f1)" != "${TH14_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH14_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH14_DIR}/${TH14_FILE}
	done

	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd ${TH14_DIR}

	if [ -e ${TH14_FILE} ]; then
		eval ${ZIP_DEC} ${TH14_FILE}
		LANG='ja_JP.UTF-8'

		wine setup_th14_001b.exe

		if [ -d "${TH14_INST}" ]; then
			rm ${TH14_FILE}
			rm setup_th14_001b.exe
			for f in "custom.exe" "th14tr.dat" "th14.exe" "thbgm_tr.dat"; do
				ln -s "${TH14_INST}/${f}" "${TH14_DIR}/${f}"
			done

			ln -s "${TH14_DATA}" "${TH14_DIR}/th14tr_data"
			echo "AgAUAAAAAQACAAUA/////////////wMAWAJYAgABAQUAAmRQAAIAAAAAAAAHAAAAAAAAAAAAAAAB
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" | base64 -d > "${TH14_DIR}/th14tr_data/th14.cfg"

			zenity --info --title "Success" --text "東方輝針城 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
	LANG=${OLD_LANG}
}

[ "$(th14_check)" = "0" ] && th14_setup
[ "$(th14_check)" = "1" ] && th14_run

exit 0

