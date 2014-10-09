Application integration and testing
===================================

Now that the node templates have defined the job templates, it is now time to organize these in a workflow.

The workflows are Directed Acyclic Graphs (DAG) where nodes and their relation(s), the source(s) are defined.

Each node of DAG has:

* a unique node identifier
* a job template id reference
* one or more sources
* one or more parameters and associated values to overide the default values (if defined in the job template).

The node_expression node
------------------------

The first node of the DAG with the unique identifer set to *node_expression* instantiates the :doc:`expression <nodes/expression>` job template.

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 65-71

As source, this node uses the sandbox catalogue:

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 67-69

The complete node *node_expression* definition is:

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 65-71

The node_arrange node
---------------------

The node_arrange instantiates the arrange job template and uses the default value for the period. The node inputs are not a reference to a catalogue as for the expression node, but the references to *node_expression* results:

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 74-76
  
The complete node *node_arrange* definition is:

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 72-79
 

The node_binning node
---------------------

The node *node_binning* definition is:

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 80-88

Workflow
--------

The complete workflow is:

.. literalinclude:: src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 63-89

Testing the application
-----------------------

Application installation
^^^^^^^^^^^^^^^^^^^^^^^^

All the application files are available on GitHub repository `MERIS Algal bloom detection using BEAM <https://github.com/Terradue/dcs-beam-algalbloom>`_. 

To install the application clone the repository on the Sandbox in your home folder:

.. code-block:: console

  cd ~
  git clone git@github.com:Terradue/dcs-beam-algalbloom.git
  cd dcs-beam-algalbloom
  mvn install

Then build the BEAM processor and the application resources with:

.. code-block:: console

  mvn install

The maven command will:

* Copy the application resources files from ~/dcs-beam-flh-java/src/main/app-resources to /application,
* Retrieve from BEAM website all the Java artifacts required to run BEAM.
  
Application check
^^^^^^^^^^^^^^^^^
  
The Application Descriptor file can be checked with:

.. code-block:: console

  ciop-appcheck
  
If the Application Descriptor is valid, the output is:

.. code-block:: console-output

  /application/application.xml validates
  
Installing the required packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The application requires ESA BEAM Toolbox which is available in the sandbox software repository:

.. code-block:: console

  sudo yum install esa-beam-4.11

R, which is also available in the software repository (it includes several packages and libraries):

.. code-block:: console

  sudo yum install rciop
  
And finally the R fcp package for the R DBSCAN library:


Simulating the application execution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  
There are two approaches to test an application. 

The first manually invokes each of the nodes with the ciop-simjob [#f1]_ command line utility.

The second triggers the automatic execution of the workflow with the ciop-simwf [#f2]_ command line utility.
  
Both approaches are shown below.

Testing manually the workflow with ciop-simjob
----------------------------------------------

Trigger the execution of the node_expression with:

.. code-block:: console

  ciop-simjob -f node_expression
  
The node_expression will produce one compressed archive with the BEAM-DIMAP product per input Envisat MERIS Level 1 product:

.. code-block:: console-output

  MER_RR__1PRLRA20120406_102429_000026213113_00238_52838_0211.N1.dim.tgz
  MER_RR__1PRLRA20120405_174214_000026213113_00228_52828_0110.N1.dim.tgz
  MER_RR__1PRLRA20120405_142147_000026243113_00226_52826_0090.N1.dim.tgz
  MER_RR__1PRLRA20120405_092107_000026213113_00223_52823_0052.N1.dim.tgz
  MER_RR__1PRLRA20120404_231946_000026213113_00217_52817_9862.N1.dim.tgz

These files are all available in sandbox the distributed filesystem. These are the inputs for the second node of the DAG

Run ciop-simjob for all the nodes of the DAG. 

.. code-block:: console

  ciop-simjob -n # list the node identifiers 
  ciop-simjob -f node_arrange
  ciop-simjob -f node_binning
  ciop-simjob -f node_clustering

Testing the workflow automatic execution with ciop-simwf
--------------------------------------------------------

.. code-block:: console

  ciop-simwf
  
Wait for the workflow execution.

.. rubric:: Footnotes

.. [#f1] :doc:`ciop-simjob man page </reference/man/bash_commands_functions/simulation/ciop-simjob>`
.. [#f2] :doc:`ciop-simwf man page </reference/man/bash_commands_functions/simulation/ciop-simwf>`
