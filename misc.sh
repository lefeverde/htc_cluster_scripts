while read i; do
  scancel ${i}
done < jobs
