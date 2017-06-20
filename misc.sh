while read i; do
  qdel ${i}
done < $ jobs
