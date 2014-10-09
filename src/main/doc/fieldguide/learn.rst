What you will learn
===================

1. To manage test data in a sandbox - you will copy Envisat MERIS Level 1 Reduced Resolution data to the Sandbox. This data will be referenced in the Sandbox local catalogue
2. To create a simple application - you will implement an algal bloom detection application in four processing steps
3. To test the application - you will execute each of the processing steps individually and inspect the results and will then execute complete the workflow
4. To exploit the application - you will create the Web Processing Service (WPS) interface and invoke it

Where is the code
+++++++++++++++++

The code for this tutorial is available on GitHub repository `MERIS Algal bloom detection using BEAM <https://github.com/Terradue/dcs-beam-algalbloom>`_.

To deploy the tutorial on a Developer Sandbox:

.. code-block:: console

  cd ~
  git clone git@github.com:Terradue/dcs-beam-algalbloom.git
  cd dcs-beam-algalbloom
  mvn install
  
This will build and install the application on the /application volume.

The code can be modified by forking the repository here: `<https://github.com/Terradue/dcs-beam-algalbloom/fork>`_
