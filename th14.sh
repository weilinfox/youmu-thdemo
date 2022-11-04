#!/bin/sh

TH14_DIR="${WORK_DIR}/th14"
TH14_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方輝針城体験版"
TH14_INST_BAK="${WINEPREFIX}/drive_c/Program Files/忋奀傾儕僗尪炠抍/搶曽婸恓忛懱尡斉"
#TH14_DATA="${WINEPREFIX}/drive_c/users/${USER}/AppData/Roaming/ShanghaiAlice/th14tr"

TH14_FILE='setup_th14_001b.zip'
TH14_LINKS='"http://oic.storage-service.jp:8080/shanghaialice/setup_th14_001b.zip"
	"http://kokoron.madoka.org/mirror/D/t/touhoukishinjou/setup_th14_001b.zip"
	"http://s1.gptwm.com/s_alice/th140/setup_th14_001b.zip"'
TH14_MD5='51ec6d98a1b0c8186442857fcfe91274'

[ -d ${TH14_DIR} ] || mkdir ${TH14_DIR}
#[ -d ${TH14_DATA} ] || mkdir -p ${TH14_DATA}

th14_check() {
	if [ -e "${TH14_DIR}/th14.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th14_run() {
	OLD_PWD=$(pwd)

	cd "${TH14_DIR}"

	if [ -e "th14.exe" ]; then
		LC_ALL="${TMP_LOCALE}" wine th14.exe
	fi

	cd ${OLD_PWD}
}

th14_setup() {
	while [ "$(eval md5sum "${TH14_DIR}/${TH14_FILE}" | cut -d' ' -f1)" != "${TH14_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH14_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH14_DIR}/${TH14_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH14_DIR}

	if [ -e ${TH14_FILE} ]; then
		eval ${ZIP_DEC} ${TH14_FILE}

		LC_ALL="${TMP_LOCALE}" wine setup_th14_001b.exe

		[ -d "${TH14_INST_BAK}" ] && [ ! -d "${TH14_INST}" ] && TH14_INST=${TH14_INST_BAK}
		if [ -d "${TH14_INST}" ]; then
			rm ${TH14_FILE}
			rm setup_th14_001b.exe
			for f in "custom.exe" "th14tr.dat" "th14.exe" "thbgm_tr.dat"; do
				ln -s "${TH14_INST}/${f}" "${TH14_DIR}/${f}"
			done

#			ln -s "${TH14_DATA}" "${TH14_DIR}/th14tr_data"
#			echo "AgAUAAAAAQACAAUA/////////////wMAWAJYAgABAQUAAmRQAAIAAAAAAAAHAAAAAAAAAAAAAAAB
#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" | base64 -d > "${TH14_DIR}/th14tr_data/th14.cfg"

			zenity --info --title "Success" --text "東方輝針城 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
}

[ "$(th14_check)" = "0" ] && th14_setup
[ "$(th14_check)" = "1" ] && th14_run

exit 0

