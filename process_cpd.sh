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


justify() {
    # $1=val $2=width $3=pad $4=output_var
    local val="$1"
    local len="$2"
    local pad="${3:- }"
    local outvar="$4"
    # Truncate to at most $len
    if (( ${#val} > len )); then
        val="${val:0:len}"
    fi
    # Pad (right-justified/left-padded)
    printf -v __just_out "%${len}s" "$val"
    # If pad char is not space, replace
    [[ "$pad" != " " ]] && __just_out="${__just_out// /$pad}"
    # Return by reference
    printf -v "$outvar" "%s" "$__just_out"
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
    IFS='|' read -r a gl_account cost_center b c d first_name last_name e f g h i j k l row_date amount m n o p q memo_num r s t doc_num u v w x y z aa ab ac claim_type ad ae af <<< "$line"
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

    justify "$cost_center_fixed" $LEN_OPERATING_UNIT '0' result
    fixed_width_string+=$result
    justify '54590' $LEN_OPERATING_UNIT '0' result
    offset_string+=$result

    # division
    justify '400' $LEN_DIVISION ' ' result
    fixed_width_string+=$result
    justify '530' $LEN_DIVISION ' ' result
    offset_string+=$result

    # Account
    justify "$gl_account" $LEN_ACCOUNT ' ' result
    fixed_width_string+=$result
    justify '21167' $LEN_ACCOUNT ' ' result
    offset_string+=$result

    # Source
    justify 'CPD' $LEN_SOURCE ' ' result
    fixed_width_string+=$result
    justify 'CPD' $LEN_SOURCE ' ' result
    offset_string+=$result

    # Category
    justify '' $LEN_CATEGORY ' ' result
    fixed_width_string+=$result
    justify '' $LEN_CATEGORY ' ' result
    offset_string+=$result

    # YEAR
    justify '' $LEN_YEAR ' ' result
    fixed_width_string+=$result
    justify '' $LEN_YEAR ' ' result
    offset_string+=$result

    # WEEK
    justify '' $LEN_WEEK ' ' result
    fixed_width_string+=$result
    justify '' $LEN_WEEK ' ' result
    offset_string+=$result

    # Cost
    justify "$amount" $LEN_COST ' ' result
    fixed_width_string+=$result

    # Offset: invert sign
    if [[ "$amount" == -* ]]; then
        # negative, strip the minus sign
        offset_amount="${amount#-}"
    else
        # positive, prepend minus sign
        offset_amount="-$amount"
    fi

    justify "$offset_amount" $LEN_COST ' ' result
    offset_string+=$result

    # CURRENCY_CODE
    justify '' $LEN_CURRENCY_CODE ' ' result
    fixed_width_string+=$result
    justify '' $LEN_CURRENCY_CODE ' ' result
    offset_string+=$result

    # SELLING_VALUE
    justify '' $LEN_SELLING_VALUE ' ' result
    fixed_width_string+=$result
    justify '' $LEN_SELLING_VALUE ' ' result
    offset_string+=$result

    # STATISTICAL_AMOUNT
    justify '' $LEN_STATISTICAL_AMOUNT ' ' result
    fixed_width_string+=$result
    justify '' $LEN_STATISTICAL_AMOUNT ' ' result
    offset_string+=$result

    # STATISTICAL_CODE
    justify '' $LEN_STATISTICAL_CODE ' ' result
    fixed_width_string+=$result
    justify '' $LEN_STATISTICAL_CODE ' ' result
    offset_string+=$result

    # REVERSAL_FLAG
    justify 'N' $LEN_REVERSAL_FLAG ' ' result
    fixed_width_string+=$result
    justify 'N' $LEN_REVERSAL_FLAG ' ' result
    offset_string+=$result

    # REVERSAL_YEAR
    justify '' $LEN_REVERSAL_YEAR ' ' result
    fixed_width_string+=$result
    justify '' $LEN_REVERSAL_YEAR ' ' result
    offset_string+=$result

    # REVERSAL_WEEK
    justify '' $LEN_REVERSAL_WEEK ' ' result
    fixed_width_string+=$result
    justify '' $LEN_REVERSAL_WEEK ' ' result
    offset_string+=$result

    # BACKTRAFFIC_FLAG
    justify '' $LEN_BACKTRAFFIC_FLAG ' ' result
    fixed_width_string+=$result
    justify '' $LEN_BACKTRAFFIC_FLAG ' ' result
    offset_string+=$result

    # SYSTEM_SWITCH
    justify '' $LEN_SYSTEM_SWITCH ' ' result
    fixed_width_string+=$result
    justify '' $LEN_SYSTEM_SWITCH ' ' result
    offset_string+=$result

    # memo
    justify "$memo_num" $LEN_DESCRIPTION ' ' result
    fixed_width_string+=$result
    justify "$memo_num" $LEN_DESCRIPTION ' ' result
    offset_string+=$result

    # ENTRY_TYPE
    justify '' $LEN_ENTRY_TYPE ' ' result
    fixed_width_string+=$result
    justify '' $LEN_ENTRY_TYPE ' ' result
    offset_string+=$result

    # RECORD_TYPE
    justify '' $LEN_RECORD_TYPE ' ' result
    fixed_width_string+=$result
    justify '' $LEN_RECORD_TYPE ' ' result
    offset_string+=$result

    # REF_NBR_1
    justify '' $LEN_REF_NBR_1 ' ' result
    fixed_width_string+=$result
    justify '' $LEN_REF_NBR_1 ' ' result
    offset_string+=$result

    # doc number. 
    clean_doc_num="${doc_num//-/}"
    clean_doc_num="${clean_doc_num:-}"
    ref_value="${clean_doc_num: -12}"
    if [[ "$ref_value" == "000000000000" || "$ref_value" == "0" || -z "$ref_value" ]]; then
        ref_value=" "
    fi
    
    justify "$ref_value" $LEN_DOC_NBR ' ' result
    fixed_width_string+=$result
    justify "$ref_value" $LEN_DOC_NBR ' ' result
    offset_string+=$result

    # REF_NBR_2
    justify '' $LEN_REF_NBR_2 ' ' result
    fixed_width_string+=$result
    justify '' $LEN_REF_NBR_2 ' ' result
    offset_string+=$result

    # first name
    justify "$first_name" $LEN_MISC_1 ' ' result
    fixed_width_string+=$result
    justify "$first_name" $LEN_MISC_1 ' ' result
    offset_string+=$result

    # last name
    justify "$last_name" $LEN_MISC_2 ' ' result
    fixed_width_string+=$result
    justify "$last_name" $LEN_MISC_2 ' ' result
    offset_string+=$result

    # claim type
    justify "$claim_type" $LEN_MISC_3 ' ' result
    fixed_width_string+=$result
    justify "$claim_type" $LEN_MISC_3 ' ' result
    offset_string+=$result

    # TO_FROM
    justify '' $LEN_TO_FROM ' ' result
    fixed_width_string+=$result
    justify '' $LEN_TO_FROM ' ' result
    offset_string+=$result

    # DOC DATE
    justify "$year$month$day" $LEN_DOC_DATE ' ' result
    fixed_width_string+=$result
    justify "$year$month$day" $LEN_DOC_DATE ' ' result
    offset_string+=$result

    # EXP_CODE
    justify '' $LEN_EXP_CODE ' ' result
    fixed_width_string+=$result
    justify '' $LEN_EXP_CODE ' ' result
    offset_string+=$result

    # EMP_NBR
    justify '' $LEN_EMP_NBR ' ' result
    fixed_width_string+=$result
    justify '' $LEN_EMP_NBR ' ' result
    offset_string+=$result

    # DET_TRAN_DATE
    justify "$row_date" $LEN_DET_TRAN_DATE ' ' result
    fixed_width_string+=$result
    justify "$row_date" $LEN_DET_TRAN_DATE ' ' result
    offset_string+=$result

    # ORIG_ENTRY
    justify '' $LEN_ORIG_ENTRY ' ' result
    fixed_width_string+=$result
    justify '' $LEN_ORIG_ENTRY ' ' result
    offset_string+=$result

    # REP_FLG
    justify '' $LEN_REP_FLG ' ' result
    fixed_width_string+=$result
    justify '' $LEN_REP_FLG ' ' result
    offset_string+=$result

    # ORU
    justify '' $LEN_ORU ' ' result
    fixed_width_string+=$result
    justify '' $LEN_ORU ' ' result
    offset_string+=$result

    # GL_TRXN_DATE
    trxn_month=${row_date:0:2}
    trxn_day=${row_date:2:2}
    trxn_year=${row_date:4:2}

    # Convert 2-digit year to 4-digit (assumes 2000) ... bugs imminent in 75 years. 
    trxn_year="20$trxn_year"

    gl_trxn_date="${trxn_year}${trxn_month}${trxn_day}"

    justify "$gl_trxn_date" $LEN_GL_TRXN_DATE ' ' result
    fixed_width_string+=$result
    justify "$gl_trxn_date" $LEN_GL_TRXN_DATE ' ' result
    offset_string+=$result

    # FILLER
    justify '' $LEN_FILLER ' ' result
    fixed_width_string+=$result
    justify '' $LEN_FILLER ' ' result
    offset_string+=$result

    {
        echo "$fixed_width_string"
        echo "$offset_string"
    } >> "$local_output_file"
done < "$local_copy"

network_destination="${prod_path%/}/${output_filename}"
echo $network_destination
echo "quitting!"
exit 1

# if mv "$local_output_file" "$network_destination"; then
#   echo "File successfully moved."
# else
#   echo "Error moving file."
#   echo "File saved locally under file name:"
#   echo $local_output_file
#   echo "Please move file to prod destination:"
#   echo $prod_path
#   exit 1
# fi
