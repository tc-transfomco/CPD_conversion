from datetime import date, timedelta
from os import listdir, path

class NetworkDriveHandler():
    INP_FILE_SUFFIX = ".txt"
    def __init__(self):
        self.w_drive = '//uskihfil5.kih.kmart.com/workgrp/Finance/AccountsPayable/CHECK_ISSUES/'
        # windows verison of file path 
        #              '\\uskihfil5.kih.kmart.com\workgrp\Finance\AccountsPayable\CHECK_ISSUES\'
        self.inp_file_prefix = "MANUALCHECKS_PREISSUE_"

    def get_file_name_by_day(self, in_day=date.today()):
        year = in_day.year
        month = str(in_day.month).zfill(2)
        day = str(in_day.day).zfill(2)

        return f"{self.inp_file_prefix}{year}{month}{day}"
    
    def get_in_input_files(self, days_ago_list=[0]):
        in_files = []
        for days_ago in days_ago_list:
            today = date.today()
            day_wanted = today - timedelta(days=days_ago)
            in_files.append(self.get_file_name_by_day(day_wanted))
        wanted_files = []
        for in_file in in_files:
            existing_files = [entry for entry in listdir(self.w_drive) if entry.lower().startswith(in_file.lower()) and entry.lower().endswith(self.INP_FILE_SUFFIX.lower())]
            # print(existing_file)
            if len(existing_files) == 0:
                print(f"Could not find file: {in_file}{self.INP_FILE_SUFFIX} in the following location:\n{self.w_drive}")
                continue
            if len(existing_files) > 1:
                raise Exception("Uh oh, too many files.")
            
            matching_file = existing_files[0]

            wanted_files.append(path.join(self.w_drive, matching_file))
        return wanted_files
