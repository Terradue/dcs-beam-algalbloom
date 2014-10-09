Rationales for your processing chain
####################################

Data 
****

You will use Envisat MERIS Level 1 Reduced Resolution, a few orbit passes acquired in April 2012.

The list of products used as test data is:

.. container:: context-custom
  
  MERIS file list

  .. code-block:: bash

    MER_RR__1PRLRA20120407_112751_000026243113_00253_52853_0364.N1
    MER_RR__1PRLRA20120406_102429_000026213113_00238_52838_0211.N1
    MER_RR__1PRLRA20120405_174214_000026213113_00228_52828_0110.N1
    MER_RR__1PRLRA20120405_142147_000026243113_00226_52826_0090.N1
    MER_RR__1PRLRA20120405_092107_000026213113_00223_52823_0052.N1
    MER_RR__1PRLRA20120404_231946_000026213113_00217_52817_9862.N1
    MER_RR__1PRLRA20120404_181906_000026213113_00214_52814_9818.N1
    MER_RR__1PRLRA20120404_131826_000026213113_00211_52811_9783.N1
    MER_RR__1PRLRA20120404_113812_000026213113_00210_52810_9773.N1
    MER_RR__1PRLRA20120404_095759_000026213113_00209_52809_9767.N1

Software and COTS
*****************

ESA BEAM toolbox
----------------

You will use the ESA BEAM Toolbox [#f1]_ to:

* apply the MCI formula to the MERIS Level 1 products of the test dataset
* create daily binned products (temporal and spatial aggregation)

BEAM is an open-source toolbox and development platform for viewing, analyzing and processing of remote sensing raster data. Originally developed to facilitate the utilization of image data from Envisat's optical instruments, BEAM now supports a growing number of other raster data formats such as GeoTIFF and NetCDF as well as data formats of other EO sensors such as MODIS, AVHRR, AVNIR, PRISM and CHRIS/Proba. Various data and algorithms are supported by dedicated extension plug-ins.
BEAM Graph Processing Tool (gpt) is a tool used to execute BEAM raster data operators in batch-mode. The operators can be used stand-alone or combined as a directed acyclic graph (DAG). Processing graphs are represented using XML.

You will tutorial use the **BandMaths** operator and the **Level 3 Binning Processor**. 

**The BandMaths Operator**

The *BandMaths* operator can be used to create a product with multiple bands based on mathematical expression. All products specified as source must have the same width and height, otherwise the operator will fail. The geo-coding information and metadata for the target product is taken from the first source product.  
In the application, you will apply the mathematical expression below to all input MERIS Level 1 Reduced Resolution products to detect the algal blooms:

.. container:: context-custom
  
  Band arithmetic expression
  
  .. code-block:: bash

    l1_flags.INVALID?0:radiance_13>15?0:100+radiance_9-(radiance_8+(radiance_10-radiance_8)*27.524/72.570)

**The Level 3 Binning Processor**

The term binning refers to the process of distributing the contributions of Level 2 pixels in satellite coordinates to a fixed Level 3 grid using a geographic reference system. In most cases a sinusoidal projection is used to realize Level 3 grid comprising a fixed number of equal area bins with global coverage. This is for example true for the SeaWiFS Level 3 products.
As long as the area of an input pixel is small compared to the area of a bin, a simple binning is sufficient.
In this case, the geodetic center coordinate of the Level 2 pixel is used to find the bin in the Level 3 grid whose area is intersected by this point. If the area of the contributing pixel is equal or even larger than the bin area, this simple binning will produce composites with insufficient accuracy and visual artefacts such as Moiré effects will dominate the resulting datasets.


R
-

R is used to organize the inputs for the Level 3 Binning Processor.

R is a language and environment for statistical computing and graphics. R provides a wide variety of statistical (linear and nonlinear modelling, classical statistical tests, time-series analysis, classification, clustering, ...) and graphical techniques, and is highly extensible. The S language is often the vehicle of choice for research in statistical methodology, and R provides an Open Source route to participation in that activity. It is one of languages that can be used to implement applications in the framework.

.. [#f1] `ESA BEAM Toolbox <http://www.brockmann-consult.de/cms/web/beam/>`_
