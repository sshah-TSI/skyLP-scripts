cal_cmd="blaunch  --cpus 4 --mem 32 --jobname <DESIGN_NAME>_FLT \"launch -c mgc/calibre calibre -drc -hier -64 -hyper -turbo ${MAIN_RULE_FILE} | tee calibre_flt_run.log\""

eval "$cal_cmd"
