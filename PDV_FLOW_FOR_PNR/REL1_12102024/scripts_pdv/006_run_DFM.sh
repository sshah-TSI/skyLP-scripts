export DFM_CONFIG_FILE=${TECHDIR}/DFM/Include/DFM_configfile.tvf
launch_cmd="blaunch --cpus <CPU_COUNT> --mem <MEMORY> --jobname <DESIGN_NAME>_DFM \"launch -c mgc/calibre calibre -drc -hier -turbo -hyper ${DFM_CONFIG_FILE} | tee calibre_dfm_run.log\""
eval "$launch_cmd"
