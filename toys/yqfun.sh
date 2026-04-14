yq eval '.workloads | length' $1
yq eval ".workloads[0].kernelslist" ./workloads/backprop-test.toml -r
for (( i=0; i<1; i++)); do 
  echo $i
  yq eval ".workloads[${i}].kernelslist"
done
