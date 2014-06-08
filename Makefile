# -*- coding: us-ascii-unix -*-

name       = harbour-seadevil
version    = 0.6
DESTDIR    =
PREFIX     = /usr/local
datadir    = $(DESTDIR)$(PREFIX)/share/$(name)
desktopdir = $(DESTDIR)$(PREFIX)/share/applications
icondir    = $(DESTDIR)$(PREFIX)/share/icons/hicolor/86x86/apps

.PHONY: clean dist install rpm

clean:
	rm -rf dist seadevil/__pycache__
	rm -f rpm/*.rpm

dist:
	$(MAKE) clean
	mkdir -p dist/$(name)-$(version)
	cp -r `cat MANIFEST` dist/$(name)-$(version)
	tar -C dist -czf dist/$(name)-$(version).tar.gz $(name)-$(version)

install:
	@echo "Installing Python files..."
	mkdir -p $(datadir)/seadevil
	cp seadevil/*.py $(datadir)/seadevil
	@echo "Installing QML files..."
	mkdir -p $(datadir)/qml/icons
	cp qml/SeaDevil.qml $(datadir)/qml/$(name).qml
	cp -r qml/* $(datadir)/qml
	@echo "Installing desktop file..."
	mkdir -p $(desktopdir)
	cp data/$(name).desktop $(desktopdir)
	@echo "Installing icon..."
	mkdir -p $(icondir)
	cp data/harbour-seadevil.png $(icondir)/$(name).png

rpm:
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(name)-$(version).tar.gz $$HOME/rpmbuild/SOURCES
	rpmbuild -ba rpm/$(name).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(name)-$(version)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(name)-$(version)-*.rpm rpm
