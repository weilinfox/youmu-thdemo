#!/bin/sh

TH13_DIR="${WORK_DIR}/th13"
TH13_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方神霊廟体験版"
TH13_DATA="${WINEPREFIX}/drive_c/users/${USER}/AppData/Roaming/ShanghaiAlice/th13tr"

TH13_FILE='th13tr001a_setup.exe'
TH13_LINKS='"http://mirror.studio-ramble.com/upload/535/201104/th13tr001a_setup.exe"
	"http://kokoron.madoka.org/mirror/D/t/touhoushinreibyou/th13tr001a_setup.exe"
	"http://s1.gptwm.com/s_alice/th130/th13tr001a_setup.exe"'
TH13_MD5='5336b10545fd0b6cb0eb38c97199e9bc'

[ -d ${TH13_DIR} ] || mkdir ${TH13_DIR}
[ -d ${TH13_DATA} ] || mkdir ${TH13_DATA}

function th13_check {
	if [ -e "${TH13_DIR}/th13.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

function th13_run {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH13_DIR}"
	LANG="ja_JP.UTF-8"

	if [ -e "th13.exe" ]; then
		wine th13.exe
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

function th13_setup {
	while [ "$(eval md5sum "${TH13_DIR}/${TH13_FILE}" | cut -d' ' -f1)" != "${TH13_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH13_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH13_DIR}/${TH13_FILE}
	done

	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd ${TH13_DIR}

	if [ -e ${TH13_FILE} ]; then
		LANG='ja_JP.UTF-8'

		wine ${TH13_FILE}

		if [ -d "${TH13_INST}" ]; then
			rm ${TH13_FILE}
			for f in "custom.exe" "th13tr.dat" "th13.exe" "thbgm_tr.dat"; do
				ln -s "${TH13_INST}/${f}" "${TH13_DIR}/${f}"
			done

			ln -s "${TH13_DATA}" "${TH13_DIR}/th13tr_data"
			echo "AQATAAAAAQACAAUA/////////////wMAWAJYAgABAQMAAmRQAAIAAAAAAAAHAAAAAAAAAAAAAAAA
AAAA" | base64 -d > "${TH13_DIR}/th13tr_data/th13.cfg"

			zenity --info --title "Success" --text "東方神霊廟 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
	LANG=${OLD_LANG}
}

[ "$(th13_check)" = "0" ] && th13_setup
[ "$(th13_check)" = "1" ] && th13_run

exit 0

