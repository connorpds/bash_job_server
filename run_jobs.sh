program_to_run=$1
run_args_toml=$2

gpgpu_sim_configs=()
accel_sim_configs=()
#TODO:  
function read_configs(){

}

args=()
workloads()
function read_args(){
  run_args_ct=$(tomlq -r '.run_args | length' $run_args_toml)
  for (( i=0; i<run_args_ct; i++ )); do 
    args+=("$(tomlq -r ".run_args[$i].arg" $run_args_toml)")
    workloads+=("$(tomlq -r ".run_args[$i].workload" $run_args_toml)")
  done
}


function run_tasks(){
  for arg in "${args[@]}"; do 
    ./$program_to_run "$arg"   
  done 
}


read_args
run_tasks 
