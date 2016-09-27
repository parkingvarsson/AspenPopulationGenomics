#! /bin/bash -l


#SBATCH -A b2012210
#SBATCH -p core
#SBATCH -o pairwise_shared.out
#SBATCH -e pairwise_shared.err
#SBATCH -J pairwise_shared.job
#SBATCH -t 5-00:00:00
#SBATCH --mail-user jing.wang@emg.umu.se
#SBATCH --mail-type=ALL

module load bioinfo-tools
#module load BEDTools/2.16.2
module load BEDTools


window=$1  ####window can be 10kb, 100kb, 1Mb

Input_vcf="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/three_species_ref_allele.vcf" ###This file contains all the information we need to summarize the data, the 6th,7th and 8th column shows the category of shared information between pairwise species, 6th is between tremula and trichocarpa, 7th is between tremuloides and trichocarpa, 8th is between tremula and tremuloides

ld_bed="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/tremula/ldhat/bed/$1" ###the bed file

OutDir="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/$1"

if [ ! -d "$OutDir" ]; then
mkdir -p $OutDir
fi

echo -e "Chr\tWin\tScaffold\tsnp_n\ttremula_trichocarpa\ttremuloides_trichocarpa\ttremula_tremuloides" > $OutDir/pairwise_shared.$1.summary


for file in $ld_bed/*bed
do
input=${file##*/}
chr_out=${input%%.bed}
number=${chr_out##*.}
chr_n=${chr_out#tremula_}
chr_number=${chr_n%.*}
echo $chr_number
chr="Chr"$chr_number
echo $chr

sed '1d' $file > $OutDir/$input

bedtools intersect -a $Input_vcf -b $OutDir/$input > $OutDir/${chr_out}.vcf

snp_n=$(cat $OutDir/${chr_out}.vcf |wc -l)
echo $snp_n

shared_tremula_trichocarpa=$(awk '$6=="shared"' $OutDir/${chr_out}.vcf |wc -l)
shared_tremula_trichocarpa_pro=$(echo -e "$shared_tremula_trichocarpa/$snp_n" |bc -l)

shared_tremuloides_trichocarpa=$(awk '$7=="shared"' $OutDir/${chr_out}.vcf |wc -l)
shared_tremuloides_trichocarpa_pro=$(echo -e "$shared_tremuloides_trichocarpa/$snp_n" |bc -l)

shared_tremula_tremuloides=$(awk '$8=="shared"' $OutDir/${chr_out}.vcf |wc -l)
shared_tremula_tremuloides_pro=$(echo -e "$shared_tremula_tremuloides/$snp_n" |bc -l)

scaffold=$(cut -f 2 $OutDir/$input)
echo $scaffold

if [ $1 == "10kb" ] ; then
middle_scaffold=$(echo $scaffold+5001 |bc)
fi
if [ $1 == "100kb" ] ; then
middle_scaffold=$(echo $scaffold+50001 |bc)
fi
if [ $1 == "500kb" ] ; then
middle_scaffold=$(echo $scaffold+250001 |bc)
fi
if [ $1 == "1Mb" ] ; then
middle_scaffold=$(echo $scaffold+500001 |bc)
fi

echo $middle_scaffold
echo -e "$chr\t$number\t$middle_scaffold\t$snp_n\t$shared_tremula_trichocarpa_pro\t$shared_tremuloides_trichocarpa_pro\t$shared_tremula_tremuloides_pro" >>  $OutDir/pairwise_shared.$1.summary

rm $OutDir/$input
rm $OutDir/${chr_out}.vcf

done

sort -k1,1V -k2,2n $OutDir/pairwise_shared.$1.summary > $OutDir/temp && mv $OutDir/temp $OutDir/pairwise_shared.$1.summary


