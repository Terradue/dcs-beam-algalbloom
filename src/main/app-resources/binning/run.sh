#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_BINNING=20
ERR_PCONVERT=30

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS)      msg="Processing successfully concluded";;
     $ERR_BINNING)  msg="gpt returned an error";;
     $ERR_PCONVERT) msg="pconvert returned an error";;
     *)             msg="Unknown error";;
   esac
   [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
   exit $retval
}
trap cleanExit EXIT

function createImage() {
		
  band=3 # max. Change this if the algorithm is not MIN_MAX
		
  $_CIOP_APPLICATION_PATH/shared/bin/pconvert.sh -f $1 \
					-b $band $TMPDIR/output/$outputname.dim  \
					-c $TMPDIR/palette.cpd  \
					-o $TMPDIR/output &> /dev/null
	
  [ "$?" == "0" ] || return $ERR_PCONVERT

  ciop-publish -m $TMPDIR/output/$outputname.$1
	
}


# retrieve the parameters value from workflow or job default value
bandname="`ciop-getparam bandname`"
bitmask="`ciop-getparam bitmask`"
bbox="`ciop-getparam bbox`"
algorithm="`ciop-getparam algorithm`"
outputname="`ciop-getparam outputname`"
band="`ciop-getparam band`"

# split the bounding value
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
  tar xzf `basename $prod` -C  $TMPDIR/input
done

# create the Binning graph
cat > $file << EOF
  <graph id="someGraphId">
    <version>1.0</version>
    <node id="someNodeId">
      <operator>Binning</operator>
<parameters>
    <sourceProductPaths>`find $TMPDIR/input -name "*.dim" | tr "\n" ","`</sourceProductPaths>
    <region class="com.vividsolutions.jts.geom.Polygon">POLYGON (($xmin $ymin, $xmax $ymin, $xmax $ymax, $xmin $ymax, $xmin $ymin))</region>
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

# invoke BEAM gpt with the created graph
$_CIOP_APPLICATION_PATH/shared/bin/gpt.sh $file 
[ "$?" == "0" ] || exit $ERR_BINNING

ciop-log "INFO" "Compressing and publishing binned DIMAP product"

tar czf $TMPDIR/output/$outputname.tgz -C $TMPDIR/output $outputname.*
ciop-publish -m $TMPDIR/output/$outputname.tgz

ciop-log "INFO" "Generating image files"

cat > $TMPDIR/palette.cpd << EOF
`ciop-getparam "palette"`
EOF

createImage png 
[ "$?" == "0" ] || exit $ERR_PCONVERT

createImage tif 
[ "$?" == "0" ] || exit $ERR_PCONVERT

exit 0

