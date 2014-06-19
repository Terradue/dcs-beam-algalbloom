#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

export BEAM_HOME=/usr/lib/esa/beam-4.11
export PATH=$BEAM_HOME/bin:$PATH

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

l3db=$TMPDIR/l3_database.bindb
file=$TMPDIR/binning_request.xml

mkdir -p $TMPDIR/input
mkdir -p $TMPDIR/output

while read product
do
	prod=`echo $product | ciop-copy -U -o $TMPDIR/input -`
	cd $TMPDIR/input; tar xfz `basename $prod`; cd - &> /dev/null 
done

# first part of request file
cat > $file << EOF
<?xml version="1.0" encoding="ISO-8859-1"?>
  <RequestList>
    <Request type="BINNING">
      <Parameter name="process_type" value="init" />
      <Parameter name="database" value="$l3db" />
      <Parameter name="lat_min" value="$ymin" />
      <Parameter name="lat_max" value="$ymax" />
      <Parameter name="lon_min" value="$xmin" />
      <Parameter name="lon_max" value="$xmax" />
      <Parameter name="log_prefix" value="l3" />
      <Parameter name="log_to_output" value="false" />
      <Parameter name="resampling_type" value="binning" />
      <Parameter name="grid_cell_size" value="$cellsize" />
      <Parameter name="band_name.0" value="$bandname" />
      <Parameter name="bitmask.0" value="$bitmask" />
      <Parameter name="binning_algorithm.0" value="$algorithm" />
      <Parameter name="weight_coefficient.0" value="1" />
    </Request>
    <Request type="BINNING">
      <Parameter name="process_type" value="update" />
      <Parameter name="database" value="$l3db" />
      <Parameter name="log_prefix" value="l3" />
      <Parameter name="log_to_output" value="false" />
EOF

for myfile in `find $TMPDIR/input -type f -name "*.dim"`
do
        echo "      <InputProduct URL=\"file://$myfile\" /> " >> $file
done
cat >> $file << EOF
    </Request>
    <Request type="BINNING">
      <Parameter name="process_type" value="finalize" />
      <Parameter name="database" value="$l3db" />
      <Parameter name="delete_db" value="true" />
      <Parameter name="log_prefix" value="l3" />
      <Parameter name="log_to_output" value="false" />
      <Parameter name="tailor" value="$tailor" />
      <OutputProduct URL="file:$TMPDIR/output/$outputname.dim" format="BEAM-DIMAP" />
    </Request>
</RequestList>
EOF

	binning.sh $file &> /dev/null
	[ "$?" == "0" ] || exit $ERR_BINNING

	ciop-log "INFO" "Publishing binned DIMAP product"
	ciop-publish -m $TMPDIR/output/$outputname.dim
	ciop-publish -rm $TMPDIR/output/$outputname.data

cat > $TMPDIR/palette.cpd << EOF
`ciop-getparam "palette"`
EOF

	ciop-log "INFO" "Generating image files"
	pconvert.sh -f png -b $band $TMPDIR/output/$outputname.dim -c $TMPDIR/palette.cpd -o $TMPDIR/output &> /dev/null
	[ "$?" == "0" ] || exit $ERR_PCONVERT

	ciop-publish -m $TMPDIR/output/$outputname.png
	
	pconvert.sh -f tif -b $band $TMPDIR/output/$outputname.dim -c  $TMPDIR/palette.cpd -o $TMPDIR/output &> /dev/null
	[ "$?" == "0" ] || exit $ERR_PCONVERT
	mv $TMPDIR/output/$outputname.tif $TMPDIR/output/$outputname.rgb.tif
	ciop-publish -m $TMPDIR/output/$outputname.rgb.tif
	
	pconvert.sh -f tif -b $band $TMPDIR/output/$outputname.dim -o $TMPDIR/output &> /dev/null
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

