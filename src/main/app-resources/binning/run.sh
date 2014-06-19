#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

#export BEAM_HOME=/usr/lib/esa/beam-4.11
#export PATH=$BEAM_HOME/bin:$PATH

# define the exit codes
SUCCESS=0
ERR_NOINPUT=1
ERR_BINNING=2
ERR_NOPARAMS=5
ERR_JPEGTMP=7
ERR_BROWSE=9

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS)      msg="Processing successfully concluded";;
     $ERR_NOPARAMS) msg="Output format not defined";;
     $ERR_GDAL)    msg="Graph processing of job ${JOBNAME} failed (exit code $res)";;
     *)             msg="Unknown error";;
   esac
   [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
   exit $retval
}
trap cleanExit EXIT

function getVal() {
	cat $1 | grep $2 | cut -d '>' -f 2 | cut -d '<' -f 1 
}

function getValue() {
	cat $1 | grep $2 | cut -d '"' -f 2 | cut -d '"' -f 1
}

# retrieve the parameters value from workflow or job default value
cellsize="`ciop-getparam cellsize`"
bandname="`ciop-getparam bandname`"
bitmask="`ciop-getparam bitmask`"
bbox="`ciop-getparam bbox`"
algorithm="`ciop-getparam algorithm`"
outputname="`ciop-getparam outputname`"
compress="`ciop-getparam compress`"
band="`ciop-getparam band`"
tailor="`ciop-getparam tailor`"

# run a check on the format value, it can't be empty
#[ -z "$reflecAs" ] || [ -z "$normReflec" ] || [ -z "$cloudIceExpr" ] && exit $ERR_NOPARAMS

xmin=`echo $bbox | cut -d "," -f 1`
ymin=`echo $bbox | cut -d "," -f 2`
xmax=`echo $bbox | cut -d "," -f 3`
ymax=`echo $bbox | cut -d "," -f 4`

#l3db=$TMPDIR/l3_database.bindb
file=$TMPDIR/binning_request.xml

mkdir -p $TMPDIR/input
mkdir -p $TMPDIR/output

while read product
do
	prod=`echo $product | ciop-copy -U -o $TMPDIR/input -`
	cd $TMPDIR/input; tar xfz `basename $prod`; cd - &> /dev/null 
done

cat > $file << EOF
  <graph id="someGraphId">
    <version>1.0</version>
    <node id="someNodeId">
      <operator>Binning</operator>
<parameters>
    <sourceProductPaths>`find $TMPDIR/input -name "*.dim" | tr "\n" ","`</sourceProductPaths>
    <region class="com.vividsolutions.jts.geom.Polygon">POLYGON ((-180 -90, 180 -90, 180 90, -180 90, -180 -90))</region>
    <timeFilterMethod>NONE</timeFilterMethod>
    <numRows>2160</numRows>
    <superSampling>1</superSampling>
    <maskExpr>$bitmask</maskExpr>
    <variables/>
    <aggregators>
        <aggregator>
            <type>$algorithm</type>
            <varName>$bandname</varName>
            <targetName></targetName>
        </aggregator>
    </aggregators>
    <outputFile>$TMPDIR/output/$outputname.dim</outputFile>
</parameters>
 </node>
</graph>
EOF

cp $file /tmp
	$_CIOP_APPLICATION_PATH/shared/bin/gpt.sh $file 

	[ "$?" == "0" ] || exit $ERR_BINNING

	ciop-log "INFO" "Publishing binned DIMAP product"
	ciop-publish -m $TMPDIR/output/$outputname.dim
	ciop-publish -r -m $TMPDIR/output/$outputname.data

cat > $TMPDIR/palette.cpd << EOF
`ciop-getparam "palette"`
EOF

	ciop-log "INFO" "Generating image files"
	$_CIOP_APPLICATION_PATH/shared/bin/pconvert.sh -f png -b $band $TMPDIR/output/$outputname.dim -c $TMPDIR/palette.cpd -o $TMPDIR/output &> /dev/null
	[ "$?" == "0" ] || exit $ERR_PCONVERT

	ciop-publish -m $TMPDIR/output/$outputname.png
	
	$_CIOP_APPLICATION_PATH/shared/bin/pconvert.sh -f tif -b $band $TMPDIR/output/$outputname.dim -c  $TMPDIR/palette.cpd -o $TMPDIR/output &> /dev/null
	[ "$?" == "0" ] || exit $ERR_PCONVERT
	mv $TMPDIR/output/$outputname.tif $TMPDIR/output/$outputname.rgb.tif
	ciop-publish -m $TMPDIR/output/$outputname.rgb.tif
	
	$_CIOP_APPLICATION_PATH/shared/bin/pconvert.sh -f tif -b $band $TMPDIR/output/$outputname.dim -o $TMPDIR/output &> /dev/null
	[ "$?" == "0" ] || exit $ERR_PCONVERT
	ciop-publish -m $TMPDIR/output/$outputname.tif

	dim=$TMPDIR/output/$outputname.dim
	width=`getVal $dim NCOLS`
    height=`getVal $dim NROWS`

	minx=`getValue $dim EASTING`
    maxy=`getValue $dim NORTHING`
    resx=`getValue $dim PIXELSIZE_X`
    resy=`getValue $dim PIXELSIZE_Y`

    maxx=`echo "$minx + $width * $resx" | bc -l `
    miny=`echo "$maxy - $height * $resy" | bc -l `	

	convert -cache 1024 -size ${width}x${height} -depth 8 -interlace Partition $TMPDIR/output/$outputname.png $TMPDIR/tmp.jpeg &> /dev/null
	[ "$?" == "0" ] || exit $ERR_JPEGTMP
	
	ciop-log "INFO" "Generating the browse"
	convert -cache 1024 -size 150x150 -depth 8 -interlace Partition $TMPDIR/tmp.jpeg $TMPDIR/output/${outputname}_browse.jpg &> /dev/null
	[ "$?" == "0" ] || exit $ERR_BROWSE
	ciop-publish -m $TMPDIR/output/${outputname}_browse.jpg

exit 0

