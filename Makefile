
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
	make digsigsums
	dpkg-deb --build debian/pkgsrc dest
digsigsums:
	rm -rf /tmp/pkgsrc
	mkdir -p /tmp/pkgsrc/opt/pkgsrc/
	rsync -apv debian/pkgsrc/opt/pkgsrc/bin  /tmp/pkgsrc/opt/pkgsrc/
	rsync -apv --exclude python2.6 --exclude perl5 --exclude man --exclude zsh --exclude emacs --exclude version.pm debian/pkgsrc/opt/pkgsrc/lib  /tmp/pkgsrc/opt/pkgsrc/
	gendigsigsums - /tmp/pkgsrc >debian/pkgsrc/DEBIAN/digsigsums
put: build
	ssh root@n9 rm -f /$(compilehost)/user/MyDocs/`ls dest`
	cd dest && scp pkgsrc**.deb root@n9:/$(compilehost)/user/MyDocs/
clean:
	rm -rf dest
reload:
	mkdir -p debian/pkgsrc/opt
	cd debian/pkgsrc/opt && rsync -ave ssh --delete root@$(compilehost):/opt/pkgsrc ./
install: put
	ssh root@n9 dpkg -i /$(compilehost)/user/MyDocs/`ls dest`
	ssh root@n9 rm -f /$(compilehost)/user/MyDocs/`ls dest`
