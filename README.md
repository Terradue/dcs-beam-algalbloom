## Developer Cloud Service - MERIS Algal bloom detection using BEAM

Ocean colour radiometry is a technology, and a discipline of research, concerning the study of the interaction between the visible electromagnetic radiation coming from the sun and aquatic environments. In general, the term is used in the context of remote-sensing observations, often made from Earth-orbiting satellites. Using sensitive radiometers, such as those on-board satellite platforms, one can measure carefully the wide array of colors emerging out of the ocean. These measurements can be used to infer important information such as phytoplankton biomass or concentrations of other living and non-living material that modify the characteristics of the incoming radiation. Monitoring the spatial and temporal variability of algal blooms from satellite, over large marine regions up to the scale of the global ocean, has been instrumental in characterizing variability of marine ecosystems and is a key tool for research into how marine ecosystems respond to climate change and anthropogenic perturbations.

Source: [Wikipedia Ocean Color](http://en.wikipedia.org/wiki/Ocean_color)

The MERIS Algal bloom detection using BEAM tutorial uses the Developer Cloud Sandbox service to implement a simple datapipeline workflow to apply a band arithmetic expression to MERIS Level 1 data to visualy detect algal blooms and bin these products.

This tutorial builds upon the on the work done in the context of the ESA Cat-1 project “Production of global MERIS MCI composite images for detection of plankton blooms and other events” submitted by Dr. Jim Gower and extends it to exploit a Cloud computing platform for its development, test and exploitation.

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
