
#These three need to be exported in your shell, not just the Makefile.
PERL5LIB=/opt/qtsdk/Maemo/4.6.2/madlib/perl5/
AEGIS_TOOL_PREFIX=/opt/qtsdk/Madde/targets/harmattan-nokia-meego-api/bin/
SYSROOT_DIR=/opt/qtsdk/Madde/sysroots/harmattan-nokia-arm-sysroot

#Change this to your own development host.
compilehost=home


all: build

build: clean 
	#Finally, package it up.
	rm -rf debian/pkgsrc/usr
	mkdir -p debian/pkgsrc/usr/share/applications
	cp *.desktop debian/pkgsrc/usr/share/applications/
	mkdir -p debian/pkgsrc/usr/share/icons/hicolor/80x80/apps
	cp *.png debian/pkgsrc/usr/share/icons/hicolor/80x80/apps/
	mkdir -p debian/pkgsrc/opt/pkgsrc/etc/
	cp etc/* debian/pkgsrc/opt/pkgsrc/etc/
	#Clean old files.
	rm -rf debian/pkgsrc/DEBIAN
	rm -f debian/pkgsrc.tarlist
	mkdir -p debian/pkgsrc/DEBIAN
	mkdir dest
	cp debian/control debian/pkgsrc/DEBIAN/
	echo "Installed-Size: " `du -sk debian/pkgsrc | sed 's/debian.*//'` >>debian/pkgsrc/DEBIAN/control
	dpkg-deb --build debian/pkgsrc dest
	#Add the aegis manifest.
	#ar q dest/pkgsrc_0.0.3_armel.deb debian/_aegis

put: build
	ssh root@n9 rm -f /$(compilehost)/user/MyDocs/`ls dest`
	cd dest && scp pkgsrc**.deb root@n9:/$(compilehost)/user/MyDocs/
clean:
	rm -rf dest
reload:
	cd debian/pkgsrc/opt && rsync -ave ssh --delete root@$(compilehost):/opt/pkgsrc ./
install: put
	ssh root@n9 dpkg -i /$(compilehost)/user/MyDocs/`ls dest`
	ssh root@n9 rm -f /$(compilehost)/user/MyDocs/`ls dest`
