accel_sim="/pool/connor/accel-sim-framework/gpu-simulator/bin/release/accel-sim.out"
workloads_toml=$2
configs_toml=$3
tracking_file ="./job_tracking/jobs_tracking.dat" 

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
  config_names+=("$(tomlq -r ".configs[$i].name")")
  gpgpu_sim_configs+=("$(tomlq -r ".configs[$i].gpgpu_sim_config")")
  accel_sim_configs+=("$(tomlq -r ".configs[$i].accel_sim_config")")
done

output_filenames=() #names of output files 
run_incantations=() #generated incantations to run the simulator
total_combinations=$(( configs_ct * workload_ct )) #number of combos we expect 
# Convolve the configs with the workloads (nested for), generating both
# the incantation and the output filename for each combination 
for (( i=0; i<configs_ct; i++ )); do 
  for (( j=0; j<workload_ct; j++ )); do 
    # generate our run commands 
    run_incantations+=("./$accel_sim \
                            -trace ${workloads[j]} \
                            -config ${gpgpu_sim_configs[i]} \
                            -config ${accel_sim_configs[i]}")
    # generate our output filenames  
    output_filenames+=("${workload_names[j]}_${config_names[i]}")
  done
done


# run all the commands :)
job_pids=()
max_jobs=72
function run_benchmarks(){
  for (( i=0; i<total_combinations; i++ )); do 
    #run the simulation as a background process 
    ${run_incantations[i]} > "${output_filenames[i]}_results.txt" &
    #record the job id 
    job_pids+=($!)
    #write the jobid and workload/configuration
    id="${job_pids[i]}"
    experiment="${output_filenames[i]}"
    echo "[[job_ids]]" >> $tracking_file
    echo "id=$id" >> $tracking_file
    echo "experiment=$experiment" >> $tracking_file
    
    echo "STARTED" 
    echo -e "Experiment:\tJob_PID:"
    echo -e "$experiment\t$id"

    #make sure we aren't at the job limit 
    while (( $(jobs -r | wc -l) >= max_jobs )); do 
      wait -n #wait for another job to complete before continuing
    done
  done
}


