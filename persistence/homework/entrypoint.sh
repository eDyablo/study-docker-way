set -e

count_state_path=/state/itinerary-count
count=$(cat "$count_state_path")
font=$(cat /config/font)
path=/workspace/itinerary-point-$(printf '%*.*d' 3 3 $count)
echo $@ | figlet ${font:+-f$font} > "$path"
echo $count
cat "$path"
echo $((count + 1))> "$count_state_path"
