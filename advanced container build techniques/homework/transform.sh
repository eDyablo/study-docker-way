set -e
[ "$(ls /src)" ] || (echo FAIL: The /src directory must not be empty; exit 1)
mkdir /out
(
  ls /src | while read file
  do
    cat "/src/$file"
    echo
  done
) | cowsay -fdragon > "/out/wish"
