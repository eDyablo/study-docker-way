ls /src | while read file
do
  cat "/src/$file" | cowsay -fdragon > "/out/$file"
done
