# define the exit codes
SUCCESS=0
ERR_BINNING=20
ERR_PCONVERT=30

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "${retval}" in
     ${SUCCESS})      msg="Processing successfully concluded";;
     ${ERR_BINNING})  msg="gpt returned an error";;
     ${ERR_PCONVERT}) msg="pconvert returned an error";;
     *)             msg="Unknown error";;
   esac
   [ "${retval}" != "0" ] && ciop-log "ERROR" "Error ${retval} - ${msg}, processing aborted" || ciop-log "INFO" "${msg}"
   exit ${retval}
}

trap cleanExit EXIT

function createImage() {

  local format=$1

  band=3 # max. Change this if the algorithm is not MIN_MAX

  ${_CIOP_APPLICATION_PATH}/shared/bin/pconvert.sh \
    -f ${format} \
    -b ${band} ${TMPDIR}/${outputname}/${outputname}.dim  \
    -c ${TMPDIR}/palette.cpd  \
    -o ${TMPDIR}/${outputname} &> /dev/null || return $ERR_PCONVERT

  ciop-publish -m ${TMPDIR}/${outputname}/${outputname}.${format}

}

function set_env() {

  # retrieve the parameters value from workflow or job default value
  bandname="$( ciop-getparam bandname )"
  bitmask="$( ciop-getparam bitmask )"
  bbox="$( ciop-getparam bbox )"
  algorithm="$( ciop-getparam algorithm )"
  outputname="$( ciop-getparam outputname )"
  band="$( ciop-getparam band )"

  # split the bounding value
  xmin=$( echo $bbox | cut -d "," -f 1 )
  ymin=$( echo $bbox | cut -d "," -f 2 )
  xmax=$( echo $bbox | cut -d "," -f 3 )
  ymax=$( echo $bbox | cut -d "," -f 4 )

}

function main() {

  local list=$1
  file=${TMPDIR}/binning_request.xml

  # create a folder for the input products (results of node_expression)
  mkdir -p ${TMPDIR}/input

  # copy the list
  ciop-log "DEBUG" "list: ${list}"
  local_list=$( echo ${list} | ciop-copy -o ${TMPDIR} -)

  # copy the node_expression results locally
  cat ${local_list} | awk '{print $1}' | while read product
    do
      prod=$( echo ${product} | ciop-copy -U -o ${TMPDIR}/input - )
      ciop-log "INFO" "Retrieved $( basename ${prod} )"

      cd ${TMPDIR}/input
      tar xfz $( basename ${prod} )
     cd - &> /dev/null
   done

   # the third column of the node_arrange result contains the period start date
   outputname=$( cat ${local_list} | awk '{print $3}' | sort -u )
   ciop-log "DEBUG" "outputname: ${outputname}"

  # create a folder based on the outputname
  mkdir ${TMPDIR}/${outputname}

  # stage-in all results produced by the previous node

  # create the Binning graph
cat > ${file} << EOF
  <graph id="someGraphId">
    <version>1.0</version>
    <node id="someNodeId">
      <operator>Binning</operator>
<parameters>
    <sourceProductPaths>$( find ${TMPDIR}/input -name "*.dim" | tr "\n" "," )</sourceProductPaths>
    <region class="com.vividsolutions.jts.geom.Polygon">POLYGON ((${xmin} ${ymin}, ${xmax} ${ymin}, ${xmax} ${ymax}, ${xmin} ${ymax}, ${xmin} ${ymin}))</region>
    <timeFilterMethod>NONE</timeFilterMethod>
    <numRows>2160</numRows>
    <superSampling>1</superSampling>
    <maskExpr>${bitmask}</maskExpr>
    <variables/>
    <aggregators>
        <aggregator>
            <type>${algorithm}</type>
            <varName>${bandname}</varName>
            <targetName></targetName>
        </aggregator>
    </aggregators>
    <outputFile>${TMPDIR}/${outputname}/${outputname}.dim</outputFile>
</parameters>
 </node>
</graph>
EOF

  # invoke BEAM gpt with the created graph
  ciop-log "INFO" "Binning products"

  ${_CIOP_APPLICATION_PATH}/shared/bin/gpt.sh ${file} || return ${ERR_BINNING}

  ciop-log "INFO" "Compressing and publishing binned DIMAP product"
  tar -C ${TMPDIR}/${outputname} -czf ${TMPDIR}/${outputname}/${outputname}.tgz ${TMPDIR}/${outputname}/${outputname}.*

  # stage-out the binned product
  ciop-publish -m ${TMPDIR}/${outputname}/${outputname}.tgz

  ciop-log "INFO" "Generating image files"

  cat > $TMPDIR/palette.cpd << EOF
$( ciop-getparam "palette")
EOF

  createImage png || return $ERR_PCONVERT

  createImage tif || return $ERR_PCONVERT

  # clean-up for next list
  rm -fr ${TMPDIR}/input/*

  rm -fr ${TMPDIR}/${outputname}

}
