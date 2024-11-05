program_to_run=$1
run_args_toml=$2
configs_toml=$3


#kernelslist.g files 
kernelslists=()
#workload names -- this includes an identifier for the dataset
workloads=()
function read_workloads(){
  run_args_ct=$(tomlq -r '.run_args | length' $run_args_toml)
  for (( i=0; i<run_args_ct; i++ )); do 
    kernelslists+=("$(tomlq -r ".run_args[$i].kernelslist" $run_args_toml)")
    workloads+=("$(tomlq -r ".run_args[$i].workload" $run_args_toml)")
  done
}


#array of gpgpu-sim config files
gpgpu_sim_configs=()
#array of accel-sim config files 
accel_sim_configs=()
function read_configs(){
  configs_ct=$(tomlq -r '.configs | length' $configs_toml) 
  for (( i=0; i<configs_ct; i++ )); do 
    gpgpu_sim_configs+=("$(tomlq -r ".configs[$i].gpgpu_sim_config")")
    accel_sim_configs+=("$(tomlq -r ".configs[$i].accel_sim_config")")
  done
}



function run_tasks(){
  for arg in "${args[@]}"; do 
    ./$program_to_run "$arg"   
  done 
}


read_workloads
run_tasks 
