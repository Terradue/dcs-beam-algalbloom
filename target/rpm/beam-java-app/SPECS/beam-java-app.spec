%define __jar_repack 0
Name: beam-java-app
Version: 0.1
Release: ciop
Summary: ESA BEAM Toolbox band arithmetic for algal bloom detection
License: ${project.inceptionYear}, Terradue, GPL
Distribution: Terradue ${project.inceptionYear}
Group: air
Packager: Terradue
Provides: beam-java-app
autoprov: yes
autoreq: yes
Prefix: /application
BuildArch: noarch
BuildRoot: /home/fbrito/dcs-beam-algalbloom/target/rpm/beam-java-app/buildroot

%description
This tutorial uses the ESA BEAM Toolbox to perform
						Envisat MERIS Level 1 band arithmetic calculation to detect algal
						blooms. The tutorial includes two MERIS Level 1 reduced resolution
						products and two processing steps: expression taking each MERIS
						product and applying the mathematical expression and binning that
						bins the products and generates the outputs in several formats
						(e.g. GEOTIFF, PNG and JPEG)

%install
if [ -d $RPM_BUILD_ROOT ];
then
  mv /home/fbrito/dcs-beam-algalbloom/target/rpm/beam-java-app/tmp-buildroot/* $RPM_BUILD_ROOT
else
  mv /home/fbrito/dcs-beam-algalbloom/target/rpm/beam-java-app/tmp-buildroot $RPM_BUILD_ROOT
fi

%files
%defattr(664,root,ciop,775)
  "/application/shared/bin/pconvert.sh"
  "/application/shared/bin/detect_java.sh"
  "/application/shared/bin/binning.sh"
  "/application/shared/bin/gpt.sh"
  "/application/expression/run.sh"
  "/application/binning/run.sh"
  "/application/application.xml"
 "/application/shared/modules"
 "/application/shared/lib"
%attr(775,root,ciop)  "/application/shared/bin/pconvert.sh"
%attr(775,root,ciop)  "/application/shared/bin/detect_java.sh"
%attr(775,root,ciop)  "/application/shared/bin/binning.sh"
%attr(775,root,ciop)  "/application/shared/bin/gpt.sh"
%attr(775,root,ciop)  "/application/expression/run.sh"
%attr(775,root,ciop)  "/application/binning/run.sh"
