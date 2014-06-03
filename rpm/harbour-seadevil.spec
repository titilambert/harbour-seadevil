# Prevent brp-python-bytecompile from running.
%define __os_install_post %{___build_post}

Name: harbour-seadevil
Version: 0.5
Release: 1
Summary: WoL application for Sailfish OS
License: GPLv3+
URL: https://github.com/titilambert/harbour-seadevil
Source: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: make
Requires: libsailfishapp-launcher
Requires: pyotherside-qml-plugin-python3-qt5 >= 1.2
Requires: python3-base
Requires: sailfishsilica-qt5

%description
SeaDevil is a Wake on Lan application for sailfish OS. With SeaDevil you can wake your computers using your Jolla device. You can also save your favorite computers to wake them more quickly.

%prep
%setup -q

%install
make DESTDIR=%{buildroot} PREFIX=/usr install

%files
%doc AUTHORS COPYING NEWS README TODO
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

%changelog
* Tue Jun 03 2014 Thibault Cohen <titilambert@gmail.com> 0.5-1
- Add computer management page
- Add cover

* Mon Jun 02 2014 Thibault Cohen <titilambert@gmail.com> 0.1-2
- Fix desktop file

* Mon Jun 02 2014 Thibault Cohen <titilambert@gmail.com> 0.1-1
- Initial RPM release
