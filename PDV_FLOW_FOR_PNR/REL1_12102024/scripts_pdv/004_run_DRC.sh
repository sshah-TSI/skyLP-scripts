#Calibre rule file
rule_file=/proj/pd/vendors/samsung/ln04lpp/pdk/calibre/LN04LPP_CalibreDRC_S00-V1.0.8.0_c/DRC/cmos04lpp.drc.cal
#Calibre command
cal_cmd="launch -c mgc/calibre calibre -drc -hier -turbo -hyper $rule_file | tee calibre_drc_run.log"

launch_cmd="blaunch --cpus <CPU_COUNT> --mem <MEMORY> --jobname <DESIGN_NAME>_DRC_JOB \"$cal_cmd\""

eval "$launch_cmd |& tee -a slurm_launch.log"
