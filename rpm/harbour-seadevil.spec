# Prevent brp-python-bytecompile from running.
%define __os_install_post %{___build_post}

Name: harbour-seadevil
Version: 0.9
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
mkdir -p %{buildroot}/%{_datadir}/%{name}/doc
cp AUTHORS COPYING NEWS README TODO %{buildroot}/%{_datadir}/%{name}/doc

%files
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%docdir %{_datadir}/%{name}/doc/

%changelog
* Thu Jul 24 2014 Thibault Cohen <titilambert@gmail.com> 0.9-1
- Clean packaging
- Fix pylint Warnings

* Tue Jul 15 2014 Thibault Cohen <titilambert@gmail.com> 0.8-1
- SeaDevil can now be added to Launcher

* Sun Jun 08 2014 Thibault Cohen <titilambert@gmail.com> 0.7-1
- Improve About page

* Sun Jun 08 2014 Thibault Cohen <titilambert@gmail.com> 0.6-1
- Fix refresh bugs
- Add some PopUps

* Tue Jun 03 2014 Thibault Cohen <titilambert@gmail.com> 0.5-1
- Add computer management page
- Add cover

* Mon Jun 02 2014 Thibault Cohen <titilambert@gmail.com> 0.1-2
- Fix desktop file

* Mon Jun 02 2014 Thibault Cohen <titilambert@gmail.com> 0.1-1
- Initial RPM release
