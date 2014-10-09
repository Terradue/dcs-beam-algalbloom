Node binning
============

The binning job template defines the streaming executable, the wall time and the parameters:

* cellsize which is the size of the bin and it is specified in kilometers
* bbox that defines the area of interest. Its value defaults to -180,-90,180,90.
* algorithm defaulting to Minimum/Maximum (in this application, we want the maximum value). The other possible values are: "Maximum Likelihood" and "Arithmetic Mean"

The job template includes the path to the streaming executable.

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 30
  
The streaming executable source is available here: :download:`/application/binning/run.sh <../src/src/main/app-resources/binning/run.sh>` 

It implements the activities:

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start

  :Source libraries;
  
  :Get parameter values;

  while (check stdin?) is (line)
    
    :Stage-in list of expression results of the period;
    
    while (check list?) is (line)
    
      :Stage-in MERIS Level 1b product;
      
    endwhile (empty)
    
    :Apply Binning BEAM processor;
    
    :Generate RGB Tif and PNG;
    
    :Stage-out Binned, RBG Tif and PNG products;
  
  endwhile (empty)
  
  stop

The job template defines three parameters:

+----------------+-----------------+------------------------------------------------------------+
| Parameter name | Default value   | Description                                                | 
+================+=================+============================================================+
| bandname       | out             | prefix used to name the output BEAM DIMAP files            |
+----------------+-----------------+------------------------------------------------------------+
| bitmask        |                 | Mask expression to identify valid pixels to bin            |
+----------------+-----------------+------------------------------------------------------------+
| bbox           | -180,-90,180,90 | Bounding box of the area of interest (Xmin,Ymin,Xmax,Ymax) |
+----------------+-----------------+------------------------------------------------------------+
| algorithm      | MIN_MAX         | Aggregation methog for the Binning algorithm               |
+----------------+-----------------+------------------------------------------------------------+
| palette        |                 | BEAM Toolbox palette to generate the RGB results           |
+----------------+-----------------+------------------------------------------------------------+

which translates to:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 31-57

The job template set the property mapred.task.timeout, the wall time between messages in the log:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 58-60

Here's the job template including the elements described above:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 28-61

.. rubric:: Footnotes

.. [#f1] `ESA BEAM Toolbox Binning algorithm <http://www.brockmann-consult.de/beam/doc/help/binning/BinningTool.html>`_
