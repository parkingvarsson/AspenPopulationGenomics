#! /bin/bash -l


#SBATCH -A b2012210
#SBATCH -p core
#SBATCH -o gene_diversity_divergence.tremula.out
#SBATCH -e gene_diversity_divergence.tremula.err
#SBATCH -J gene_diversity_divergence.tremula.job
#SBATCH -t 2-00:00:00

module load bioinfo-tools
module load BEDTools/2.16.2


mean="/proj/b2011141/tools/mean"
thetaStat="/proj/b2011141/tools/angsd0.602/misc/thetaStat"
vcf_to_thetas="/proj/b2011141/pipeline/perl/vcf_to_thetas.pl"

gene_gff="/proj/b2010014/GenomePaper/population_genetics/pan_genome/annotation/gene.larger_90.gff"

#OutDir="/proj/b2011141/nobackup/genomic_selection_paper/gene_alpha/MKtest/input"
OutDir="/proj/b2010014/GenomePaper/population_genetics/pan_genome/gene_diversity_divergence/tremula"

four_fold="/proj/b2010014/GenomePaper/population_genetics/pan_genome/ANGSD/tremula/tremula_all/thetas/anno_type/four_fold.filter.vcf"
zero_fold="/proj/b2010014/GenomePaper/population_genetics/pan_genome/fst_ngsStat/tremula_trichocarpa/all/anno_type/zero_fold.filter.vcf"

echo -e "Name\t4_fold_pi\t0_fold_df" > $OutDir/tremula.gene.4pi_0df.$1.txt

n_gene=$1

for ((i=$n_gene;i<$n_gene+100;i++)) 
do
	head -n $i $gene_gff | tail -n 1 > $OutDir/gene$i.gff
	name=$(cut -f 9 $OutDir/gene$i.gff |cut -f 2 -d ";" |sed s'/Name=//g')
	bedtools intersect -a $four_fold -b $OutDir/gene$i.gff > $OutDir/$name.four_fold.vcf
	perl $vcf_to_thetas $OutDir/$name.four_fold.vcf
	gzip $OutDir/$name.four_fold.thetas
	$thetaStat make_bed $OutDir/$name.four_fold.thetas.gz
	$thetaStat do_stat $OutDir/$name.four_fold.thetas.gz -nChr 48
	gene_four_fold_tP=$(cut -f 5 $OutDir/$name.four_fold.thetas.gz.pestPG)
	gene_four_fold_sites=$(cut -f 14 $OutDir/$name.four_fold.thetas.gz.pestPG)
	gene_four_fold_pi=$(echo "scale=4;$gene_four_fold_tP/$gene_four_fold_sites" |bc)
	
######df,dxy,fst
	bedtools intersect -a $zero_fold -b $OutDir/gene$i.gff > $OutDir/$name.zero_fold.vcf

	gene_zero_fold_df=$($mean col=8 $OutDir/$name.zero_fold.vcf |cut -f 11)  ###the proportion of fixed differences between P.tremula and P.trichocarpa

	echo -e "$name\t$gene_four_fold_pi\t$gene_zero_fold_df" >> $OutDir/tremula.gene.4pi_0df.$1.txt
	
	rm $OutDir/gene$i.gff
	rm $OutDir/$name.four_fold.thetas.gz
	rm $OutDir/$name.four_fold.thetas.gz.bin
	rm $OutDir/$name.four_fold.thetas.gz.idx
	rm $OutDir/$name.four_fold.thetas.gz.pestPG
	rm $OutDir/$name.four_fold.vcf
	rm $OutDir/$name.zero_fold.vcf	

done


