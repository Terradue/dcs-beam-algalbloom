Node expression
===============

This is the first node of the workflow. As such, the platform takes cares of providing the inputs to the streaming executable.

It defines the parameters to query the catalogue which, in this case is the start and end time (time of interest) of the MERIS Level 1 products.

Two parameters target an OpenSearch query: 

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 8-12

The catalogue OpenSearch description URL is defined in the worflow section of the application descriptor file:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 68

.. NOTE::

  Although the application descriptor file refers to the local catalogue, the URLs below use a catalogue available to registered users so that the URLs do not depend on the sandbox IP.

Inspecting the contents returned by this URL, a query template for the *application/rdf+xml* response type is provided:

.. literalinclude:: ../assets/osd.xml
  :language: xml
  :tab-width: 1
  :lines: 18
  
The parameter values of startdate and enddate are mapped to the queryables *start={time:start?}* and *stop={time:end?}* to build the query

http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?start=2012-04-04&stop=2012-04-06

The same information is passed to the OpenSearch client available in the sandbox to generate the stdin for the expression node:

.. code-block:: bash

  opensearch-client -f Rdf -p time:start=2012-04-04 -p time:end=2012-04-06 http://catalogue.terradue.int/catalogue/search/MER_RR__1P/description 
  
which returns:

.. code-block:: bash

  http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?uid=MER_RR__1PRLRA20120405_192228_000026213113_00229_52829_0120.N1
  http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?uid=MER_RR__1PRLRA20120405_174214_000026213113_00228_52828_0110.N1
  http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?uid=MER_RR__1PRLRA20120405_142147_000026243113_00226_52826_0090.N1
  http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?uid=MER_RR__1PRLRA20120405_092107_000026213113_00223_52823_0052.N1
  http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?uid=MER_RR__1PRLRA20120404_131826_000026213113_00211_52811_9783.N1
  http://catalogue.terradue.int/catalogue/search/MER_RR__1P/rdf?uid=MER_RR__1PRLRA20120404_113812_000026213113_00210_52810_9773.N1

Those URLs are piped to the expression streamining executable that:

* Stages-in the input Envisat MERIS Level 1 products [#f1]_ passed as references to their catalogue entry
* Invokes the ESA BEAM Toolbox BandMaths Operator [#f2]_ to apply the provided band arithmetic expression to all input MERIS Level 1 products covering the time of interest 
* Stages-out the results in a distributed file system as inputs to the next processing step

The job template includes the path to the streaming executable.

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 7
  
The streaming executable source is available here: `/application/expression/run <https://github.com/Terradue/BEAM-Arithm-tutorial/blob/master/expression/run>`_
  
The job template defines three parameters:

+----------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------+
| Parameter name | Default value                                                                                                 | Description                                          |
+================+===============================================================================================================+======================================================+
| expression     | l1_flags.INVALID?0:radiance_13>17?0:100+radiance_9-(radiance_8+(radiance_10-radiance_8)*27.524/72.570)        | Band arithmetic expression for ESA BEAM Toolbox      |
+----------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------+
| startdate      | 2012-04-02                                                                                                    | startdate of type opensearch and a target time:start |
+----------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------+
| enddate        | 2012-04-06                                                                                                    | enddate of type opensearch and a target time:end     |
+----------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------+

which translates to:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 8-12

The job template set the property mapred.task.timeout, the wall time between messages in the log:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 13-15

Here's the job template including the elements described above:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 5-16

.. rubric:: Footnotes

.. [#f1] `Envisat MERIS  <https://earth.esa.int/web/guest/missions/esa-operational-eo-missions/envisat/instruments/meris>`_
.. [#f2] `ESA BEAM Toolbox BandMaths <http://www.brockmann-consult.de/beam/doc/help/gpf/org_esa_beam_gpf_operators_standard_BandMathsOp.html>`_ 
