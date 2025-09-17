#!/bin/bash


DELIMITER='|'

LEN_OPERATING_UNIT=5
LEN_DIVISION=4
LEN_ACCOUNT=5
LEN_SOURCE=3
LEN_CATEGORY=4
LEN_YEAR=4
LEN_WEEK=2
LEN_COST=17
LEN_CURRENCY_CODE=3
LEN_SELLING_VALUE=17
LEN_STATISTICAL_AMOUNT=17
LEN_STATISTICAL_CODE=3
LEN_REVERSAL_FLAG=1
LEN_REVERSAL_YEAR=4
LEN_REVERSAL_WEEK=2
LEN_BACKTRAFFIC_FLAG=1
LEN_SYSTEM_SWITCH=2
LEN_DESCRIPTION=30
LEN_ENTRY_TYPE=3
LEN_RECORD_TYPE=2
LEN_REF_NBR_1=10
LEN_DOC_NBR=15
LEN_REF_NBR_2=10
LEN_MISC_1=20
LEN_MISC_2=20
LEN_MISC_3=20
LEN_TO_FROM=6
LEN_DOC_DATE=8
LEN_EXP_CODE=3
LEN_EMP_NBR=7
LEN_DET_TRAN_DATE=6
LEN_ORIG_ENTRY=15
LEN_REP_FLG=1
LEN_ORU=6
LEN_GL_TRXN_DATE=8
LEN_FILLER=16

# Source the config file
source config.sh

right_justify() {
    local val="$1"
    local len="$2"
    local pad="${3:- }"

    # Truncate the string to the specified length if it exceeds the length
    if [ ${#val} -gt $len ]; then
        val="${val:0:$len}"
    fi
    printf "%-${len}s" "$val" | tr ' ' "$pad"
}

justify() {
    local val="$1"
    local len="$2"
    local pad="${3:- }"
    # Truncate the string to the specified length if it exceeds the length
    if [ ${#val} -gt $len ]; then
        val="${val:0:$len}"
    fi
    printf "%${len}s" "$val" | tr ' ' "$pad"
}

# Get today's date components
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)

# Build the filename
filepath="${w_drive%/}/${inp_file_prefix}${year}${month}${day}.txt"

# Check if file exists
if [[ ! -f "$filepath" ]]; then
    echo "File not found: $filepath"
    exit 1
fi
local_copy="./${inp_file_prefix}${year}${month}${day}.txt"
echo "Processing file: $filepath"
cp "$filepath" "$local_copy"

timestamp=$(date +%Y%m%d_%H%M%S)
output_filename="${naming_convention_prefix}${timestamp}.txt"

local_output_file="./${output_filename}"

header=true
# ID|GL Account|Cost Center|Bundle ID|Type|Check #|First Name|Last Name|Payee Address|Address 1|Address 2|City|State|Zip|Country|Status|Date|Amount|Fees|Check Type|Postage ID|Postage Code|Postage|Memo/Claim Number|Flagged|Needs Repaired|Approved|Reference|Date on Check|Mail To Name|Recip Instruction|Tax ID|Client Trans. ID|Funding Source|Insert|Tracking|Email ID|Claim Type|Plan Type|Service Provider Name|Generic 5
# Read and parse each line
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip header
    if $header; then
        header=false
        continue
    fi
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Parse line by pipe
    IFS='|' read -r a gl_account cost_center b c d first_name last_name e f g h i j k l row_date amount m n o p q memo_num  r s t doc_num u  v w x y  z aa  ab ac claim_type ad  ae af  <<< "$line"
    echo $a                                                                             
    fixed_width_string=""
    offset_string=""

    # operating unit
    if [[ "$cost_center" == "7084" ]]; then
        cost_center_fixed="3132"
    elif [[ "$cost_center" == "7323" ]]; then
        cost_center_fixed="3580"
    else
        cost_center_fixed="$cost_center"
    fi

    fixed_width_string+="$(justify "$cost_center_fixed" $LEN_OPERATING_UNIT '0')"
    offset_string+="$(justify '54590' $LEN_OPERATING_UNIT '0')"

    # division
    fixed_width_string+="$(justify '400' $LEN_DIVISION ' ')"
    offset_string+="$(justify '530' $LEN_DIVISION ' ')"

    # Account
    fixed_width_string+="$(justify "$gl_account" $LEN_ACCOUNT ' ')"
    offset_string+="$(justify '21167' $LEN_ACCOUNT ' ')"

    # Source
    fixed_width_string+="$(justify 'CPD' $LEN_SOURCE ' ')"
    offset_string+="$(justify 'CPD' $LEN_SOURCE ' ')"

    # Category
    fixed_width_string+="$(justify '' $LEN_CATEGORY ' ')"
    offset_string+="$(justify '' $LEN_CATEGORY ' ')"

    # YEAR
    fixed_width_string+="$(justify '' $LEN_YEAR ' ')"
    offset_string+="$(justify '' $LEN_YEAR ' ')"

    # WEEK
    fixed_width_string+="$(justify '' $LEN_WEEK ' ')"
    offset_string+="$(justify '' $LEN_WEEK ' ')"

    # Cost
    fixed_width_string+="$(justify "$amount" $LEN_COST ' ')"

    # Offset: invert sign
    if [[ "$amount" == -* ]]; then
        # negative, strip the minus sign
        offset_amount="${amount#-}"
    else
        # positive, prepend minus sign
        offset_amount="-$amount"
    fi

    offset_string+="$(justify "$offset_amount" $LEN_COST ' ')" 

    # CURRENCY_CODE
    fixed_width_string+="$(justify '' $LEN_CURRENCY_CODE ' ')"
    offset_string+="$(justify '' $LEN_CURRENCY_CODE ' ')"

    # SELLING_VALUE
    fixed_width_string+="$(justify '' $LEN_SELLING_VALUE ' ')"
    offset_string+="$(justify '' $LEN_SELLING_VALUE ' ')"

    # STATISTICAL_AMOUNT
    fixed_width_string+="$(justify '' $LEN_STATISTICAL_AMOUNT ' ')"
    offset_string+="$(justify '' $LEN_STATISTICAL_AMOUNT ' ')"

    # STATISTICAL_CODE
    fixed_width_string+="$(justify '' $LEN_STATISTICAL_CODE ' ')"
    offset_string+="$(justify '' $LEN_STATISTICAL_CODE ' ')"

    # REVERSAL_FLAG
    fixed_width_string+="$(justify 'N' $LEN_REVERSAL_FLAG ' ')"
    offset_string+="$(justify 'N' $LEN_REVERSAL_FLAG ' ')"

    # REVERSAL_YEAR
    fixed_width_string+="$(justify '' $LEN_REVERSAL_YEAR ' ')"
    offset_string+="$(justify '' $LEN_REVERSAL_YEAR ' ')"

    # REVERSAL_WEEK
    fixed_width_string+="$(justify '' $LEN_REVERSAL_WEEK ' ')"
    offset_string+="$(justify '' $LEN_REVERSAL_WEEK ' ')"

    # BACKTRAFFIC_FLAG
    fixed_width_string+="$(justify '' $LEN_BACKTRAFFIC_FLAG ' ')"
    offset_string+="$(justify '' $LEN_BACKTRAFFIC_FLAG ' ')"

    # SYSTEM_SWITCH
    fixed_width_string+="$(justify '' $LEN_SYSTEM_SWITCH ' ')"
    offset_string+="$(justify '' $LEN_SYSTEM_SWITCH ' ')"

    # memo
    fixed_width_string+="$(justify "$memo_num" $LEN_DESCRIPTION ' ')"
    offset_string+="$(justify "$memo_num" $LEN_DESCRIPTION ' ')"

    # ENTRY_TYPE
    fixed_width_string+="$(justify '' $LEN_ENTRY_TYPE ' ')"
    offset_string+="$(justify '' $LEN_ENTRY_TYPE ' ')"

    # RECORD_TYPE
    fixed_width_string+="$(justify '' $LEN_RECORD_TYPE ' ')"
    offset_string+="$(justify '' $LEN_RECORD_TYPE ' ')"

    # REF_NBR_1
    fixed_width_string+="$(justify '' $LEN_REF_NBR_1 ' ')"
    offset_string+="$(justify '' $LEN_REF_NBR_1 ' ')"

    # doc number. 
    clean_doc_num="${doc_num//-/}"
    clean_doc_num="${clean_doc_num:-}"
    ref_value="${clean_doc_num: -12}"
    if [[ "$ref_value" == "000000000000" || "$ref_value" == "0" || -z "$ref_value" ]]; then
        ref_value=" "
    fi
    
    fixed_width_string+="$(justify "$ref_value" $LEN_DOC_NBR ' ')"
    offset_string+="$(justify "$ref_value" $LEN_DOC_NBR ' ')"

    # REF_NBR_2
    fixed_width_string+="$(justify '' $LEN_REF_NBR_2 ' ')"
    offset_string+="$(justify '' $LEN_REF_NBR_2 ' ')"

    # first name
    fixed_width_string+="$(justify "$first_name" $LEN_MISC_1 ' ')"
    offset_string+="$(justify "$first_name" $LEN_MISC_1 ' ')"

    # last name
    fixed_width_string+="$(justify "$last_name" $LEN_MISC_2 ' ')"
    offset_string+="$(justify "$last_name" $LEN_MISC_2 ' ')"

    # claim type
    fixed_width_string+="$(justify "$claim_type" $LEN_MISC_3 ' ')"
    offset_string+="$(justify "$claim_type" $LEN_MISC_3 ' ')"

    # TO_FROM
    fixed_width_string+="$(justify '' $LEN_TO_FROM ' ')"
    offset_string+="$(justify '' $LEN_TO_FROM ' ')"

    # DOC DATE
    fixed_width_string+="$(justify "$year$month$day" $LEN_DOC_DATE ' ')"
    offset_string+="$(justify "$year$month$day" $LEN_DOC_DATE ' ')"

    # EXP_CODE
    fixed_width_string+="$(justify '' $LEN_EXP_CODE ' ')"
    offset_string+="$(justify '' $LEN_EXP_CODE ' ')"

    # EMP_NBR
    fixed_width_string+="$(justify '' $LEN_EMP_NBR ' ')"
    offset_string+="$(justify '' $LEN_EMP_NBR ' ')"

    # DET_TRAN_DATE
    fixed_width_string+="$(justify "$row_date" $LEN_DET_TRAN_DATE ' ')"
    offset_string+="$(justify "$row_date" $LEN_DET_TRAN_DATE ' ')"

    # ORIG_ENTRY
    fixed_width_string+="$(justify '' $LEN_ORIG_ENTRY ' ')"
    offset_string+="$(justify '' $LEN_ORIG_ENTRY ' ')"

    # REP_FLG
    fixed_width_string+="$(justify '' $LEN_REP_FLG ' ')"
    offset_string+="$(justify '' $LEN_REP_FLG ' ')"

    # ORU
    fixed_width_string+="$(justify '' $LEN_ORU ' ')"
    offset_string+="$(justify '' $LEN_ORU ' ')"

    # GL_TRXN_DATE
    trxn_month=${row_date:0:2}
    trxn_day=${row_date:2:2}
    trxn_year=${row_date:4:2}

    # Convert 2-digit year to 4-digit (assumes 2000) ... bugs imminent in 75 years. dear god let this code be dead by then
    trxn_year="20$trxn_year"

    gl_trxn_date="${trxn_year}${trxn_month}${trxn_day}"

    fixed_width_string+="$(justify "$gl_trxn_date" $LEN_GL_TRXN_DATE ' ')"
    offset_string+="$(justify "$gl_trxn_date" $LEN_GL_TRXN_DATE ' ')"

    # FILLER
    fixed_width_string+="$(justify '' $LEN_FILLER ' ')"
    offset_string+="$(justify '' $LEN_FILLER ' ')"

    {
        echo "$fixed_width_string"
        echo "$offset_string"
    } >> "$local_output_file"
done < "$local_copy"

network_destination="${prod_path%/}/${output_filename}"
echo "quitting!"
exit 1
if mv "$local_output_file" "$network_destination"; then
  echo "File successfully moved."
else
  echo "Error moving file."
  echo "File saved locally under file name:"
  echo $local_output_file
  echo "Please move file to prod destination:"
  echo $prod_path
  exit 1
fi
