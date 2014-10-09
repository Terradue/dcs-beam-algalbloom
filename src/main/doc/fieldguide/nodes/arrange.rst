Node arrange
===============

This section defines the node *arrange* job template. The template is part of the application descriptor file [#f1]_.

The application goal is to produce daily binned products so the binning processing step needs to have its inputs well organized so that it aggregates in time and space only the products of a given day. 

In terms of job template, you will define the path to the streaming executable, one parameter: the period (a day) and instruct the framework that only one task has to be run.

As the second job in this workflow, the expression processing step implements a streaming executable that:

* Create an R data frame [#f2]_ with all references to the data produced by the node expression
* Split the references by period based in the acquisition start time of the input product into groups of references
* Write the groups to the local filesystem in Tab separated files
* Stage-out the Tab separated files to the distributed file system

The job template includes the path to the streaming executable.

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 19
  
The streaming executable source is available here: `/application/arrange/run.R <https://github.com/Terradue/BEAM-Arithm-tutorial/blob/master/arrange/run.R>`_
  
The job template defines a single parameter:

+----------------+----------------+-------------------------------------------------+
| Parameter name | Default value  | Description                                     |
+================+================+=================================================+
| period         | day            | The period for the temporal aggregation (daily) |
+----------------+----------------+-------------------------------------------------+

which translates to the XML code in the node arrange job template: 

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 20-22

The job template sets the *ciop.job.max.tasks* to one instance since the streaming executable has to process all inputs at once:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 23-25
  	
.. NOTE::
  The property *mapred.task.timeout* is not set and uses the default value (10 minutes).*

Here's the job template including all the elements described above:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 18-26 

.. rubric:: Footnotes

.. [#f1] The application file descriptor reference is found :doc:`here </reference/application/index>` and the entire Algal Bloom detection application descriptor file here: `/application/application.xml  <https://github.com/Terradue/BEAM-Arithm-tutorial/blob/master/application.xml>`_  
.. [#f2] `R data frames <http://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html>`_ 
