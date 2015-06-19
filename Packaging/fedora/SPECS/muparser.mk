#
# Copyright (c) 2005 - 2015 Ralf Corsepius, Ulm, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
Name:     OpenThreads
Version:  3.3.0
Release:  1%{?dist}
Summary:  OpenThreads is a cross platform, object orientated threading library.

# The OSGPL is just the wxWidgets license.
License:        wxWidgets
URL:            http://www.openscenegraph.org/
# Announced as stable, but published under developer_releases ;)
Source0:        http://www.openscenegraph.org/downloads/developer_releases/OpenThreads-%{version}.tar.xz
BuildRequires:  cmake

%description
OpenThreads is intended to provide a minimal & complete Object-Oriented (OO)
thread interface for C++ programmers.  It is loosely modeled on the Java
thread API, and the POSIX Threads standards.  The architecture of the 
library is designed around "swappable" thread models which are defined at 
compile-time in a shared object library.

%prep
%setup -q

%build
mkdir -p BUILD
pushd BUILD
CFLAGS="${RPM_OPT_FLAGS} -pthread"
CXXFLAGS="${RPM_OPT_FLAGS} -pthread"
%cmake %{_builddir}/%{name}-%{version} -DCMAKE_BUILD_TYPE=RelWithDebInfo
make VERBOSE=1 %{?_smp_mflags}
popd

%install
pushd BUILD
make install DESTDIR=${RPM_BUILD_ROOT}
popd

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%doc {AUTHORS,INSTALL,README}.txt
%license COPYING.txt
%{_libdir}/libOpenThreads.so.*

# OpenThreads-devel
%package devel
Summary:        Development files for OpenThreads
License:        wxWidgets
Requires:       OpenThreads = %{version}-%{release}
Requires:       pkgconfig

%description devel
Development files for OpenThreads.

%files devel
%doc {AUTHORS,INSTALL,README}.txt
%{_libdir}/pkgconfig/openthreads.pc
%{_libdir}/libOpenThreads.so
%{_includedir}/OpenThreads

%changelog
* Fri Apr 17 2015 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.2.1-5
- Rebuild (gcc-5.0.1).
- Modernize spec.
- Add %%license.

* Wed Feb 18 2015 Rex Dieter <rdieter@fedoraproject.org> 3.2.1-4
- rebuild (fltk,gcc5)

* Thu Oct 30 2014 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.2.1-3
- Add 0004-Applied-fix-to-Node-remove-Callback-NodeCallback-ins.patch
  (RHBZ #1158669).
- Rebase patches.

* Fri Aug 15 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.2.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Thu Jul 10 2014 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.2.1-1
- Upgrade to 3.2.1.
- Rebase patches.

* Fri Jun 06 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.2.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue May 27 2014 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.2.0-2
- Modernize spec.
- Preps for 3.2.1.

* Wed Aug 14 2013 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.2.0-1
- Upstream update.
- Rebase patches.

* Tue Aug 13 2013 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.0.1-18
- Fix %%changelog dates.

* Fri Aug 02 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.0.1-17
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Wed Feb 13 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.0.1-16
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Fri Jan 18 2013 Adam Tkac <atkac redhat com> - 3.0.1-15
- rebuild due to "jpeg8-ABI" feature drop

* Fri Dec 21 2012 Adam Tkac <atkac redhat com> - 3.0.1-14
- rebuild against new libjpeg

* Mon Sep 03 2012 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.0.1-13
- BR: libvncserver-devel, ship osgvnc (RHBZ 853755).

* Wed Jul 18 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.0.1-12
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Thu May 17 2012 Marek Kasik <mkasik@redhat.com> - 3.0.1-11
- Rebuild (poppler-0.20.0)

* Mon May 07 2012 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.0.1-10
- Append -pthread to CXXFLAGS (Fix FTBFS).

* Tue Feb 28 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.0.1-9
- Rebuilt for c++ ABI breakage

* Thu Jan 12 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.0.1-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Dec 06 2011 Adam Jackson <ajax@redhat.com> - 3.0.1-7
- Rebuild for new libpng

* Fri Oct 28 2011 Rex Dieter <rdieter@fedoraproject.org> - 3.0.1-6
- rebuild(poppler)

* Fri Sep 30 2011 Marek Kasik <mkasik@redhat.com> - 3.0.1-5
- Rebuild (poppler-0.18.0)

* Mon Sep 19 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.0.1-3
- Add BR: qtwebkit-devel.
- Add osgQtBrowser, osgQtWidgets to OpenSceneGraph-examples-qt.

* Mon Sep 19 2011 Marek Kasik <mkasik@redhat.com> - 3.0.1-2
- Rebuild (poppler-0.17.3)

* Wed Aug 17 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 3.0.1-1
- Upstream update.
- Remove OpenSceneGraph2* tags.
- Split out OpenSceneGraph-qt, OpenSceneGraph-qt-devel.
- Pass -Wno-dev to cmake.
- Append -pthread to CFLAGS.

* Sun Jul 17 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.5-3
- Reflect curl having silently broken their API.

* Fri Jul 15 2011 Marek Kasik <mkasik@redhat.com> - 2.8.5-2
- Rebuild (poppler-0.17.0)

* Tue Jun 14 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.5-1
- Upstream update.

* Mon May 30 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.4-2
- Reflect fltk-include paths having changed incompatibly.

* Wed Apr 27 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.4-1
- Upstream update.
- Rebase OpenSceneGraph-*.diff.
- Spec file cleanup.

* Sun Mar 13 2011 Marek Kasik <mkasik@redhat.com> - 2.8.3-10
- Rebuild (poppler-0.16.3)

* Mon Feb 07 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.8.3-9
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Sun Jan 02 2011 Rex Dieter <rdieter@fedoraproject.org> - 2.8.3-8
- rebuild (poppler)

* Wed Dec 15 2010 Rex Dieter <rdieter@fedoraproject.org> - 2.8.3-7
- rebuild (poppler)

* Wed Dec 15 2010 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.3-6
- Add %%{_fontdir} to OSG's font file search path.

* Sat Nov 06 2010 Rex Dieter <rdieter@fedoraproject.org> - 2.8.3-5
- rebuilt (poppler)

* Thu Sep 30 2010 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.3-4
- rebuild (libpoppler-glib.so.6).

* Thu Aug 19 2010 Rex Dieter <rdieter@fedoraproject.org> - 2.8.3-3
- rebuild (poppler)

* Mon Jul 12 2010 Dan Horák <dan@danny.cz> - 2.8.3-2
- rebuilt against wxGTK-2.8.11-2

* Fri Jul 02 2010 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.3-1
- Upstream update.
- Add osg-examples-gtk.

* Wed Aug 26 2009 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.2-3
- Change Source0 URL (Upstream moved it once again).

* Tue Aug 18 2009 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.2-2
- Spec file cleanup.

* Mon Aug 17 2009 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.2-1
- Upstream update.
- Reflect upstream having changes Source0-URL.

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.8.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Mon Jun 29 2009 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.1-2
- Remove /usr/bin/osgfilecache from *-examples.
- Further spec cleanup.

* Wed Jun 24 2009 Ralf Corsépius <corsepiu@fedoraproject.org> - 2.8.1-1
- Upstream update.
- Reflect upstream having consolidated their Source0:-URL.
- Stop supporting OSG < 2.6.0.

* Mon Feb 23 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.8.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Sun Feb 15 2009 Ralf Corsépius <rc040203@freenet.de> - 2.8.0-1
- Upgrade to OSG-2.8.0.
- Remove Obsolete: Producer hacks.

* Thu Aug 14 2008 Ralf Corsépius <rc040203@freenet.de> - 2.6.0-1
- Upgrade to OSG-2.6.0.

* Wed Aug 13 2008 Ralf Corsépius <rc040203@freenet.de> - 2.4.0-4
- Preps for 2.6.0.
- Reflect the Source0-URL having changed.
- Major spec-file overhaul.

* Thu May 22 2008 Tom "spot" Callaway <tcallawa@redhat.com> - 2.4.0-3
- fix license tag

* Tue May 13 2008 Ralf Corsépius <rc040203@freenet.de> - 2.4.0-2
- Add Orion Poplawski's patch to fix building with cmake-2.6.0.

* Mon May 12 2008 Ralf Corsépius <rc040203@freenet.de> - 2.4.0-1
- Upstream update.
- Adjust patches to 2.4.0.

* Mon Feb 11 2008 Ralf Corsépius <rc040203@freenet.de> - 2.2.0-5
- Add *-examples-SDL package.
- Add osgviewerSDL.
- Add *-examples-fltk package.
- Add osgviewerFLTK.
- Add *-examples-qt package.
- Move osgviewerQT to *-examples-qt package.

* Mon Feb 11 2008 Ralf Corsépius <rc040203@freenet.de> - 2.2.0-4
- Rebuild for gcc43.
- OpenSceneGraph-2.2.0.diff: Add gcc43 hacks.

* Wed Nov 28 2007 Ralf Corsépius <rc040203@freenet.de> - 2.2.0-3
- Re-add apivers.
- Rebuild against doxygen-1.5.3-1 (BZ 343591).

* Fri Nov 02 2007 Ralf Corsépius <rc040203@freenet.de> - 2.2.0-2
- Add qt.

* Thu Nov 01 2007 Ralf Corsépius <rc040203@freenet.de> - 2.2.0-1
- Upstream upgrade.
- Reflect Source0-URL having changed once again.
- Reflect upstream packaging changes to spec.

* Sat Oct 20 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-8
- Reflect Source0-URL having changed.

* Thu Sep 27 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-7
- Let OpenSceneGraph-libs Obsoletes: Producer
- Let OpenSceneGraph-devel Obsoletes: Producer-devel.

* Wed Sep 26 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-6
- By public demand, add upstream's *.pcs.
- Add hacks to work around the worst bugs in *.pcs.
- Add OpenSceneGraph2-devel.
- Move ldconfig to *-libs.
- Abandon OpenThreads2.
- Remove obsolete applications.

* Wed Aug 22 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-5
- Prepare renaming package into OpenSceneGraph2.
- Split out run-time libs into *-libs subpackage.
- Rename pkgconfig files into *-2.pc.
- Reactivate ppc64.
- Mass rebuild.

* Sat Jun 30 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-4
- Cleanup CVS.
- Add OSG1_Producer define.

* Fri Jun 29 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-3
- Re-add (but don't ship) *.pc.
- Let OpenSceneGraph "Obsolete: Producer".
- Let OpenSceneGraph-devel "Obsolete: Producer-devel".

* Wed Jun 27 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-2
- Build docs.

* Fri Jun 22 2007 Ralf Corsépius <rc040203@freenet.de> - 2.0-1
- Upgrade to 2.0.

* Thu Jun 21 2007 Ralf Corsépius <rc040203@freenet.de> - 1.2-4
- ExcludeArch: ppc64 (BZ 245192, 245196).

* Thu Jun 21 2007 Ralf Corsépius <rc040203@freenet.de> - 1.2-3
- Remove demeter (Defective, abandoned by upstream).

* Wed Mar 21 2007 Ralf Corsépius <rc040203@freenet.de> - 1.2-2
- Attempt to build with gdal enabled.

* Thu Oct 05 2006 Ralf Corsépius <rc040203@freenet.de> - 1.2-1
- Upstream update.
- Remove BR: flex bison.
- Drop osgfbo and osgpbuffer.

* Tue Sep 05 2006 Ralf Corsépius <rc040203@freenet.de> - 1.1-2
- Mass rebuild.

* Thu Aug 24 2006 Ralf Corsépius <rc040203@freenet.de> - 1.1-1
- Upstream update.

* Sat Jul 08 2006 Ralf Corsépius <rc040203@freenet.de> - 1.0-5
- Rebuilt to with gcc-4.1.1-6.

* Wed Jun 07 2006 Ralf Corsépius <rc040203@freenet.de> - 1.0-4
- Try to avoid adding SONAMEs on plugins and applications.

* Tue Jun 06 2006 Ralf Corsépius <rc040203@freenet.de> - 1.0-3
- Add SONAME hack to spec (PR 193934).
- Regenerate OpenSceneGraph-1.0.diff.
- Remove OpenSceneGraph-1.0.diff from look-aside cache. Add to CVS instead.
- Fix broken shell fragments.

* Sun Feb 19 2006 Ralf Corsépius <rc040203@freenet.de> - 1.0-2
- Rebuild.

* Sat Dec 10 2005 Ralf Corsépius <rc040203@freenet.de> - 1.0-1
- Upstream update.

* Wed Dec 07 2005 Ralf Corsépius <rc040203@freenet.de> - 0.9.9-5
- Try at getting this package buildable with modular X11.

* Tue Dec 06 2005 Ralf Corsepius <rc040203@freenet.de> - 0.9.9-4%{?dist}.1
- Merge diffs into one file.
- Fix up *.pcs from inside of *.spec.

* Sun Aug 28 2005 Ralf Corsepius <rc040203@freenet.de> - 0.9.9-4
- Propagate %%_libdir to pkgconfig files.
- Fix typo in %%ifarch magic to setup LD_LIBRARY_PATH
- Move configuration to %%build.
- Spec file cosmetics.

* Sat Aug 27 2005 Ralf Corsepius <rc040203@freenet.de> - 0.9.9-3
- Add full URL to Debian patch.
- Add _with_demeter.
- Extend Producer %%description.
- Extend OpenThreads %%description.

* Tue Aug 09 2005 Ralf Corsepius <ralf@links2linux.de> - 0.9.9-2
- Fix license to OSGPL.
- Change permissions on pkgconfig files to 0644.

* Tue Aug 02 2005 Ralf Corsepius <ralf@links2linux.de> - 0.9.9-1
- FE submission.

* Thu Jul 21 2005 Ralf Corsepius <ralf@links2linux.de> - 0.9.9-0
- Initial spec.
