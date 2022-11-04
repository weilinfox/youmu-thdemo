#!/bin/sh

TH10_DIR="${WORK_DIR}/th10"
TH10_INST="${WINEPREFIX}/drive_c/Program Files/上海アリス幻樂団/東方風神録体験版"
TH10_INST_BAK="${WINEPREFIX}/drive_c/Program Files/忋奀傾儕僗尪炠抍/搶曽晽恄榐懱尡斉"

TH10_FILE='th10tr002a_setup.exe'
TH10_CUSTOM_FILE='thcustom_002a.lzh'
TH10_LINKS='"http://kokoron4.madoka.org/mirror/D/t/touhoufuujinroku/th10tr002a_setup.exe"
	"http://kokoron.madoka.org/mirror/D/t/touhoufuujinroku/th10tr002a_setup.exe"
	"http://kokoron.madoka.org/mirror/D/t/touhoufuujinroku/th10tr002a_setup.exe"
	"http://kokoron5.madoka.org/mirror/D/t/touhoufuujinroku/th10tr002a_setup.exe"
	"http://s1.gptwm.com/s_alice/th100/th10tr002a_setup.exe"'
TH10_CUSTOM_LINKS='"http://www16.big.or.jp/~zun/data/soft/thcustom_002a.lzh"
	"http://s1.gptwm.com/s_alice/th100/thcustom_002a.lzh"'
TH10_MD5='4c816e8d7f59430d5083e55c86df2462'
TH10_CUSTOM_MD5='ff0501145d6dc00e61fd8bd153e3bc5a'

[ -d ${TH10_DIR} ] || mkdir ${TH10_DIR}

th10_check() {
	if [ -e "${TH10_DIR}/th10.exe" ] || [ -e "${TH10_DIR}/th10tr.exe" ]; then
		echo 1
	else
		echo 0
	fi
}

th10_run() {
	OLD_PWD=$(pwd)

	cd "${TH10_DIR}"

	if [ -e "th10.exe" ]; then
		LC_ALL="${TMP_LOCALE}" wine th10.exe
	else
		LC_ALL="${TMP_LOCALE}" wine th10tr.exe
	fi

	cd ${OLD_PWD}
}

th10_setup() {
	while [ "$(eval md5sum "${TH10_DIR}/${TH10_FILE}" | cut -d' ' -f1)" != "${TH10_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH10_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH10_DIR}/${TH10_FILE}
	done

	while [ "$(md5sum "${TH10_DIR}/${TH10_CUSTOM_FILE}" | cut -d' ' -f1)" != "${TH10_CUSTOM_MD5}" ]; do
		link=$(eval zenity --list --window-icon ${SCRIPT_DIR}/thdemo.xpm --column download ${TH10_CUSTOM_LINKS})
		[ "$link" = "" ] && break

		curl -L ${link} --output ${TH10_DIR}/${TH10_CUSTOM_FILE}
	done

	OLD_PWD=$(pwd)

	cd ${TH10_DIR}

	if [ -e ${TH10_FILE} ] && [ -e ${TH10_CUSTOM_FILE} ]; then
		eval ${LZH_DEC} ${TH10_CUSTOM_FILE}
		
		LC_ALL="${TMP_LOCALE}" wine ${TH10_FILE}

		[ -d "${TH10_INST_BAK}" ] && [ ! -d "${TH10_INST}" ] && TH10_INST=${TH10_INST_BAK}
		if [ -d "${TH10_INST}" ]; then
			mv custom.exe "${TH10_INST}/"
			rm ${TH10_CUSTOM_FILE}
			rm ${TH10_FILE}
			for f in "custom.exe" "th10tr.dat" "th10tr.exe" "thbgm_tr.dat"; do
				ln -s "${TH10_INST}/${f}" "${TH10_DIR}/${f}"
			done
			[ -d "${TH10_INST}/儅僯儏傾儖" ] && ln -s "${TH10_INST}/儅僯儏傾儖" "${TH10_DIR}/マニュアル"
			[ -d "${TH10_INST}/マニュアル" ] && ln -s "${TH10_INST}/マニュアル" "${TH10_DIR}/マニュアル"

			zenity --info --title "Success" --text "東方風神録 安装完成了捏"
		fi
	fi

	cd ${OLD_PWD}
}

[ "$(th10_check)" = "0" ] && th10_setup
[ "$(th10_check)" = "1" ] && th10_run

exit 0

