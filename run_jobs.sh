accel_sim=$1
workloads_toml=$2
configs_toml=$3


#kernelslist.g files 
kernelslists=()
#workload names -- this includes an identifier for the dataset
workload_names=()
workload_ct=$(tomlq -r '.workloads | length' $workloads_toml)
for (( i=0; i<workload_ct; i++ )); do 
  kernelslists+=("$(tomlq -r ".workloads[$i].kernelslist" $workloads_toml)")
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
#TODO: convolve the configs with the workloads (nested for), generating both
      # the incantations required for the runs and the output filenames


# eval "$command"
function run_tasks(){
  the_args=$1
  for arg in "${the_args[@]}"; do 
    ./$accel_sim "$arg"   
  done 
}


read_workloads
run_tasks 
