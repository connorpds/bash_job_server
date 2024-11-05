
program_to_run=$1


args=()
function read_args(){
  run_args_ct=$(tomlq -r '.run_args | length' hellos.toml)
  for (( i=0; i<run_args_ct; i++ )); do 
    args+=("$(tomlq -r ".run_args[$i].arg" hellos.toml)")
  done
}


function run_tasks(){
  for arg in "${args[@]}"; do 
    ./$program_to_run "$arg"   
  done 
}


read_args
run_tasks 
