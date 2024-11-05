accel_sim=$1
workloads_toml=$2
configs_toml=$3


#kernelslist.g files 
workloads=()
#workload names -- this includes an identifier for the dataset
workload_names=()
workload_ct=$(tomlq -r '.workloads | length' $workloads_toml)
for (( i=0; i<workload_ct; i++ )); do 
  workloads+=("$(tomlq -r ".workloads[$i].kernelslist" $workloads_toml)")
  workload_names+=("$(tomlq -r ".workloads[$i].name" $workloads_toml)")
done


#array of gpgpu-sim config files
gpgpu_sim_configs=()
#array of accel-sim config files 
accel_sim_configs=()
#array of config names 
config_names=()
#number of configs present, for iterating across them
configs_ct=$(tomlq -r '.configs | length' $configs_toml) 
for (( i=0; i<configs_ct; i++ )); do 
  gpgpu_sim_configs+=("$(tomlq -r ".configs[$i].gpgpu_sim_config")")
  accel_sim_configs+=("$(tomlq -r ".configs[$i].accel_sim_config")")
  config_names+=("$(tomlq -r ".configs[$i].name")")
done

output_filenames=() #names of output files 
run_incantations=() #generated incantations to run the simulator
total_combinations=$(( configs_ct * workload_ct )) #number of combos we expect 
# Convolve the configs with the workloads (nested for), generating both
# the incantation and the output filename for each combination 
for (( i=0; i<configs_ct; i++ )); do 
  for (( j=0; j<workload_ct; j++ )); do 
    # generate our run commands 
    run_incantations+=("./$accel_sim 
                            -trace ${workloads[j]} 
                            -config ${gpgpu_sim_configs[i]}
                            -config ${accel_sim_configs[i]}")
    # generate our output filenames  
    output_filenames+=("${workload_names[j]}_${config_names[i]}_results.txt")
  done
done


# run all the commands :)
function run_benchmarks(){
  for (( i=0; i<total_combinations; i++ )); do 
    echo "${run_incantations[i]} > ${output_filenames[i]}"
  done | parallel -j 72
}


