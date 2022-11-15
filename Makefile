NAME=thdemo
PREFIX=/usr

all:
	@echo Run \'make install\' to install

install:
	@mkdir -p "${DESTDIR}${PREFIX}/lib/${NAME}/"
	@mkdir -p "${DESTDIR}${PREFIX}/bin/"
	@mkdir -p "${DESTDIR}${PREFIX}/share/applications/"
	@cp *.sh "${DESTDIR}${PREFIX}/lib/${NAME}/"
	@cp thdemo.xpm "${DESTDIR}${PREFIX}/lib/${NAME}/"
	@cp thdemo.desktop "${DESTDIR}${PREFIX}/share/applications/"
	@ln -s "${PREFIX}/lib/${NAME}/thdemo.sh" "${DESTDIR}${PREFIX}/bin/thdemo"
	@find "${DESTDIR}${PREFIX}/lib/" -name "*.sh" | xargs chmod 755

uninstall:
	@rm -rf "${DESTDIR}${PREFIX}/lib/${NAME}"
	@rm -rf "${DESTDIR}${PREFIX}/bin/thdemo"
	@rm "${DESTDIR}${PREFIX}/share/applications/thdemo.desktop"

