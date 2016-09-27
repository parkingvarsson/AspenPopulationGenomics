#! /bin/bash -l


#SBATCH -A b2012141
#SBATCH -p core
#SBATCH -o gene_diversity_divergence.tremula.out
#SBATCH -e gene_diversity_divergence.tremula.err
#SBATCH -J gene_diversity_divergence.tremula.job
#SBATCH -t 1-00:00:00

module load bioinfo-tools
module load BEDTools/2.20.1


mean="/proj/b2011141/tools/mean"
thetaStat="/proj/b2011141/tools/angsd0.602/misc/thetaStat"
vcf_to_thetas="/proj/b2011141/pipeline/perl/vcf_to_thetas.pl"

gene_gff="/proj/b2010014/GenomePaper/population_genetics/pan_genome/annotation/gene.larger_90.gff"

#OutDir="/proj/b2011141/nobackup/genomic_selection_paper/gene_alpha/MKtest/input"
OutDir="/proj/b2010014/GenomePaper/population_genetics/pan_genome/gene_alpha/tremula"

if [ ! -d "$OutDir" ]; then
mkdir -p $OutDir
fi

shared_vcf="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/three_species_ref_allele.vcf" ##This file includes the information whether the snp is private, shared or fixed within and between species

four_fold_bed="/proj/b2010014/GenomePaper/population_genetics/pan_genome/annotation/features/four_fold.filter.bed"
zero_fold_bed="/proj/b2010014/GenomePaper/population_genetics/pan_genome/annotation/features/zero_fold.filter.bed"

four_fold="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/four_fold/three_species_ref_allele.four_fold.bed"
zero_fold="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/zero_fold/three_species_ref_allele.zero_fold.bed"

#echo "Dn,Ln(D),Pn,Ln(P),Ds,Ls(D),Ps,Ls(P),alleles,Chr,Class,r(recombination rate)" > $OutDir/gene.MKtest.input.txt
echo -e "Name\tDn_c\tLn(D)\tPn\tLn(P)\tDs_c\tLs(D)\tPs\tLs(P)" > $OutDir/tremula.gene_alpha.$1.txt
echo -e "Name\tDn_c\tLn(D)\tPn\tLn(P)\tDs_c\tLs(D)\tPs\tLs(P)" > $OutDir/tremula.gene_alpha.$1.maf15.txt

n_gene=$1

for ((i=$n_gene;i<$n_gene+100;i++)) 
do
	head -n $i $gene_gff | tail -n 1 > $OutDir/gene$i.gff
	name=$(cut -f 9 $OutDir/gene$i.gff |cut -f 2 -d ";" |sed s'/Name=//g')
	bedtools intersect -a $four_fold -b $OutDir/gene$i.gff > $OutDir/$name.four_fold.vcf
	bedtools intersect -a $zero_fold -b $OutDir/gene$i.gff > $OutDir/$name.zero_fold.vcf
	bedtools intersect -a $zero_fold_bed -b $OutDir/gene$i.gff > $OutDir/$name.zero_fold.bed
	bedtools intersect -a $four_fold_bed -b $OutDir/gene$i.gff > $OutDir/$name.four_fold.bed
	
	Ps=$(awk '$4>0' $OutDir/$name.four_fold.vcf |awk '$4<1'|wc -l)  ###$4 represents the polymorphic sites in tremula
	Ps_maf15=$(awk '$4>0.15' $OutDir/$name.four_fold.vcf |awk '$4<0.85'|wc -l)  ###$4 represents the polymorphic sites in tremula
	Pn=$(awk '$4>0' $OutDir/$name.zero_fold.vcf |awk '$4<1'|wc -l)
	Pn_maf15=$(awk '$4>0.15' $OutDir/$name.zero_fold.vcf |awk '$4<0.85'|wc -l)
	Ln=$(cat $OutDir/$name.zero_fold.bed |wc -l)
	Ls=$(cat $OutDir/$name.four_fold.bed |wc -l)
	Dn=$(awk '$7=="fixed"' $OutDir/$name.zero_fold.vcf |wc -l)
	Ds=$(awk '$7=="fixed"' $OutDir/$name.four_fold.vcf |wc -l)

	###calculate the Jukes-Cantor corrected divergence
        Dn_c=$(echo -e "-3*$Ln*l(1-4*($Dn/$Ln)/3)/4" | bc -l)
        Ds_c=$(echo -e "-3*$Ls*l(1-4*($Ds/$Ls)/3)/4" | bc -l)


        #echo -e "$name,$Dn,$Ln_D,$Pn,$Ln_P,$Ds,$Ls_D,$Ps,$Ls_P,48" >> $OutDir/gene.MKtest.input.txt
        echo -e "$name\t$Dn_c\t$Ln\t$Pn\t$Ln\t$Ds_c\t$Ls\t$Ps\t$Ls" >> $OutDir/tremula.gene_alpha.$1.txt
        echo -e "$name\t$Dn_c\t$Ln\t$Pn_maf15\t$Ln\t$Ds_c\t$Ls\t$Ps_maf15\t$Ls" >> $OutDir/tremula.gene_alpha.$1.maf15.txt


rm $OutDir/$name.four_fold.vcf
rm $OutDir/gene$i.gff
rm $OutDir/$name.zero_fold.vcf
rm $OutDir/$name.zero_fold.bed
rm $OutDir/$name.four_fold.bed

done


