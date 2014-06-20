## Developer Cloud Service - MERIS Algal bloom detection using BEAM

TODO

The Landsat NDVI Python tutorial uses the Developer Cloud Sandbox service to implement a Python package using GDAL to   calculate the [NDVI](http://en.wikipedia.org/wiki/Normalized_Difference_Vegetation_Index) in [Landsat TM 5 and 7](http://en.wikipedia.org/wiki/Landsat_program) data.

This tutorial builds upon the [Python Scripting for Remote Sensing course](http://www.landmap.ac.uk/index.php/Learning-Materials/Python-Scripting/9.1-Introduction) by [Landmap](http://www.landmap.ac.uk/) and extends it to exploit a Cloud computing platform for its development, test and exploitation.

### Getting Started 

To run this application, you will need a Developer Cloud Sandbox that can be requested from Terradue's [Portal](http://www.terradue.com/partners), provided user registration approval. 

A Developer Cloud Sandbox provides Earth Science data access services, and assistance tools for a user to implement, test and validate his application.
It runs in two different lifecycle modes: Sandbox mode and Cluster mode. 
Used in Sandbox mode (single virtual machine), it supports cluster simulation and user assistance functions in building the distributed application.
Used in Cluster mode (collections of virtual machines), it supports the deployment and execution of the application with the power of distributed computing processing over large datasets (leveraging the Hadoop Streaming MapReduce technology). 

### Installation 

Log on the developer sandbox and run these commands in a shell:

* Install **Java 7**

```bash
sudo yum install java-1.7.0-openjdk
```

* Select Java 7

```bash
sudo /usr/sbin/alternatives --config java
```

Select java 1.7 out of the menu options.

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

Or invoke the Web Processing Service via the Sandbox dashboard providing a start/stop date in the format YYYY/MM/DD.

### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer) service 
* [Envisat MERIS](https://earth.esa.int/web/guest/missions/esa-operational-eo-missions/envisat/instruments/meris)
* [ESA BEAM](https://earth.esa.int/web/guest/software-tools)
* [ESA BEAM repository](https://github.com/bcdev/beam)

### Authors (alphabetically)

* Emmannuel Mathot 
* Fabrice Brito

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
