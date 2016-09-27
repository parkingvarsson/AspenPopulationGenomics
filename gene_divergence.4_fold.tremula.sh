#! /bin/bash -l


#SBATCH -A b2012210
#SBATCH -p core
#SBATCH -o gene_diversity_divergence.tremula.out
#SBATCH -e gene_diversity_divergence.tremula.err
#SBATCH -J gene_diversity_divergence.tremula.job
#SBATCH -t 24:00:00

module load bioinfo-tools
module load BEDTools/2.16.2


mean="/proj/b2011141/tools/mean"
thetaStat="/proj/b2011141/tools/angsd0.602/misc/thetaStat"
vcf_to_thetas="/proj/b2011141/pipeline/perl/vcf_to_thetas.pl"

gene_gff="/proj/b2010014/GenomePaper/population_genetics/pan_genome/annotation/gene.larger_90.gff"

#OutDir="/proj/b2011141/nobackup/genomic_selection_paper/gene_alpha/MKtest/input"
OutDir="/proj/b2010014/GenomePaper/population_genetics/pan_genome/gene_diversity_divergence/tremula"

four_fold="/proj/b2010014/GenomePaper/population_genetics/pan_genome/fst_ngsStat/tremula_trichocarpa/all/anno_type/four_fold.filter.vcf"

echo -e "Name\t4_fold_df" > $OutDir/tremula.gene.4df.$1.txt

n_gene=$1

for ((i=$n_gene;i<$n_gene+500;i++)) 
do
	head -n $i $gene_gff | tail -n 1 > $OutDir/gene$i.gff
	name=$(cut -f 9 $OutDir/gene$i.gff |cut -f 2 -d ";" |sed s'/Name=//g')
	
######df,dxy,fst
	bedtools intersect -a $four_fold -b $OutDir/gene$i.gff > $OutDir/$name.four_fold.vcf

	gene_four_fold_df=$($mean col=8 $OutDir/$name.four_fold.vcf |cut -f 11)  ###the proportion of fixed differences between P.tremula and P.trichocarpa

	echo -e "$name\t$gene_four_fold_df" >> $OutDir/tremula.gene.4df.$1.txt
	
	rm $OutDir/gene$i.gff
	rm $OutDir/$name.four_fold.vcf	

done


