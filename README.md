## Developer Cloud Service - MERIS Algal bloom detection using BEAM

This tutorial builds upon the on the work done in the context of the ESA Cat-1 project “Production of global MERIS MCI composite images for detection of plankton blooms and other events” submitted by Dr. Jim Gower. More context information is available from the [tutorial wiki page](https://github.com/Terradue/dcs-beam-algalbloom/wiki).

Hereafter, we will guide you to implement a "MERIS Algal bloom detection using BEAM" application on Terradue's Cloud Platform, a set of Cloud services to develop, test and exploit scalable, distributed earth data processors. 

### Getting Started 

To run this application, you will need a Developer Cloud Sandbox that can be requested from [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval. 

### Installation 

Log on the developer sandbox and run these commands in a shell:

* Install **Java 7**

```bash
sudo yum install -y java-1.7.0-openjdk
```

* Select Java 7

```bash
sudo /usr/sbin/alternatives --config java
```
This will show on the terminal window:

```
There are 3 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
 + 1           /usr/java/jdk1.6.0_35/jre/bin/java
   2           /usr/lib/jvm/jre-1.5.0-gcj/bin/java
*  3           /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java

Enter to keep the current selection[+], or type selection number:
```

Select java 1.7 out of the menu options by typing the correct number (here it's *3*).

* Install R required packages

Install R and associated packages with the platform rciop RPM:

```bash
sudo yum install rciop
```

Install ff package in an R console:

```coffee
install.packages("ff")
```

* Install this application

```bash
cd
git clone git@github.com:Terradue/dcs-beam-algalbloom.git
cd dcs-beam-algalbloom
mvn install
```

### Submitting the workflow

Run this command in a shell:

```bash
ciop-simwf
```

Or invoke the Web Processing Service via the Sandbox dashboard providing a start/stop date in the format YYYY/MM/DD (e.g. 2012-04-01 and 2012-04-03).

### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer) service 
* [Envisat MERIS](https://earth.esa.int/web/guest/missions/esa-operational-eo-missions/envisat/instruments/meris)
* [ESA BEAM](https://earth.esa.int/web/guest/software-tools)
* [ESA BEAM repository](https://github.com/bcdev/beam)

### Authors (alphabetically)

* Brito Fabrice
* Mathot Emmannuel

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
