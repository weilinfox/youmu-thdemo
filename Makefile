NAME=thdemo
PREFIX=/usr

all:
	@echo Run \'make install\' to install

install:
	@mkdir -p "${DESTDIR}${PREFIX}/lib/${NAME}"
	@mkdir -p "${DESTDIR}${PREFIX}/bin/"
	@cp *.sh "${DESTDIR}${PREFIX}/lib/"
	@ln -s "${DESTDIR}${PREFIX}/lib/thdemo.sh" "${DESTDIR}${PREFIX}/bin/thdemo"
	@find "${DESTDIR}${PREFIX}/lib/" -name "*.sh" | xargs chmod 755

uninstall:
	@rm -rf "${DESTDIR}${PREFIX}/lib/${NAME}"
	@rm -rf "${DESTDIR}${PREFIX}/bin/thdemo"

