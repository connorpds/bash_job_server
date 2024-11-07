accel_sim="/pool/connor/accel-sim-framework/gpu-simulator/bin/release/accel-sim.out"
workloads_toml=$1
configs_toml=$2
output_dir=$3
tracking_file=$4
max_jobs=72

#kernelslist.g files 
workloads=()
#workload names -- this includes an identifier for the dataset
workload_names=()
workload_ct=$(yq -r '.workloads | length' $workloads_toml)
for (( i=0; i<workload_ct; i++ )); do 
  workloads+=("$(yq eval -r ".workloads[$i].kernelslist" $workloads_toml)")
  workload_names+=("$(yq eval -r ".workloads[$i].name" $workloads_toml)")
done


#array of gpgpu-sim config files
gpgpu_sim_configs=()
#array of accel-sim config files 
accel_sim_configs=()
#array of config names 
config_names=()
#number of configs present, for iterating across them
configs_ct=$(yq eval -r '.configs | length' $configs_toml) 
for (( i=0; i<configs_ct; i++ )); do 
  config_names+=("$(yq -r ".configs[$i].name" $configs_toml)")
  gpgpu_sim_configs+=("$(yq eval -r ".configs[$i].gpgpu_sim_config" $configs_toml)")
  accel_sim_configs+=("$(yq eval -r ".configs[$i].accel_sim_config" $configs_toml)")
done




output_filenames=() #names of output files 
run_incantations=() #generated incantations to run the simulator
total_combinations=$(( configs_ct * workload_ct )) #number of combos we expect 
# Convolve the configs with the workloads (nested for), generating both
# the incantation and the output filename for each combination 
for (( i=0; i<configs_ct; i++ )); do 
  for (( j=0; j<workload_ct; j++ )); do 
    # generate our run commands 
    run_incantations+=("$accel_sim \
                            -trace ${workloads[j]} \
                            -config ${gpgpu_sim_configs[i]} \
                            -config ${accel_sim_configs[i]}")
    # generate our output filenames  
    output_filenames+=("${workload_names[j]}_${config_names[i]}")
  done
done


# run all the commands :)
job_pids=()
if [ ! -d $output_dir ]; then 
  mkdir -p $output_dir
fi 
  
for (( i=0; i<total_combinations; i++ )); do 
  #run the simulation as a background process 
  ${run_incantations[i]} > "$output_dir/${output_filenames[i]}.dat" &
  #record the job id 
  job_pids+=($!)
  #write the jobid and workload/configuration
  id="${job_pids[i]}"
  experiment="${output_filenames[i]}"
  echo "[[job_ids]]" >> $tracking_file
  echo "id=$id" >> $tracking_file
  echo "experiment=$experiment" >> $tracking_file
  
  echo "STARTED" 
  echo -e "Experiment: $experiment\t\tJob_PID: $id"

  #make sure we aren't at the job limit 
  while (( $(jobs -r | wc -l) >= max_jobs )); do 
    wait -n #wait for another job to complete before continuing
  done
done


