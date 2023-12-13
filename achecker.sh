#!/bin/bash
# input:    in_dir - source dir of .bin files
#           out_dir - destination dir for results.csv
# output: out_dir/results.csv

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir>"
    exit 1
fi

if test -s "$2/results.csv"; then
    echo "Error: $2/results.csv is not empty."
    exit 1
fi

in_dir="$1"
out_dir="$2"
out_file="$out_dir/results.csv"

mkdir -p "$out_dir"

echo -n "" > "$out_file"
echo "Contract Name,Contract Path,Violated,Missing,Intended,Time (ms)" > "$out_file"

for file in "$in_dir"/*.bin; do
    filename=$(basename "$file")
    
    in_file="$in_dir/$filename"
    
    if test -s "$in_file"; then

        output=$(timeout 90s achecker.py -f "$in_file" -m 12 -b)
        if test -s "$output"; then
            echo "timeout: $filename"
        else
            violated=$(echo "$output" | grep -o 'Violated access control checks: [0-9]\+' | awk '{print $5}')
            missing=$(echo "$output" | grep -o 'Missing access control checks: [0-9]\+' | awk '{print $5}')
            intended=$(echo "$output" | grep -o 'Intended behavior: [0-9]\+' | awk '{print $3}')
            elapsed_time=$(echo "$output" | grep -o 'Elapsed Time (ms): [0-9.]\+' | awk '{print $4}')

            echo "$filename,$in_file,$violated,$missing,$intended,$elapsed_time" >> "$out_file"
        fi

    fi
done
