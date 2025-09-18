import os
from datetime import date, datetime
import argparse
from pathlib import Path
from network_drive_handler import NetworkDriveHandler

SANDBOX_DESTINATION = "//SHSNGSTFSX/shs_boomi_vol/Test/GL_Files/300-byte"
PROD_PATH = '//SHSNGPRFSX/shs_boomi_vol/GL_Files/300-byte'
# PROD_PATH = '\\SHSNGPRFSX\shs_boomi_vol\GL_Files\300-byte'
NAMING_CONVENTION_PREFIX = "PG.GFEK100.TEXTIPTF_CPD_"

# DELIMITER = ','
# DELIMITER = '\t'
DELIMITER = '|'

LEN_OPERATING_UNIT = 5
LEN_DIVISION = 4
LEN_ACCOUNT = 5
LEN_SOURCE = 3
LEN_CATEGORY = 4
LEN_YEAR = 4
LEN_WEEK = 2
LEN_COST = 17
LEN_CURRENCY_CODE = 3
LEN_SELLING_VALUE = 17
LEN_STATISTICAL_AMOUNT = 17
LEN_STATISTICAL_CODE = 3
LEN_REVERSAL_FLAG = 1
LEN_REVERSAL_YEAR = 4
LEN_REVERSAL_WEEK = 2
LEN_BACKTRAFFIC_FLAG = 1
LEN_SYSTEM_SWITCH = 2
LEN_DESCRIPTION = 30
LEN_ENTRY_TYPE = 3
LEN_RECORD_TYPE = 2
LEN_REF_NBR_1 = 10
LEN_DOC_NBR = 15
LEN_REF_NBR_2 = 10
LEN_MISC_1 = 20
LEN_MISC_2 = 20
LEN_MISC_3 = 20
LEN_TO_FROM = 6
LEN_DOC_DATE = 8
LEN_EXP_CODE = 3
LEN_EMP_NBR = 7
LEN_DET_TRAN_DATE = 6
LEN_ORIG_ENTRY = 15
LEN_REP_FLG = 1
LEN_ORU = 6
LEN_GL_TRXN_DATE = 8
LEN_FILLER = 16

#   Tuple description: (
#                          1. The length in the 300 byte file,
#                          2. If it exists in the input file (and should be mapped)
#                          3. if True:
#                               The name of the header in the input file where the value is. 
#                             if False:
#                               The default value (can be empty) 
#                      )
IN_ORDER_300_BYTE_FIELDS = [
    (LEN_OPERATING_UNIT, False, "Cost Center"),     # Actually IS in input file
    (LEN_DIVISION, False, "DIVISION"), 
    (LEN_ACCOUNT, True, "GL Account"), 
    (LEN_SOURCE, False, "CPD"), 
    (LEN_CATEGORY, False, " "), 
    (LEN_YEAR, False, " "), 
    (LEN_WEEK, False, " "), 
    (LEN_COST, True, "Amount"), 
    (LEN_CURRENCY_CODE, False, " "), 
    (LEN_SELLING_VALUE, False, " "), 
    (LEN_STATISTICAL_AMOUNT, False, " "), 
    (LEN_STATISTICAL_CODE, False, " "), 
    (LEN_REVERSAL_FLAG, False, "N"),                # Should these be Y for the offset? 
    (LEN_REVERSAL_YEAR, False, " "), 
    (LEN_REVERSAL_WEEK, False, " "), 
    (LEN_BACKTRAFFIC_FLAG, False, " "), 
    (LEN_SYSTEM_SWITCH, False, " "), 
    (LEN_DESCRIPTION, True, "Memo/Claim Number"), 
    (LEN_ENTRY_TYPE, False, " "), 
    (LEN_RECORD_TYPE, False, " "), 
    (LEN_REF_NBR_1, False, " "), 
    (LEN_DOC_NBR, False, "Reference"),              # Actually IS in input file
    (LEN_REF_NBR_2, False, " "), 
    (LEN_MISC_1, True, "First Name"), 
    (LEN_MISC_2, True, "Last Name"), 
    (LEN_MISC_3, True, "Claim Type"), 
    (LEN_TO_FROM, False, " "), 
    (LEN_DOC_DATE, False, "FILE NAME"), 
    (LEN_EXP_CODE, False, " "), 
    (LEN_EMP_NBR, False, " "), 
    (LEN_DET_TRAN_DATE, True, "Date"), 
    (LEN_ORIG_ENTRY, False, " "), 
    (LEN_REP_FLG, False, " "), 
    (LEN_ORU, False, " "), 
    (LEN_GL_TRXN_DATE, False, "DateDIFF"), 
    (LEN_FILLER, False, " "), 
]

def parse_file_into_dictionaries(input_file):
    parsed_dicts = []
    with open(input_file, 'r') as f:
        lines = f.readlines()
    if len(lines) == 0:
        return []
    header_line = lines[0].strip()
    lines = lines[1:]
    headers = []
    for header in header_line.split(DELIMITER):
        if len(header) != 0:
            headers.append(header)
    if len(headers) <= 2:
        raise Exception(f"Delimeter ({DELIMITER}) is likely wrong!\n{header_line}")
    # print(len(headers))
    do_raise = False

    for i, line in enumerate(lines):
        line = line.strip()
        if line == '':
            continue
        values = line.split(DELIMITER)
        parsed_dict = {}
        if len(values) != len(headers):
            print(input_file)
            print(f"ON line {i + 2} there is a mismatch between the amount of headers ({len(headers)}) and values found ({len(values)})")
            values = values[:len(headers)]
            do_raise = True

        for header, value in zip(headers, values):
            parsed_dict[header] = value
        parsed_dicts.append(parsed_dict)

    if do_raise:
        try:
            with open(os.path.basename(input_file), "w+") as broken_file:
                broken_file.write(header_line + "\n")
                for line in lines:
                    broken_file.write(line)
        except Exception as e:
            raise Exception("Can not process input file due to header and value mismatch.")
    return parsed_dicts


def map_in_dicts_to_300_byte_format(dicts, file_name: str):
    mapped = ""
    file_date = str(file_name).lower().replace(NetworkDriveHandler.INP_FILE_SUFFIX, "")[-8:]
    for dict in dicts:
        mapped += convert_dict_to_300_byte(dict, file_date)
    return mapped

# "7084" it converts it to "3132" 
# "7323" it converts it to "3580"?
def convert_dict_to_300_byte(in_dict, file_date):
    current_map = ""
    for field_len, is_in_dict, value in IN_ORDER_300_BYTE_FIELDS:
        if value == "Cost Center":
            value = in_dict[value]
            check_value = int(value)
            if check_value == 7084:
                value = "3132"
            if check_value == 7323:
                value = "3580"
            value = justify(value, field_len, '0')
        if value == "DIVISION":
            value = "400"
        if value == "Reference":
            value = in_dict[value].replace("-", "")[-12:]
            if value == "000000000000":
                value = " "
        if value == "FILE NAME":
            value = file_date
        if value == "DateDIFF":
            dict_date = in_dict["Date"]
            dict_date = datetime.strptime(str(dict_date), '%m%d%y')
            value = _get_gl_trxn_date(dict_date)
        if is_in_dict:
            value = in_dict[value]
        current_map += justify(value, field_len)
    
    offset = ""
    for field_len, is_in_dict, value in IN_ORDER_300_BYTE_FIELDS:
        ignore_dict_value = False
        if value == "Cost Center":
            value = "54590"
        if value == "DIVISION":
            value = "530"
        if value == "GL Account":
            ignore_dict_value = True
            value = "21167"
        if value == "Amount":
            ignore_dict_value = True
            dict_val = str(in_dict[value])
            if dict_val[0] == "-":
                value = dict_val[1:]
            else:
                value = "-" + dict_val
        if value == "Reference":
            value = in_dict[value].replace("-", "")[-12:]
            if value == "000000000000":
                value = " "
        if value == "FILE NAME":
            value = file_date
        if value == "DateDIFF":
            dict_date = in_dict["Date"]
            dict_date = datetime.strptime(str(dict_date), '%m%d%y')
            value = _get_gl_trxn_date(dict_date)
        if is_in_dict and not ignore_dict_value:
            value = in_dict[value]
        offset += justify(value, field_len)


    return f"{current_map}\n{offset}\n"


def justify(input, amount, fillchar=' '):
    return str(input)[:amount].rjust(amount, fillchar)


def _get_gl_trxn_date(the_date):
    month = str(the_date.month).zfill(2)
    day = str(the_date.day).zfill(2)
    year = int(the_date.year)
    return f"{year}{month}{day}"


def get_formatted_out_file_name():
    today = date.today()
    year = today.year
    month = str(today.month).zfill(2)
    day = str(today.day).zfill(2)

    right_now = datetime.now()
    hour = str(right_now.hour).zfill(2)
    minute = str(right_now.minute).zfill(2)
    second = str(right_now.second).zfill(2)

    return f"{year}{month}{day}_{hour}{minute}{second}.txt"


def process_file(input_file):
    dicts = parse_file_into_dictionaries(input_file)
    # dicts = parse_file_into_dictionaries(input_file)

    mapped_str = map_in_dicts_to_300_byte_format(dicts, input_file)
    if len(mapped_str) == 0:
        return
    
    file_name = get_formatted_out_file_name()
    print(f'{PROD_PATH}/{NAMING_CONVENTION_PREFIX}{file_name}')

    with open(f'{NAMING_CONVENTION_PREFIX}{file_name}', 'w+') as file:
        file.write(mapped_str)

    try:
        raise Exception("fart")
        with open(f'{PROD_PATH}/{NAMING_CONVENTION_PREFIX}{file_name}', 'w') as file:
            file.write(mapped_str)
    except Exception as e:
        raise Exception(f"You ran into an exception: {e}\n\nPlease take the file that was saved: "\
                        f"({NAMING_CONVENTION_PREFIX}{file_name}) and make sure that it is saved at {PROD_PATH}")

def main(days_ago=[0]):
    ndh = NetworkDriveHandler()
    input_files = ndh.get_in_input_files(days_ago_list=days_ago)

    for input_file in input_files:
       process_file(input_file=input_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Locate a daily data file based on age in days or absolute path.\n"
            "By default, it looks for today's file (0 days ago).\n"
            "If multiple files are found for the given day, you must pass the absolute path instead."
        ),
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument(
        "days_ago",
        nargs="?",
        type=int,
        default=0,
        help="How many days ago the file was created (0 = today). Default is 0."
    )


    parser.add_argument(
        "--file",
        type=str,
        default=None,
        help="Absolute path to the file to process (used when multiple files exist for the date)"
    )

    args = parser.parse_args()

    if args.file:
        file_path = Path(args.file)
        process_file(input_file=file_path)
        exit(0)
    
    main([args.days_ago])
