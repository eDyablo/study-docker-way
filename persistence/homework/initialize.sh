set -e

mkdir -p /config
mkdir -p /state

find / -type f -name *.flf -exec basename {} .flf \; > /config/fonts

echo big > /config/font
echo 1 > /state/itinerary-count
