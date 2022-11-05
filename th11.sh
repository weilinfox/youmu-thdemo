#!/bin/sh

TH11_DIR="${WORK_DIR}/th11"
TH11_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方地霊殿体験版"
TH11_INST_BAK="${WINEPREFIX}/drive_c/Program Files/忋奀傾儕僗尪炠抍/搶曽抧楈揳懱尡斉"

TH11_FILE='th11tr002a_setup.exe'
TH11_UPDATE_FILE='th11_002b_update.lzh'
TH11_LINKS='"http://mirror.studio-ramble.com/upload/535/200806/th11tr002a_setup.exe"
	"http://kokoron.madoka.org/mirror/D/t/touhouchireiden/th11tr002a_setup.exe"
	"http://kokoron5.madoka.org/mirror/D/t/touhouchireiden/th11tr002a_setup.exe"
	"http://s1.gptwm.com/s_alice/th110/th11tr002a_setup.exe"'
TH11_UPDATE_LINKS='"http://s1.gptwm.com/s_alice/th110/th11_002b_update.lzh"'
TH11_MD5='9b7c092a529fcc1f48590f0a2b3cca87'
TH11_UPDATE_MD5='9548b3af586cf1030229cc38e5db24c3'

[ -d ${TH11_DIR} ] || mkdir ${TH11_DIR}

th11_check() {
	if [ -e "${TH11_DIR}/th11.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th11_run() {
	OLD_PWD=$(pwd)

	cd "${TH11_DIR}"

	if [ -e "th11.exe" ]; then
		LC_ALL="${TMP_LOCALE}" wine th11.exe
	fi

	cd ${OLD_PWD}
}

th11_custom() {
	OLD_PWD=$(pwd)

	cd "${TH11_DIR}"

	LC_ALL="${TMP_LOCALE}" wine custom.exe

	cd ${OLD_PWD}
}

th11_setup() {
	while [ "$(eval md5sum "${TH11_DIR}/${TH11_FILE}" | cut -d' ' -f1)" != "${TH11_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH11_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH11_DIR}/${TH11_FILE}
	done

	while [ "$(md5sum "${TH11_DIR}/${TH11_UPDATE_FILE}" | cut -d' ' -f1)" != "${TH11_UPDATE_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH11_UPDATE_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH11_DIR}/${TH11_UPDATE_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH11_DIR}

	if [ -e ${TH11_FILE} ] && [ -e ${TH11_UPDATE_FILE} ]; then
		eval ${LZH_DEC} ${TH11_UPDATE_FILE}
		
		LC_ALL="${TMP_LOCALE}" wine ${TH11_FILE}

		[ -d "${TH11_INST_BAK}" ] && [ ! -d "${TH11_INST}" ] && TH11_INST=${TH11_INST_BAK}
		if [ -d "${TH11_INST}" ]; then
			rm ${TH11_FILE}
			rm ${TH11_UPDATE_FILE}
			for f in "custom.exe" "th11tr.dat" "th11.exe" "thbgm_tr.dat"; do
				ln -s "${TH11_INST}/${f}" "${TH11_DIR}/${f}"
			done
			[ -d "${TH11_INST}/儅僯儏傾儖" ] && ln -s "${TH11_INST}/儅僯儏傾儖" "${TH11_DIR}/マニュアル"
			[ -d "${TH11_INST}/マニュアル" ] && ln -s "${TH11_INST}/マニュアル" "${TH11_DIR}/マニュアル"

			zenity --info --title "Update" --text "此时应用 002b 更新程序。请在差分应用目录选框选入 C:\\Program Files\\上海アリス幻樂団\\東方地霊殿体験版"

			LC_ALL="${TMP_LOCALE}" wine th11_002b_update.exe
			rm th11_002b_update.exe

			echo "AwARAAAAAQACAAQA//////////8DAFgCWAIAAQEDAAJkUAACAAAAAAAAAAAHAAAAAAAAAAAAAAAA
AAAA" | base64 -d > th11.cfg

			zenity --info --title "Success" --text "東方地霊殿 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
}

if [ "$1" = "custom" ]; then
	[ "$(th11_check)" = "0" ] && zenity --question --title "是否安装" --text "似乎没有安装诶，要先安装咩？" && th11_setup
	[ "$(th11_check)" = "1" ] && th11_custom
else
	[ "$(th11_check)" = "0" ] && th11_setup
	[ "$(th11_check)" = "1" ] && th11_run
fi

exit 0

