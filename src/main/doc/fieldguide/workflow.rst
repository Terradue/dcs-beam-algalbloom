Workflow design
===============

The application's data pipeline activities can be defined as follows:

**Step 1** use the ESA BEAM Toolbox BandMaths operator to apply the arithmetic expression to all MERIS Level 1 products. This step is run with several tasks in parallel, each task dealing with one input product.

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start
  
  while (check stdin?) is (line)
    :Stage-in data;
    :Apply ESA BEAM Toolbox BandMaths operator;
    :Stage-out arithm_result;
  endwhile (empty)

  stop

**Step 2** use an R executable script to arrange by temporal steps (in this case daily) the outputs of the previous step. This step runs as a single task.

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  while (check stdin?) is (arithm_result)
    :read arithm_result start date metadata;
  end while (empty)
  
  :create daily list of arithm_result;
  :Stage-out daily_list;
  
  stop 
  
**Step 3** use the ESA BEAM Toolbox Level 3 Binning processor to generated the daily binned products. This step is run with several tasks in parallel, each task dealing with one day of data.

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2
  
  start 
  
  while (check stdin?) is (daily_list)
    :Stage-in data referenced in daily_list;
  end while (empty)
  
  :Apply ESA BEAM Toolbox Binning operator;
  :Stage-out binned product;

  stop

This translates into a workflow containing two main processing steps: expression and binning plus an auxiliary processing step called arrange that arranges the outputs of the expression steps as the inputs for the binning processing step.

The workflow can be represented as:

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start

  :node_expression;
  :node_arrange;
  :node_binning;

  stop

Each node is described in details in :doc:`/field/ocean_color/lib_beam/nodes/index`

