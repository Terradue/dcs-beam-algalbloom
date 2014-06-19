#! /bin/sh

export BEAM4_HOME=$_CIOP_APPLICATION_PATH/shared

if [ -z "$BEAM4_HOME" ]; then
    echo
    echo Error: BEAM4_HOME not found in your environment.
    echo Please set the BEAM4_HOME variable in your environment to match the
    echo location of the BEAM 4.x installation
    echo
    exit 2
fi

. "$BEAM4_HOME/bin/detect_java.sh"

"$app_java_home/bin/java" \
    -Xmx1024m \
    -Dceres.context=beam \
    "-Dbeam.mainClass=org.esa.beam.framework.gpf.main.GPT" \
    "-Dbeam.home=$BEAM4_HOME" \
    "-Dncsa.hdf.hdflib.HDFLibrary.hdflib=$BEAM4_HOME/lib/lib-hdf/lib/libjhdf.so" \
    "-Dncsa.hdf.hdf5lib.H5.hdf5lib=$BEAM4_HOME/lib/lib-hdf/lib/libjhdf5.so" \
    -jar "$BEAM4_HOME/lib/ceres-launcher.jar" "$@"

exit $?
