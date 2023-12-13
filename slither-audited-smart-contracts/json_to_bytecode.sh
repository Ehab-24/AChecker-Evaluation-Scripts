mkdir -p ./bytecode

for file in ./json/*.json; do
    name=$(jq -r '.address' "$file")
    filename="./bytecode/${name}.txt"
    jq -r '.bytecode' "$file" | sed 's/^.\(.*\).$/\1/' > "$filename"
done
