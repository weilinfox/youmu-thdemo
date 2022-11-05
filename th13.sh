#!/bin/sh

TH13_DIR="${WORK_DIR}/th13"
TH13_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方神霊廟体験版"
TH13_INST_BAK="${WINEPREFIX}/drive_c/Program Files/忋奀傾儕僗尪炠抍/搶曽恄楈昣懱尡斉"
# TH13_DATA="${WINEPREFIX}/drive_c/users/${USER}/AppData/Roaming/ShanghaiAlice/th13tr"

TH13_FILE='th13tr001a_setup.exe'
TH13_LINKS='"http://mirror.studio-ramble.com/upload/535/201104/th13tr001a_setup.exe"
	"http://kokoron.madoka.org/mirror/D/t/touhoushinreibyou/th13tr001a_setup.exe"
	"http://s1.gptwm.com/s_alice/th130/th13tr001a_setup.exe"'
TH13_MD5='5336b10545fd0b6cb0eb38c97199e9bc'

[ -d ${TH13_DIR} ] || mkdir ${TH13_DIR}
# [ -d ${TH13_DATA} ] || mkdir -p ${TH13_DATA}

th13_check() {
	if [ -e "${TH13_DIR}/th13.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th13_run() {
	OLD_PWD=$(pwd)

	cd "${TH13_DIR}"

	if [ -e "th13.exe" ]; then
		LC_ALL="${TMP_LOCALE}" wine th13.exe
	fi

	cd ${OLD_PWD}
}

th13_custom() {
	OLD_PWD=$(pwd)

	cd "${TH13_DIR}"

	LC_ALL="${TMP_LOCALE}" wine custom.exe

	cd ${OLD_PWD}
}

th13_setup() {
	while [ "$(eval md5sum "${TH13_DIR}/${TH13_FILE}" | cut -d' ' -f1)" != "${TH13_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH13_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH13_DIR}/${TH13_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH13_DIR}

	if [ -e ${TH13_FILE} ]; then
		LC_ALL="${TMP_LOCALE}" wine ${TH13_FILE}

		[ -d "${TH13_INST_BAK}" ] && [ ! -d "${TH13_INST}" ] && TH13_INST=${TH13_INST_BAK}
		if [ -d "${TH13_INST}" ]; then
			rm ${TH13_FILE}
			for f in "custom.exe" "th13tr.dat" "th13.exe" "thbgm_tr.dat"; do
				ln -s "${TH13_INST}/${f}" "${TH13_DIR}/${f}"
			done

#			ln -s "${TH13_DATA}" "${TH13_DIR}/th13tr_data"
#			echo "AQATAAAAAQACAAUA/////////////wMAWAJYAgABAQMAAmRQAAIAAAAAAAAHAAAAAAAAAAAAAAAA
#AAAA" | base64 -d > "${TH13_DIR}/th13tr_data/th13.cfg"

			zenity --info --title "Success" --text "東方神霊廟 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
}

if [ "$1" = "custom" ]; then
	[ "$(th13_check)" = "0" ] && zenity --question --title "是否安装" --text "似乎没有安装诶，要先安装咩？" && th13_setup
	[ "$(th13_check)" = "1" ] && th13_custom
else
	[ "$(th13_check)" = "0" ] && th13_setup
	[ "$(th13_check)" = "1" ] && th13_run
fi

exit 0

