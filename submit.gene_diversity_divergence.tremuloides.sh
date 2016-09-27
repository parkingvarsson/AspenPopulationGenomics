####because we have 20759 geges for analyzing, I used this script to divide the jobs into 101 subjobs

OUT_DIR="/proj/b2011141/pipeline/nobackup/logs/tremuloides/genomic_adaptation"

if [ ! -d "$OUT_DIR" ]; then
 mkdir -p $OUT_DIR
fi


for ((i=1;i<=22910;i=i+100))
do
sbatch -e $OUT_DIR/tremuloides.gene_diversity_divergence.$i.err -o $OUT_DIR/tremuloides.gene_diversity_divergence.$i.out -J tremuloides.gene_diversity_divergence.$i.job gene_diversity_divergence.tremuloides.sh $i
echo $i

done 


