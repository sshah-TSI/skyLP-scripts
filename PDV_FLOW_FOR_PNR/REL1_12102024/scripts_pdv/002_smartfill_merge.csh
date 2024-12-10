## ;*************************************************************************************
## ;* (C) Copyright 2012-2024, Samsung, all rights reserved.							*
## ;*																					*
## ;* Samsung Confidential																*
## ;*																					*
## ;* This material is provided by Samsung solely on an "AS IS"	basis.					*
## ;* Samsung any of its employees, makes any representations or warranty of any kind, 	*
## ;* whether express or implied, or assumes any liability or responsibility for the 	*
## ;* accuracy, completeness, suitability or usefulness of this material or for any 	*
## ;* damages resulting from its use.													*
## ;*																					*
## ;*************************************************************************************

#------------------------------------------------------------------------------#
#	Check initial setting													   #
#------------------------------------------------------------------------------#
set PROC_NAME = "LN04LPP"

if ($WORK_DIR == "") then
	echo "Error : No information for WORK_DIR on Environment Setting."
	exit 1
else if (! -e $WORK_DIR) then
	echo "Error : $WORK_DIR is not exist."
	exit 1
else if (! -d $WORK_DIR) then
	echo "Error : $WORK_DIR is not a director."
	exit 1
else
	echo "WORK_DIR is set to $WORK_DIR"
endif

if ($TECHDIR == "") then
	echo "Error : No information for TECHDIR on Environment Setting."
	exit 1
else if (! -e $TECHDIR) then
	echo "Error : $TECHDIR is not exist."
	exit 1
else if (! -d $TECHDIR) then
	echo "Error : $TECHDIR is not a directory."
	exit 1
else if (! -d ${TECHDIR}/DummyFill) then
	echo "Error : No necessary files(DummyFill dir) to generate fill on ${TECHDIR}."
	exit 1
else if (! -d ${TECHDIR}/DummyScript) then
	echo "Error : No necessary files(DummyScript dir) to run fill deck on ${TECHDIR}."
	exit 1
else
	echo "TECHDIR is set to $TECHDIR"
	set TOOL_VERSION = `grep "SVRF VERSION" ${TECHDIR}/DummyFill/${PROC_NAME}.fill.cal | awk '{split($0, data, " ");print data[3]}' | sed -e s/\"//g | sed -e s/v//g`
	echo "TOOL_VERSION is set to ${TOOL_VERSION}"
endif

if ($LAYOUT_PATH == "") then
	echo "Error : No information for LAYOUT_PATH on Environment Setting."
	exit 1
else if (! -e $LAYOUT_PATH) then
	echo "Error : $LAYOUT_PATH is not exist."
	exit 1
else if (! -f $LAYOUT_PATH) then
	echo "Error : $LAYOUT_PATH is not a file."
	exit 1
else if (-z $LAYOUT_PATH) then
	echo "Error : $LAYOUT_PATH is zero size."
	exit 1
else
	echo "LAYOUT_PATH is set to $LAYOUT_PATH"
endif

if ($VAVB_REMOVAL_FOR_NW_SHORT == "") then
	echo "Warning : VAVB_REMOVAL_FOR_NW_SHORT is automatically set to ON"
	setenv VAVB_REMOVAL_FOR_NW_SHORT ON
else if ( ($VAVB_REMOVAL_FOR_NW_SHORT != "ON") && ($VAVB_REMOVAL_FOR_NW_SHORT != "OFF") ) then
	echo "Error : VAVB_REMOVAL_FOR_NW_SHORT is only possible \"ON\" or \"OFF\"."
	exit 1
else
	echo "VAVB_REMOVAL_FOR_NW_SHORT is set to $VAVB_REMOVAL_FOR_NW_SHORT"
endif

if ($LAYOUT_SYSTEM == "") then
	echo "Warning : LAYOUT_SYSTEM is automatically set to GDSII."
	setenv LAYOUT_SYSTEM GDSII
else if ( ($LAYOUT_SYSTEM != "GDSII") && ($LAYOUT_SYSTEM != "OASIS") ) then
	echo "Error : LAYOUT_SYSTEM is only possible \"GDSII\" or \"OASIS\"."
	exit 1
else
	echo "LAYOUT_SYSTEM is set to $LAYOUT_SYSTEM"
endif

if ($OUTPUT_FORMAT == "") then
	echo "Warning : OUTPUT_FORMAT is automatically set to GDSII."
	setenv OUTPUT_FORMAT GDSII
else if ( ($OUTPUT_FORMAT != "GDSII") && ($OUTPUT_FORMAT != "OASIS") ) then
	echo "Error : OUTPUT FORMAT is only possible \"OASIS\" or \"GDSII\"."
	exit 1
else
	echo "OUTPUT_FORMAT is set to $OUTPUT_FORMAT"
endif

if ($MIM_SET == "") then
	echo "Error : No information for MIM_SET on Environment Setting"
	exit 1
else if ( ($MIM_SET != "ON") && ($MIM_SET != "OFF") ) then
	echo "MIM_SET is only possible ON or OFF"
	exit 1
else if ( ($MIM_SET == "ON") ) then
	if ( $MIMCAP_OPTION == "") then
		echo "Error : When MIM_SET is set to ON, MIMCAP_OPTION should be set to 2PLATE_ON, 3PLATE_ON or 4PLATE_ON"
		exit 1
	else if (($MIMCAP_OPTION != "2PLATE_ON") && ($MIMCAP_OPTION != "3PLATE_ON") && ($MIMCAP_OPTION != "4PLATE_ON")) then
		echo "Error : MIMCAP_OPTION is only possible 2PLATE_ON or 3PLATE_ON"
		exit 1
	else
		echo "MIM_SET is set to $MIM_SET"
		echo "MIMCAP_OPTION is set to $MIMCAP_OPTION"
	endif
else if ($MIM_SET == "OFF") then
	echo "MIM_SET is set to $MIM_SET"
	setenv MIMCAP_OPTION
else
	echo "MIM_SET is set to ${MIM_SET}"
	if ($MIM_SET == "OFF") then
            setenv MIMCAP_OPTION
	endif
endif

if ($C_ORIENTATION == "") then
	echo "Warning : C_ORIENTATION is automatically set to VERTICAL."
	setenv C_ORIENTATION VERTICAL
else if ( ($C_ORIENTATION != "VERTICAL") && ($C_ORIENTATION != "HORIZONTAL") ) then
	echo "Error : C_ORIENTATION is only possible \"VERTICAL\" or \"HORIZONTAL\"."
	exit 1
else
	echo "C_ORIENTATION is set to $C_ORIENTATION"
endif

if ($FEOL_EXCLUD_OPT == "") then
	echo "Warning : FEOL_EXCLUD_OPT is automatically set to FEOL_EXCL_OPT1_ON"
	setenv FEOL_EXCL_OPT1_ON
else if ( ($FEOL_EXCLUD_OPT != "FEOL_EXCL_OPT1_ON") && ($FEOL_EXCLUD_OPT != "FEOL_EXCL_OPT2_ON") && ($FEOL_EXCLUD_OPT != "FEOL_EXCL_OPT3_ON") ) then
 	echo "Error : FEOL_EXCLUD_OPT is only possible FEOL_EXCL_OPT1_ON, FEOL_EXCL_OPT2_ON, FEOL_EXCL_OPT3_ON."
	exit 1
else
    echo "FEOL_EXCLUD_OPT is set to $FEOL_EXCLUD_OPT"
endif

if ($BEOL_EXCLUD_OPT == "") then
	echo "Warning : BEOL_EXCLUD_OPT is automatically set to BEOL_EXCL_OPT1_ON"
	setenv BEOL_EXCL_OPT1_ON
else if ( ($BEOL_EXCLUD_OPT != "BEOL_EXCL_OPT1_ON") && ($BEOL_EXCLUD_OPT != "BEOL_EXCL_OPT2_ON") && ($BEOL_EXCLUD_OPT != "BEOL_EXCL_OPT3_ON")) then
 	echo "Error : BEOL_EXCLUD_OPT is only possible BEOL_EXCL_OPT1_ON, BEOL_EXCL_OPT2_ON, BEOL_EXCL_OPT3_ON "
	exit 1
else
    echo "BEOL_EXCLUD_OPT is set to $BEOL_EXCLUD_OPT"
endif

if ($TOPCELL == "") then
	echo "Error : No information for TOPCELL on Environment Setting"
	exit 1
else
	echo "TOPCELL is set to ${TOPCELL}"
endif

if ($BEOL_STACK == "") then
	echo "Warning : BEOL_STACK is automatically set to 14M_3Mx_2Fx_7Dx_2Iz_LB."
	setenv BEOL_STACK 14M_3Mx_2Fx_7Dx_2Iz_LB
else if ( $BEOL_STACK != "14M_3Mx_2Fx_7Dx_2Iz_LB" && $BEOL_STACK != "14M_3Mx_1Fx_8Dx_2Iz_LB" && $BEOL_STACK != "16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB") then
	echo "Error : BEOL_STACK is only possible 14M_3Mx_2Fx_7Dx_2Iz_LB, 14M_3Mx_1Fx_8Dx_2Iz_LB, 16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB"
	exit 1
else
	echo "BEOL_STACK is set to $BEOL_STACK"
endif

set SELECT_LAYER = `echo $SELECT_LAYER | sed -e "s/ /:/g"`

if ($SELECT_LAYER == "") then
	echo "Error : SELECT_LAYER should be set."
	exit 1
else
	echo "SELECT_LAYER is set to `echo $SELECT_LAYER | sed -e 's/:/,/g'`"
endif

if ($CPU_COUNT == "") then
	echo "Warning : CPU_COUNT is automatically set to 4."
	setenv CPU_COUNT 4
else
	echo "CPU_COUNT is set to $CPU_COUNT"
    echo "*** CAUTION ***"
    echo "*** Please check LSF CPU support environment"
    echo "*** Check your jobs using bjobs command ***"
endif

if ($DESIGN_TYPE == "") then
	echo "Error : DESIGN_TYPE should be set."
	exit 1
else
	echo "DESIGN_TYPE is set to $DESIGN_TYPE"
endif

if ($RUN_METHOD == "") then
	echo "Warning : RUN_METHOD is automatically set to LOCAL."
	setenv RUN_METHOD LOCAL
else if ( ($RUN_METHOD != "LSF") && ($RUN_METHOD != "LOCAL") ) then
	echo "Error : RUN_METHOD is only possible LSF or LOCAL"
	exit 1
else
	echo "RUN_METHOD is set to $RUN_METHOD"
endif

if ($MERGE_FLOW == "") then
	echo "Warning : MERGE_FLOW is automatically set to ON."
	setenv MERGE_FLOW ON
else if ( ($MERGE_FLOW != "ON") && ($MERGE_FLOW != "OFF") ) then
	echo "Error : MERGE_FLOW is only possible ON or OFF"
	exit 1
else
	echo "MERGE_FLOW is set to $MERGE_FLOW"
endif

if ($GEN_3DIC == "") then
	echo "Warning : GEN_3DIC is automatically set to OFF."
	setenv GEN_3DIC OFF
else if ( ($GEN_3DIC != "ON") && ($GEN_3DIC != "OFF") ) then
	echo "Error : GEN_3DIC is only possible ON or OFF."
	exit 1
else if ( ($GEN_3DIC == "ON") && ($DESIGN_TYPE == "CELL") ) then
	echo "Error : GEN_3DIC ON is only possible when DESIGN_TYPE is CHIP."
	exit 1
else if ( ($GEN_3DIC == "ON") && (($BEOL_STACK != "14M_3Mx_2Fx_7Dx_2Iz_LB") && ($BEOL_STACK != "16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB")) ) then
	echo "Error : GEN_3DIC ON is only possible when BEOL_STACK is 14M_3Mx_2Fx_7Dx_2Iz_LB, 16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB."
	exit 1
else
	echo "GEN_3DIC is set to $GEN_3DIC."
endif

set chk_eco = `printenv ECO_VIA_SET`
if ( $chk_eco == "" ) then
	setenv ECO_VIA_SET "OFF"
else if ( ($chk_eco != "ON") && ($chk_eco != "OFF") ) then
	echo "Error : ECO_VIA_SET is only possible ON or OFF"
	exit 1
else
	echo "ECO_VIA_SET is set to $chk_eco"
endif

#------------------------------------------------------------------------------#
#       Make directory														   #
#------------------------------------------------------------------------------#

if ($MERGE_FLOW == "ON") then
	mkdir -p ${WORK_DIR}/DMM_OUTPUT ${WORK_DIR}/MERGED_OUTPUT
else
	mkdir -p ${WORK_DIR}/DMM_OUTPUT
endif

mkdir -p ${WORK_DIR}/DMM_OUTPUT/Output ${WORK_DIR}/DMM_OUTPUT/LogFile ${WORK_DIR}/DMM_OUTPUT/EnvFiles ${WORK_DIR}/DMM_OUTPUT/Etc

#------------------------------------------------------------------------------#
#      Make env file for running Fill deck									   #
#------------------------------------------------------------------------------#
set ENV_FILE = "${WORK_DIR}/4lp_fill_${TOPCELL}.env"


if (-f $ENV_FILE) then
	\rm -rf $ENV_FILE
endif

if ($OUTPUT_FORMAT == "OASIS") then
	set ext_name = "oas"
else
	set ext_name = "gds"
endif

set fill_deck_path = "${TECHDIR}/DummyFill"
set fill_script_path = "${TECHDIR}/DummyScript"
setenv original_techdir "${TECHDIR}"

  echo "setenv TECHDIR $fill_deck_path" >> $ENV_FILE
  echo "setenv LAYOUT_PATH ${LAYOUT_PATH}" >> $ENV_FILE
  echo "setenv CALIBRE_LAYOUT_PRIMARY ${TOPCELL}" >> $ENV_FILE
  echo "setenv feol_dmm_output ${WORK_DIR}/DMM_OUTPUT/FEOL_DMM_${TOPCELL}.${ext_name}" >> $ENV_FILE
  echo "setenv beol_dmm_output ${WORK_DIR}/DMM_OUTPUT/BEOL_DMM_${TOPCELL}.${ext_name}" >> $ENV_FILE
  echo "setenv output_sum ${WORK_DIR}/DMM_OUTPUT/DMM_${TOPCELL}.sum" >> $ENV_FILE
  echo "setenv LAYOUT_SYSTEM ${LAYOUT_SYSTEM}" >> $ENV_FILE
  echo "setenv OUTPUT_LAYOUT_SYSTEM ${OUTPUT_FORMAT}" >> $ENV_FILE
  echo "setenv BEOL_STACK ${BEOL_STACK}" >> $ENV_FILE
  echo "setenv C_ORIENTATION ${C_ORIENTATION}" >> $ENV_FILE
  echo "setenv DESIGN_TYPE ${DESIGN_TYPE}" >> $ENV_FILE
  echo "setenv MIM_SET ${MIM_SET}" >> $ENV_FILE
  echo "setenv MIMCAP_OPTION ${MIMCAP_OPTION}" >> $ENV_FILE
  echo "setenv FEOL_EXCLUD_OPT ${FEOL_EXCLUD_OPT}" >> $ENV_FILE
  echo "setenv BEOL_EXCLUD_OPT ${BEOL_EXCLUD_OPT}" >> $ENV_FILE
  echo "setenv GEN_3DIC ${GEN_3DIC}" >> $ENV_FILE
  echo "setenv VAVB_REMOVAL_FOR_NW_SHORT ${VAVB_REMOVAL_FOR_NW_SHORT}" >> $ENV_FILE
  if (($SELECT_LAYER == "ALL") || ($SELECT_LAYER == "")) then
  	echo "setenv MULTI_LAYER ALL" >> $ENV_FILE
  else if ( $SELECT_LAYER == "BEOL" ) then
  	echo "setenv MULTI_LAYER BEOL" >> $ENV_FILE
  else if ( $SELECT_LAYER == "FEOL") then
  	echo "setenv MULTI_LAYER FEOL" >> $ENV_FILE
  else
  	echo "setenv MULTI_LAYER EACH_LAYER" >> $ENV_FILE
  	echo 'setenv EACH_LAYERS_LIST "'"`echo ${SELECT_LAYER} | sed -e 's/:/ /g'`"'"' >> $ENV_FILE
  endif

if ($chk_eco == "ON") then
	echo "setenv ECO_VIA_SET ON" >> $ENV_FILE
endif

#--------------------------------------------------------------------------#
#                       FILL GDS FILE GENERATION		           #
#--------------------------------------------------------------------------#
set flag_abort = "0"

  if ($CPU_COUNT == "1") then
	if ($RUN_METHOD == "LSF") then
		echo "Calibre command : launch -c mgc/calibre calibre_sub drc -mode hier -v ${TOOL_VERSION} -Is  -src ${ENV_FILE} -i $fill_deck_path/${PROC_NAME}.fill.cal"
		launch -c mgc/calibre calibre_sub drc -mode hier -v ${TOOL_VERSION} -Is -src ${ENV_FILE} -i $fill_deck_path/${PROC_NAME}.fill.cal | tee drc.fillgen.${TOPCELL}.log
	else
		echo "Calibre command : launch -c mgc/calibre calibre -drc -hier $fill_deck_path/${PROC_NAME}.fill.cal"
		source ${ENV_FILE}
		launch -c mgc/calibre calibre -drc -hier $fill_deck_path/${PROC_NAME}.fill.cal | tee drc.fillgen.${TOPCELL}.log
	endif
  else
	if ($RUN_METHOD == "LSF") then
#		echo "Calibre command : launch -c mgc/calibre calibre_sub drc -mode hier -v ${TOOL_VERSION} -Is -cpu ${CPU_COUNT} -etc -hyper -src ${ENV_FILE} -i $fill_deck_path/${PROC_NAME}.fill.cal"
#		launch -c mgc/calibre calibre_sub drc -mode hier -v ${TOOL_VERSION} -Is -cpu ${CPU_COUNT} -etc -hyper -src ${ENV_FILE} -i $fill_deck_path/${PROC_NAME}.fill.cal | tee drc.fillgen.${TOPCELL}.log
		echo "Calibre command : launch -c mgc/calibre calibre -drc -hier -turbo ${CPU_COUNT} -64 -hyper $fill_deck_path/${PROC_NAME}.fill.cal"
		source ${ENV_FILE}
		blaunch --cpus $CPU_COUNT --mem $MEMORY --jobname Smartfill_$TOPCELL "launch -c mgc/calibre calibre -drc -hier -turbo ${CPU_COUNT} -64 -hyper $fill_deck_path/${PROC_NAME}.fill.cal | tee drc.fillgen.${TOPCELL}.log"
	else
		echo "Calibre command : launch -c mgc/calibre calibre -drc -hier -turbo ${CPU_COUNT} -64 -hyper $fill_deck_path/${PROC_NAME}.fill.cal"
		source ${ENV_FILE}
		blaunch --cpus $CPU_COUNT --mem $MEMORY --jobname Smartfill_$TOPCELL "launch -c mgc/calibre calibre -drc -hier -turbo ${CPU_COUNT} -64 -hyper $fill_deck_path/${PROC_NAME}.fill.cal | tee drc.fillgen.${TOPCELL}.log"
	endif
  endif

  while(1)
	if(-e ${WORK_DIR}/drc.fillgen.${TOPCELL}.log) then
		if(`grep -c ERROR: ${WORK_DIR}/drc.fillgen.${TOPCELL}.log` != 0) then
			echo "****************************************************************************"
			echo " RUNNING CALIBRE WAS NOT COMPLETED.  "
			grep "ERROR:" ${WORK_DIR}/drc.fillgen.${TOPCELL}.log
			echo "****************************************************************************"
			set flag_abort = "1"
			break
		else if(-e ${WORK_DIR}/DMM_OUTPUT/DMM_${TOPCELL}.sum) then
			echo "***************************************************************"
			echo "  FILL GENERATION WAS SUCCESSFULLY COMPLETED         "
			echo "  CHECK OUT ${WORK_DIR}/DMM_OUTPUT/DMM_${TOPCELL}.sum "
			echo "***************************************************************"
			break
		endif
	else
		sleep 120
		echo "fill generation hasn't been completed."
		echo "wait for fill generation job to be done."
	endif
  end

mv $ENV_FILE drc.*.log *.rdb ${WORK_DIR}/DMM_OUTPUT

#flag_abort if
if ($flag_abort == "0") then
#------------------------------------------------------------------------------#
#     Swap & Merge Main GDS and Fill Patterns								   #
#------------------------------------------------------------------------------#
set today = _dmy`date '+%y%m%d%H%M%S'`
setenv MOD_DATE $today

#################################################################################
#                         SWAP AND MERGE SCRIPT                                 #
#################################################################################
setenv TCL_PATH $fill_script_path

set merge_script = "${WORK_DIR}/${TOPCELL}_merge.tcl"
echo "set WORK_DIR $WORK_DIR" > ${merge_script}
echo "set TECHDIR $TCL_PATH" >> ${merge_script}
echo "set OUT_TOP $TOPCELL" >> ${merge_script}
echo "set OUTPUT_TYPE $OUTPUT_FORMAT" >> ${merge_script}
echo "set DMM_SUFFIX $MOD_DATE" >> ${merge_script}
echo "set SWAP_PATH $original_techdir" >> ${merge_script}
echo "set SWAP_ORIENTATION $C_ORIENTATION" >> ${merge_script}
echo "set MERGE_FLOW $MERGE_FLOW" >> ${merge_script}

echo 'source "${TECHDIR}/merge_sub.tcl"' >> ${merge_script}

# Check Fill generating status
# If Fill output doesn't exist, Log file has "total ( HGC=0 FGC=0 )".
setenv FEOL_GDS ${WORK_DIR}/DMM_OUTPUT/FEOL_DMM_${TOPCELL}.${ext_name}

if(! -e $FEOL_GDS) then
	setenv FEOL_GDS empty
endif

setenv BEOL_GDS ${WORK_DIR}/DMM_OUTPUT/BEOL_DMM_${TOPCELL}.${ext_name}

if(! -e $BEOL_GDS) then
	setenv BEOL_GDS empty
endif

set chk_output = `grep "( HGC=0 FGC=0 )" ${WORK_DIR}/DMM_OUTPUT/drc.fillgen.${TOPCELL}.log | grep "total" | sed -e 's/ /_/g'`
if ($chk_output != "") then
	echo "${FEOL_GDS} is empty"
	echo "${BEOL_GDS} is empty"
	setenv FEOL_GDS empty
	setenv BEOL_GDS empty
endif

# If Both BEOL_GDS and FEOL_GDS is "empty", Fill geneartion Flow is DONE.
if ((${BEOL_GDS} == "empty") && (${FEOL_GDS} == "empty")) then
	echo "**************************************************************"
	echo " NO GENERATED FEOL/BEOL FILL OUTPUT							"
	echo " COULD YOU PLEASE CHECK FILL GENERATION CONDITION IN INPUT DB "
	echo "**************************************************************"
else
	# Running dummy_merge.tcl
	if ($RUN_METHOD == "LSF") then
	  echo "Calibre command: calview_sub -drv -v 2021.4_26.12 -rcxt ${WORK_DIR}/${TOPCELL}_merge.tcl ${FEOL_GDS} ${BEOL_GDS} ${LAYOUT_PATH}"
	  pushd ${WORK_DIR}
#	  calview_sub -drv -v 2021.4_26.12 ${WORK_DIR}/${TOPCELL}_merge.tcl ${FEOL_GDS} ${BEOL_GDS} ${LAYOUT_PATH}
	  blaunch --cpus $CPU_COUNT --mem $MEMORY --jobname fill_merge_$TOPCELL "launch -c mgc/calibre calibredrv -64 ${WORK_DIR}/MERGED_OUTPUT/${TOPCELL}_merge.tcl ${FEOL_GDS} ${BEOL_GDS} ${LAYOUT_PATH} | tee drv.${TOPCELL}.log"
	  popd
	else
	  echo "Calibre command: launch -c mgc/calibre calibredrv -64 ${WORK_DIR}/${TOPCELL}_merge.tcl ${FEOL_GDS} ${BEOL_GDS} ${LAYOUT_PATH}"
	  pushd ${WORK_DIR}
	  blaunch --cpus $CPU_COUNT --mem $MEMORY --jobname fill_merge_$TOPCELL "launch -c mgc/calibre calibredrv -64 ${WORK_DIR}/MERGED_OUTPUT/${TOPCELL}_merge.tcl ${FEOL_GDS} ${BEOL_GDS} ${LAYOUT_PATH} | tee drv.${TOPCELL}.log"
	  popd
	endif

	if ($MERGE_FLOW == "ON") then
	    \rm -rf ${WORK_DIR}/MERGED_OUTPUT/${TOPCELL}_tmp*.${ext_name}
	    mv ${TOPCELL}_*merge*.tcl drv.*.log ${WORK_DIR}/MERGED_OUTPUT
	    while(1)
		    if (-e ${WORK_DIR}/MERGED_OUTPUT/${TOPCELL}_merge_done.rpt) then
	    		echo "*****************************************************************"
	    		echo "  MERGING FLOW WAS SUCCESSFULLY DONE "
	    		echo "  CHECK OUT ${WORK_DIR}/MERGED_OUTPUT/${TOPCELL}_DummyMerge.${ext_name}"
	    		echo "*****************************************************************"
	    		break
	    	else
	    		sleep 120
	    		echo "gds merge hasn't been completed"
	    		echo "wait for gds merge job to be done"
	    	endif
	    end
	else
	    mv ${TOPCELL}_*merge*.tcl drv.*.log ${WORK_DIR}/DMM_OUTPUT
	    while(1)
	    	if (-e ${WORK_DIR}/DMM_OUTPUT/${TOPCELL}_swap_done.rpt) then
	    		echo "*****************************************************************"
	    		echo "  MERGING FLOW WAS SUCCESSFULLY DONE "
	    		echo "  CHECK OUT ${WORK_DIR}/DMM_OUTPUT/${TOPCELL}_DummySwap.${ext_name}"
	    		echo "*****************************************************************"
	    		break
	    	else
	    		sleep 120
	    		echo "gds merge hasn't been completed"
	    		echo "wait for gds merge job to be done"
	    	endif
	    end
	endif
endif
endif #flag_abort

\rm -rf ${WORK_DIR}/*out
mv ${WORK_DIR}/DMM_OUTPUT/*log ${WORK_DIR}/DMM_OUTPUT/LogFile
mv ${WORK_DIR}/DMM_OUTPUT/*gds ${WORK_DIR}/DMM_OUTPUT/Output
mv ${WORK_DIR}/DMM_OUTPUT/*oas ${WORK_DIR}/DMM_OUTPUT/Output
mv ${WORK_DIR}/DMM_OUTPUT/*env ${WORK_DIR}/DMM_OUTPUT/EnvFiles
mv ${WORK_DIR}/DMM_OUTPUT/*.* ${WORK_DIR}/DMM_OUTPUT/Etc
