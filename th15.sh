#!/bin/sh

TH15_DIR="${WORK_DIR}/th15"
TH15_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方紺珠伝体験版"
TH15_DATA="${WINEPREFIX}/drive_c/users/${USER}/AppData/Roaming/ShanghaiAlice/th15tr"

TH15_FILE='setup_th15_001b.zip'
TH15_LINKS='"http://mirror.studio-ramble.com/upload/nolook/ShanghaiAlice/83dccc60c17d2b9fc25ccb713ee06078/setup_th15_001b.zip"
	"http://s1.gptwm.com/s_alice/th150/setup_th15_001b.zip"'
TH15_MD5='83dccc60c17d2b9fc25ccb713ee06078'

[ -d ${TH15_DIR} ] || mkdir ${TH15_DIR}
[ -d ${TH15_DATA} ] || mkdir ${TH15_DATA}

th15_check() {
	if [ -e "${TH15_DIR}/th15.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th15_run() {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH15_DIR}"
	LANG="ja_JP.UTF-8"

	if [ -e "th15.exe" ]; then
		wine th15.exe
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

th15_setup() {
	while [ "$(eval md5sum "${TH15_DIR}/${TH15_FILE}" | cut -d' ' -f1)" != "${TH15_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH15_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH15_DIR}/${TH15_FILE}
	done

	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd ${TH15_DIR}

	if [ -e ${TH15_FILE} ]; then
		eval ${ZIP_DEC} ${TH15_FILE}
		LANG='ja_JP.UTF-8'

		wine setup_th15_001b.exe

		if [ -d "${TH15_INST}" ]; then
			rm ${TH15_FILE}
			rm setup_th15_001b.exe
			for f in "custom.exe" "th15tr.dat" "th15.exe" "thbgm_tr.dat"; do
				ln -s "${TH15_INST}/${f}" "${TH15_DIR}/${f}"
			done

			ln -s "${TH15_DATA}" "${TH15_DIR}/th15tr_data"
			echo "AgAVAAAAAQACAAUA/////////////wMAWAJYAgABAQUAAmRQAAIAAAEAAAAAAAAABwAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" | base64 -d > "${TH15_DIR}/th15tr_data/th15.cfg"

			zenity --info --title "Success" --text "東方紺珠伝 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
	LANG=${OLD_LANG}
}

[ "$(th15_check)" = "0" ] && th15_setup
[ "$(th15_check)" = "1" ] && th15_run

exit 0

