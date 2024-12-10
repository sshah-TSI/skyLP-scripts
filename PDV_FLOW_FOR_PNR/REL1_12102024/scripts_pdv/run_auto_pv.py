#!/usr/bin/env python3
import os
import sys
import subprocess
import multiprocessing
import argparse
import textwrap
import shutil
import yaml
import time
import threading
import tkinter as tk
from datetime import datetime
from tkinter import *
from tkinter import ttk
import ttkbootstrap as tb
from ttkbootstrap.scrolled import ScrolledText
from multiprocessing import Process, Queue

now = datetime.now()
dt_string = now.strftime("%d-%m_%H-%M")

####Adding arguments to the main arg parser####

startup_parser = argparse.ArgumentParser(description='Flex-Flow Startup')
startup_parser.add_argument('--argument', action='help', default=argparse.SUPPRESS,
        help=textwrap.dedent('''\
        Usage:- python run_auto_pv.py <Options>\n
        --yaml_file:- specifies the yaml file with user config defined\n
        --run_tag:-  specifies the PnR run tag/directory absolute path'''))
startup_parser.add_argument('--yaml_file')
startup_parser.add_argument('--run_tag')

####Loading the yaml_file####

args = vars(startup_parser.parse_args())

if os.path.isfile(args['yaml_file']) == True:
    with open (args['yaml_file'], 'r') as stream:
        load_data = yaml.safe_load(stream)
    with open ('PDV_GOLDEN_SETTING.yaml', 'r') as stream:
                load_gol_data = yaml.safe_load(stream)

####Creating workarea####

workarea = args['run_tag']+'/reports_pv'
os.makedirs(os.path.join(workarea), exist_ok=True)
PV_RUNS = ['001_LAYOUT_MERGE', '002_SMARTFILL_MERGE', '003_V2LVS', '004_DRC', '005_LVS', '006_DFM', '007_FLT']
for folder in PV_RUNS:
    os.makedirs(os.path.join(workarea,folder), exist_ok=True)

####Defining a tailf function####

def tailf(filename):
    #returns lines from a file, starting from the beginning
    command = "tail -n +1 -F " + filename
    p = subprocess.Popen(command.split(), stdout=subprocess.PIPE, universal_newlines=True)
    for line in p.stdout:
        yield line

####Defining a file append method####

def append_files(file1_path, file2_path):
    with open(file1_path, 'r') as file1:
        with open(file2_path, 'a') as file2:
            shutil.copyfileobj(file1, file2)

####Defining the executor class####

job_done = 0

class executor:
    def __init__(self, work, command, log_file, keyword, text_box):
        self.work = work
        self.command = command
        self.log_file = log_file
        self.keyword = keyword
        self.text_box = text_box

    def execute(self):
        os.chdir(self.work)
        os.system(self.command)
    
    def logging(self):
        while not os.path.exists(self.log_file):
            self.text_box.tag_config('Queueing', background="white", foreground="blue")
            self.text_box.insert(tk.END, "Job submitted to queue\n", 'Queueing')
            self.text_box.yview(END)
            time.sleep(10)
        if os.path.isfile(self.log_file):
            self.text_box.insert(tk.END, "Job started\n")
            self.text_box.yview(END)
            for line in tailf(self.log_file):
                self.text_box.insert(tk.END, line)
                self.text_box.yview(END)
                if self.keyword in line:
                    self.text_box.tag_config('Success', background="white", foreground="green")
                    self.text_box.insert(tk.END, "Job Completed Successfully\n", 'Success')
                    self.text_box.yview(END)
                    global job_done
                    job_done += 1

####Common variable####

Design = load_data.get('DESIGN_NAME')
CPU_COUNT = load_data["SLURM_VAR"][0]['CPU']
MEMORY = load_data["SLURM_VAR"][0]['MEMORY']

####Building the GUI####

####Creating Root for Job Monitor####

root = tk.Tk()
root.title('Flex-Flow Job Monitor ' + Design + ' - ' + args['run_tag'])
root.geometry('1000x500')
root.resizable(0, 0)
        
####Create NoteBook####
book = ttk.Notebook(root)
book.pack(fill=tk.BOTH, expand=1)

####Dumping the run scripts####

####001####

BBOX = args['run_tag']+'/dbs/'+load_data['DESIGN_STAGE']+'/'+load_data['DESIGN_NAME']+'.gds.gz'
if os.path.isfile(BBOX):
    print(BBOX+' GDS exists')
    with open ('001_layout_merge.tcl', 'r') as file_in:
        contents = file_in.read()
        new_content = contents.replace("<TOP_CELL_NAME>", Design).replace("<BBOX_GDS_PATH>", BBOX)
    with open (workarea+'/001_LAYOUT_MERGE/calibre_filemerge.tcl', 'w+') as file_out:
        file_out.write(new_content)
    CMD_001 = "blaunch --cpus 1 --mem 16 --jobname filemerge_"+ Design +" \"launch -c mgc/calibre calibredrv -64 ./calibre_filemerge.tcl | tee calibre_merge.log\""
    KEYWORD_001 = "Merge completed successfully"
    WORK_001 = workarea + "/001_LAYOUT_MERGE"
    LOG_001 = WORK_001 + "/calibre_merge.log"
else:
    print(BBOX+ ' GDS not present')
    sys.exit('Please provide a valid run_tag')

####002####

SMARTFILL_MERGE_GOL_VAR = load_gol_data["SMARTFILL_MERGE_VAR"][0]
first_line="####Flex Flow FILL VAR####"
final_list=[]
final_list.append(first_line)
for k,v in SMARTFILL_MERGE_GOL_VAR.items():
    set_var="setenv "+k+" "+v
    final_list.append(set_var)
final_list.append("setenv TOPCELL " + Design)
final_list.append("setenv CPU_COUNT " + CPU_COUNT)
final_list.append("setenv MEMORY " + MEMORY)
final_list.append("setenv WORK_DIR " + workarea + "/002_SMARTFILL_MERGE")
final_list.append("setenv LAYOUT_PATH " + workarea + "/001_LAYOUT_MERGE/" + Design + "_merged.gds.gz")
with open(workarea+'/002_SMARTFILL_MERGE/main_fill.csh', 'w+') as f:
    for line in final_list:
        f.write(f"{line}\n")
append_files('002_smartfill_merge.csh', workarea+'/002_SMARTFILL_MERGE/main_fill.csh')
CMD_002 = "csh main_fill.csh"
KEYWORD_002 = "SUMMARY REPORT FILE"
WORK_002 = workarea + "/002_SMARTFILL_MERGE"
LOG_002 = WORK_002 + "/drc.fillgen.scuw.log"

####003####

NETLIST = args['run_tag']+'/dbs/'+load_data['DESIGN_STAGE']+'/'+load_data['DESIGN_NAME']+'.lvs.v'
if os.path.isfile(NETLIST):
    print(NETLIST+ ' LVS.V exists')
    with open ('003_v2lvs_script.tcl', 'r') as file_in:
        contents = file_in.read()
        new_content = contents.replace("<LVS_NETLIST>", NETLIST).replace("<TOP_CELL_NAME>", Design)
    with open (workarea+'/003_V2LVS/script.tcl', 'w+') as file_out:
        file_out.write(new_content)
    CMD_003 = "blaunch --cpus 1 --mem 8 --jobname v2lvs_"+ Design +" \"launch -c mgc/calibre v2lvs -tcl script.tcl\""
    KEYWORD_003 = "Verilog-to-LVS COMPLETED"
    WORK_003 = workarea + "/003_V2LVS"
    LOG_003 = WORK_003 + "/v2lvs.log"
else:
    print(NETLIST + ' LVS.V not present')
    sys.exit('Please provide a valid run_tag')

####004####

DRC_GDS = workarea + '/002_SMARTFILL_MERGE/MERGED_OUTPUT/' + Design + '_DummyMerge.gds'
DRC_GOL_VAR = load_gol_data["DRC_VAR"][0]
first_line="####Flex Flow DRC VAR####"
final_list=[]
final_list.append(first_line)
for k,v in DRC_GOL_VAR.items():
    set_var="export "+k+"="+v
    final_list.append(set_var)
final_list.append("export LAYOUT_PATH=" + DRC_GDS)
final_list.append("export RESULTS_DATABASE=" + Design + '.results')
final_list.append("export SUMMARY_REPORT=" + Design + '.summary')
final_list.append("export DENSITY_RESULTS=" + Design + '_density.results')
final_list.append("export ANTENNA_RESULTS=" + Design + '_antenna.results')
final_list.append("export HV_RESULTS=" + Design + '_hv.results')
if load_data["SELECT_RUN"][0]['004_DRC'][0]['RUN_ALL'] == 'YES':
    final_list.append("export DESIGN_TYPE=CELL")
else:
    final_list.append("export DESIGN_TYPE=CELL_FEOL_ONLY")
with open(workarea+'/004_DRC/run_drc.sh', 'w+') as f:
    for line in final_list:
        f.write(f"{line}\n")
with open ('004_run_DRC.sh', 'r') as file_in:
    contents = file_in.read()
    new_content = contents.replace("<CPU_COUNT>", CPU_COUNT).replace("<MEMORY>", MEMORY).replace("<DESIGN_NAME>", Design)
with open (workarea+'/004_DRC/run_drc.sh', 'a') as file_out:
    file_out.write(new_content)
os.chmod(workarea+'/004_DRC/run_drc.sh', 0o755)
CMD_004 = "./run_drc.sh"
KEYWORD_004 = "CALIBRE::DRC-H COMPLETED"
WORK_004 = workarea + "/004_DRC"
LOG_004 = WORK_004 + "/calibre_drc_run.log"

####005####

LVS_GDS = workarea + '/001_LAYOUT_MERGE/' + Design + '_merged.gds.gz'
LVS_CDL = workarea + '/003_V2LVS/' + Design + '.cdl'
TOP_CELL = Design
LVS_REPORT = Design + '.report'
LVS_GOL_VAR = load_gol_data["LVS_VAR"][0]
first_line="####Flex Flow LVS VAR####"
final_list=[]
final_list.append(first_line)
for k,v in LVS_GOL_VAR.items():
    set_var="export "+k+"="+v
    final_list.append(set_var)
final_list.append("export LAYOUT_PATH=" + LVS_GDS)
final_list.append("export SOURCE_PATH=" + LVS_CDL)
final_list.append("export LAYOUT_PRIMARY=" + TOP_CELL)
final_list.append("export SOURCE_PRIMARY=" + TOP_CELL)
final_list.append("export LVS_REPORT=" + LVS_REPORT)
with open(workarea+'/005_LVS/run_lvs.sh', 'w+') as f:
    for line in final_list:
        f.write(f"{line}\n")
with open ('005_run_LVS.sh', 'r') as file_in:
    contents = file_in.read()
    new_content = contents.replace("<CPU_COUNT>", CPU_COUNT).replace("<MEMORY>", MEMORY).replace("<DESIGN_NAME>", Design)
with open (workarea+'/005_LVS/run_lvs.sh', 'a') as file_out:
    file_out.write(new_content)
os.chmod(workarea+'/005_LVS/run_lvs.sh', 0o755)
CMD_005 = "./run_lvs.sh"
KEYWORD_005 = "CALIBRE::LVS COMPARISON MODULE COMPLETED"
WORK_005 = workarea + "/005_LVS"
LOG_005 = WORK_005 + "/calibre_lvs_run.log"

####006####

DFM_GDS = workarea + '/002_SMARTFILL_MERGE/MERGED_OUTPUT/' + Design + '_DummyMerge.gds'
DFM_GOL_VAR = load_gol_data["DFM_VAR"][0]
first_line="####Flex Flow DFM VAR####"
final_list=[]
final_list.append(first_line)
for k,v in DFM_GOL_VAR.items():
    set_var="export "+k+"="+v
    final_list.append(set_var)
final_list.append("export LAYOUT_PATH=" + DFM_GDS)
final_list.append("export LAYOUT_PRIMARY=" + Design)
final_list.append("export PROJECT_NAME=" + Design)
final_list.append("export OUTPUT_DIR=" + workarea + "/006_DFM")
final_list.append("export RESULTS_DATABASE=" + Design + '_DFM.db')
final_list.append("export SUMMARY_REPORT=" + Design + '_DFM.sum')
final_list.append("export RESULTS_RDB=" + Design + '_DFM.rdb')
final_list.append("export RESULTS_CRITERIA=" + Design + '_DFM_PM_CRITERIA.rdb')
final_list.append("export RESULTS_OASIS=" + Design + '_DFM.oas')
final_list.append("export DFM_SUMMARY_REPORT=" + Design + '_DFM.rpt')
with open(workarea+'/006_DFM/run_dfm.sh', 'w+') as f:
    for line in final_list:
        f.write(f"{line}\n")
with open ('006_run_DFM.sh', 'r') as file_in:
    contents = file_in.read()
    new_content = contents.replace("<CPU_COUNT>", CPU_COUNT).replace("<MEMORY>", MEMORY).replace("<DESIGN_NAME>", Design)
with open (workarea+'/006_DFM/run_dfm.sh', 'a') as file_out:
    file_out.write(new_content)
os.chmod(workarea+'/006_DFM/run_dfm.sh', 0o755)
CMD_006 = "./run_dfm.sh"
KEYWORD_006 = "CALIBRE::DRC-H COMPLETED"
WORK_006 = workarea + "/006_DFM"
LOG_006 = WORK_006 + "/calibre_dfm_run.log"

####007####

FLT_GDS = workarea + '/002_SMARTFILL_MERGE/MERGED_OUTPUT/' + Design + '_DummyMerge.gds'
FLT_GOL_VAR = load_gol_data["FLT_VAR"][0]
first_line="####Flex Flow FLT VAR####"
final_list=[]
final_list.append(first_line)
for k,v in FLT_GOL_VAR.items():
    set_var="export "+k+"="+v
    final_list.append(set_var)
final_list.append("export LAYOUT_PATH=" + FLT_GDS)
final_list.append("export LAYOUT_PRIMARY=" + Design)
final_list.append("export PROJECT_NAME=" + Design)
final_list.append("export OUTPUT_DIR=" + workarea + "/007_FLT")
final_list.append("export RDB_DIR=" + workarea + "/007_FLT")
with open(workarea+'/007_FLT/run_flt.sh', 'w+') as f:
    for line in final_list:
        f.write(f"{line}\n")
with open ('007_run_FLT.sh', 'r') as file_in:
    contents = file_in.read()
    new_content = contents.replace("<DESIGN_NAME>", Design)
with open (workarea+'/007_FLT/run_flt.sh', 'a') as file_out:
    file_out.write(new_content)
os.chmod(workarea+'/007_FLT/run_flt.sh', 0o755)
CMD_007 = "./run_flt.sh"
KEYWORD_007 = "CALIBRE::DRC-H COMPLETED"
WORK_007 = workarea + "/007_FLT"
LOG_007 = WORK_007 + "/calibre_flt_run.log"


####Running the jobs parallely and scheduling runs####

####001####

Layout_merge = tk.Frame(book)
book.add(Layout_merge, text='001 Layout Merge')
v1=Scrollbar(Layout_merge, orient='vertical')
v1.pack(side=RIGHT, fill='y')
my_text_LM = Text(Layout_merge, height=28, width=140, wrap=WORD, yscrollcommand=v1.set)
my_text_LM.pack(pady=15)
TEXT_001 = my_text_LM
CLASS_LM = executor(WORK_001, CMD_001, LOG_001, KEYWORD_001, TEXT_001)
P1 = multiprocessing.Process(target = CLASS_LM.execute)
P1.start()
def log_LM():
    while 1:
        CLASS_LM.logging()
t1 = threading.Thread(target = log_LM)
t1.start()

####002####

Smartfill_merge = tk.Frame(book)
book.add(Smartfill_merge, text='002 Smartfill Merge')
v2=Scrollbar(Smartfill_merge, orient='vertical')
v2.pack(side=RIGHT, fill='y')
my_text_SM = Text(Smartfill_merge, height=28, width=140, wrap=WORD, yscrollcommand=v2.set)
my_text_SM.pack(pady=15)
my_text_SM.tag_config('Waiting', background="yellow", foreground="red")
my_text_SM.insert(tk.END, 'Waiting for filemerge job to complete\n', 'Waiting')
TEXT_002 = my_text_SM
CLASS_SM = executor(WORK_002, CMD_002, LOG_002, KEYWORD_002, TEXT_002)
P2 = multiprocessing.Process(target = CLASS_SM.execute)
def log_SM():
    while 1:
        CLASS_SM.logging()
t2 = threading.Thread(target = log_SM)

####003####

v2lvs = tk.Frame(book)
book.add(v2lvs, text='003 V2lvs')
v3=Scrollbar(v2lvs, orient='vertical')
v3.pack(side=RIGHT, fill='y')
my_text_v2lvs = Text(v2lvs, height=28, width=140, wrap=WORD, yscrollcommand=v3.set)
my_text_v2lvs.pack(pady=15)
TEXT_003 = my_text_v2lvs
CLASS_V2LVS = executor(WORK_003, CMD_003, LOG_003, KEYWORD_003, TEXT_003)
P3 = multiprocessing.Process(target = CLASS_V2LVS.execute)
P3.start()
def log_V2LVS():
    while 1:
        CLASS_V2LVS.logging()
t3 = threading.Thread(target = log_V2LVS)
t3.start()

####004####

DRC = tk.Frame(book)
book.add(DRC, text='004 DRC Run')
v4=Scrollbar(DRC, orient='vertical')
v4.pack(side=RIGHT, fill='y')
my_text_DRC = Text(DRC, height=28, width=140, wrap=WORD, yscrollcommand=v4.set)
my_text_DRC.pack(pady=15)
my_text_DRC.tag_config('Waiting', background="yellow", foreground="red")
my_text_DRC.insert(tk.END, 'Waiting for SMARTFILL job to complete\n', 'Waiting')
TEXT_004 = my_text_DRC
CLASS_DRC = executor(WORK_004, CMD_004, LOG_004, KEYWORD_004, TEXT_004)
P4 = multiprocessing.Process(target = CLASS_DRC.execute)
def log_DRC():
    while 1:
        CLASS_DRC.logging()
t4 = threading.Thread(target = log_DRC)

####005####

LVS = tk.Frame(book)
book.add(LVS, text='005 LVS Run')
v5=Scrollbar(LVS, orient='vertical')
v5.pack(side=RIGHT, fill='y')
my_text_LVS = Text(LVS, height=28, width=140, wrap=WORD, yscrollcommand=v5.set)
my_text_LVS.pack(pady=15)
my_text_LVS.tag_config('Waiting', background="yellow", foreground="red")
my_text_LVS.insert(tk.END, 'Waiting for LAYOUT MERGE and V2LVS job to complete\n', 'Waiting')
TEXT_005 = my_text_LVS
CLASS_LVS = executor(WORK_005, CMD_005, LOG_005, KEYWORD_005, TEXT_005)
P5 = multiprocessing.Process(target = CLASS_LVS.execute)
def log_LVS():
    while 1:
        CLASS_LVS.logging()
t5 = threading.Thread(target = log_LVS)

####006####

DFM = tk.Frame(book)
book.add(DFM, text='006 DFM Run')
v6=Scrollbar(DFM, orient='vertical')
v6.pack(side=RIGHT, fill='y')
my_text_DFM = Text(DFM, height=28, width=140, wrap=WORD, yscrollcommand=v6.set)
my_text_DFM.pack(pady=15)
my_text_DFM.tag_config('Waiting', background="yellow", foreground="red")
my_text_DFM.insert(tk.END, 'Waiting for LAYOUT MERGE job to complete\n', 'Waiting')
TEXT_006 = my_text_DFM
CLASS_DFM = executor(WORK_006, CMD_006, LOG_006, KEYWORD_006, TEXT_006)
P6 = multiprocessing.Process(target = CLASS_DFM.execute)
def log_DFM():
    while 1:
        CLASS_DFM.logging()
t6 = threading.Thread(target = log_DFM)

####007####

FLT = tk.Frame(book)
book.add(FLT, text='007 FLT Run')
v7=Scrollbar(FLT, orient='vertical')
v7.pack(side=RIGHT, fill='y')
my_text_FLT = Text(FLT, height=28, width=140, wrap=WORD, yscrollcommand=v7.set)
my_text_FLT.pack(pady=15)
my_text_FLT.tag_config('Waiting', background="yellow", foreground="red")
my_text_FLT.insert(tk.END, 'Waiting for LAYOUT MERGE job to complete\n', 'Waiting')
TEXT_007 = my_text_FLT
CLASS_FLT = executor(WORK_007, CMD_007, LOG_007, KEYWORD_007, TEXT_007)
P7 = multiprocessing.Process(target = CLASS_FLT.execute)
def log_FLT():
    while 1:
        CLASS_FLT.logging()
t7 = threading.Thread(target = log_FLT)

####Starting runs sequentially####

def Sequence():
    while (job_done == 0) or (job_done == 1):
        time.sleep(10)
    P2.start()
    t2.start()
    P5.start()
    t5.start()
    print("Job_done" + str(job_done))
    while (job_done == 2) or (job_done == 3):
        time.sleep(10)
    my_text_DRC.insert(tk.END, 'Waiting for SMARTFILL merge job to complete\n', 'Waiting')
    my_text_DFM.insert(tk.END, 'Waiting for SMARTFILL merge job to complete\n', 'Waiting')
    my_text_FLT.insert(tk.END, 'Waiting for SMARTFILL merge job to complete\n', 'Waiting')
    while not (os.path.exists(WORK_002 + "/MERGED_OUTPUT/" + Design + "_DummyMerge.gds")):
        time.sleep(10)
    P4.start()
    t4.start()
    P6.start()
    t6.start()
    while (job_done == 4) or (job_done == 5):
        time.sleep(10)
    P7.start()
    t7.start()
    while job_done == 6:
        time.sleep(10)
    if job_done == 7:
        sys.exit('All runs completed')

t8 = threading.Thread(target = Sequence)
t8.start()


root.mainloop()
