set -e
echo Meal of the day is
echo ${DISH:-stew} | figlet ${FONT:+-f$FONT}
echo Bon appetit!
