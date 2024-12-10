#Calibre rule file
rule_file=/proj/vendors/samsung/ln04lpp/pdk/calibre/LN04LPP_CalibreLVS_S00-V1.0.8.0/LVS/calibre.run
#Calibre command
cal_cmd="launch -c mgc/calibre calibre -lvs -hier -automatch -turbo -hyper -spice <DESIGN_NAME>.spice $rule_file | tee calibre_lvs_run.log"

launch_cmd="blaunch --cpus <CPU_COUNT> --mem <MEMORY> --jobname <DESIGN_NAME>_LVS_JOB \"$cal_cmd\""

eval "$launch_cmd |& tee -a slurm_launch.log"
