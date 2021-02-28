#! /bin/bash 

# Parameters expected: 
DURATION=$1									# Single experiment duration
MACHINE=$2									# Machine name (nodes, quads...)

EXP_TYPE=('tas' 'spin' 'ttas' 'mcs' 'atomic' 'mutex' 'ticket')
#ITERATIONS='_iterations'
ITERATIONS=''

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters: duration machine_name [output_filename]"
    exit 
fi

if [ "$MACHINE" = "nodes" ]; then
	CLIENT_NR=(4 8 16 32 64 128)
	echo "using: ${CLIENT_NR[@]} threads"
elif [ "$MACHINE" = "quads" ]; then
	CLIENT_NR=(4 8 16 32 56 112)
	echo "using: ${CLIENT_NR[@]} threads"
else 
	echo 'wrong machine name'
	exit
fi


BASE_PATH="./"
PROFILE=false

if [ ! -d "${BASE_PATH}Data/" ]; then
	mkdir "${BASE_PATH}Data/"
fi

# Create experiment labels file
./${EXP_TYPE} -t ${CLIENT_NR} -d 1000 -c 10 | awk '{print $1}' | sort > "${BASE_PATH}experiment_ev"

# Load events list in a string
readarray -t EXPERIMENT_EV < "${BASE_PATH}experiment_ev"
#readarray -t EVENTS < "${BASE_PATH}stall_counters"

IFS=\, eval 'LST="${EVENTS[*]}"'
LST="$(echo -e "${LST}" | tr -d '[:space:]')"

IFS=\, eval 'LST_EXP="${EXPERIMENT_EV[*]}"'
LST_EXP="$(echo -e "${LST_EXP}" | tr -d '[:space:]')"


# Set the header of the .csv output file
for exp in ${EXP_TYPE[@]}; do
	if [ "$PROFILE" = true ]; then 
		echo "$LST_EXP,$LST," > "${BASE_PATH}Data/results${ITERATIONS}_${exp}_${MACHINE}.csv"		
	else
		echo "$LST_EXP," > "${BASE_PATH}Data/results${ITERATIONS}_${exp}_${MACHINE}_uni.csv"
	fi
done

#echo "$LST_EXP," > "${BASE_PATH}Data/results${ITERATIONS}_dedicated_delegation_${MACHINE}.csv"

for exp in ${EXP_TYPE[@]}; do
	echo "now testing with $exp"
	for c_nr in ${CLIENT_NR[@]}; do
		./${exp}${ITERATIONS} -d $DURATION -t $c_nr -c 10 > "${BASE_PATH}/Data/raw_data.temp"

		# Sort the experiment output
		cat "${BASE_PATH}/Data/raw_data.temp" | sort > "${BASE_PATH}/Data/raw_data.temp2"

		# Match value for each experiment event and write it in a .csv format
		awk 'NR==FNR { A[$1]=1 ; next } $1 in A {printf "%s, ", $2}' "${BASE_PATH}experiment_ev" "${BASE_PATH}/Data/raw_data.temp2" >> "${BASE_PATH}Data/results${ITERATIONS}_${exp}_${MACHINE}_uni.csv"

		echo " " >> "${BASE_PATH}Data/results${ITERATIONS}_${exp}_${MACHINE}_uni.csv"
		sleep 2s
	done
done

# Cleanup
rm ${BASE_PATH}Data/test.temp ${BASE_PATH}Data/test.temp2 ${BASE_PATH}Data/raw_data.temp ${BASE_PATH}Data/raw_data.temp2

echo "fIle with data generated - move them to the benchmark folder before plotting"

