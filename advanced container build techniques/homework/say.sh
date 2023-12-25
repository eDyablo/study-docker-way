set -e
[ "$(ls /out)" ] || (echo FAIL: The /out directory must not be empty; exit 1)
ls /out | while read file
do
  cat "/out/$file"
done
