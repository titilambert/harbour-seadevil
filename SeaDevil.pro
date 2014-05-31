# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = SeaDevil

CONFIG += sailfishapp

SOURCES += src/SeaDevil.cpp

OTHER_FILES += qml/SeaDevil.qml \
    qml/cover/CoverPage.qml \
    rpm/SeaDevil.changes.in \
    rpm/SeaDevil.spec \
    rpm/SeaDevil.yaml \
    translations/*.ts \
    SeaDevil.desktop \
    qml/pages/MainPage.qml \
    qml/pages/SaveDialog.qml \
    qml/Python.qml \
    seadevil/wol.py \
    seadevil/__init__.py

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/SeaDevil-de.ts

