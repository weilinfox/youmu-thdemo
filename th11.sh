#!/bin/sh

TH11_DIR="${WORK_DIR}/th11"
TH11_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方地霊殿体験版"

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

function th11_check {
	if [ -e "${TH11_DIR}/th11.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

function th11_run {
	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd "${TH11_DIR}"
	LANG="ja_JP.UTF-8"

	if [ -e "th11.exe" ]; then
		wine th11.exe
	fi

	LANG=${OLD_LANG}
	cd ${OLD_PWD}
}

function th11_setup {
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

	OLD_LANG=${LANG}
	OLD_PWD=$(pwd)

	cd ${TH11_DIR}

	if [ -e ${TH11_FILE} ] && [ -e ${TH11_UPDATE_FILE} ]; then
		eval ${LZH_DEC} ${TH11_UPDATE_FILE}
		
		LANG='ja_JP.UTF-8'

		wine ${TH11_FILE}

		if [ -d "${TH11_INST}" ]; then
			rm ${TH11_FILE}
			rm ${TH11_UPDATE_FILE}
			for f in "custom.exe" "th11tr.dat" "th11.exe" "thbgm_tr.dat" "マニュアル"; do
				ln -s "${TH11_INST}/${f}" "${TH11_DIR}/${f}"
			done

			zenity --info --title "Update" --text "此时应用 002b 更新程序。请在差分应用目录选框选入 C:\\Program Files\\上海アリス幻樂団\\東方地霊殿体験版"

			wine th11_002b_update.exe
			rm th11_002b_update.exe

			echo "AwARAAAAAQACAAQA//////////8DAFgCWAIAAQEDAAJkUAACAAAAAAAAAAAHAAAAAAAAAAAAAAAA
AAAA" | base64 -d > th11.cfg

			zenity --info --title "Success" --text "東方地霊殿 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
	LANG=${OLD_LANG}
}

[ "$(th11_check)" = "0" ] && th11_setup
[ "$(th11_check)" = "1" ] && th11_run

exit 0

