#! /bin/bash -l

# This is a small script using vcftools to remove indels

#SBATCH -A b2010014
#SBATCH -p core
#SBATCH -o Vcf_species_shared.out
#SBATCH -e Vcf_species_shared.err
#SBATCH -J Vcf_species_shared.job
#SBATCH -t 12:00:00
#SBATCH --mail-user jing.wang@emg.umu.se
#SBATCH --mail-type=ALL


module load bioinfo-tools
#module load vcftools

vcftools="/proj/b2011141/tools/vcftools/bin/vcftools"
bgzip="/proj/b2011141/tools/bgzip"

Inputvcf=$1
VCFDir=`dirname $1`

Out=${Inputvcf##*/}
echo $Out

OutDir="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared"

tremula="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/tremula/3species.snp.rm_indel.biallelic.DP5.GQ10.bed.all.tremula.recode.vcf.gz"
tremuloides="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/tremuloides/3species.snp.rm_indel.biallelic.DP5.GQ10.bed.all.tremuloides.recode.vcf.gz"
trichocarpa="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/trichocarpa/3species.snp.rm_indel.biallelic.DP5.GQ10.bed.all.trichocarpa.recode.vcf.gz"

$vcftools --freq2 --gzvcf $tremula --out $OutDir/tremula.freq
$vcftools --freq2 --gzvcf $tremuloides --out $OutDir/tremuloides.freq
$vcftools --freq2 --gzvcf $trichocarpa --out $OutDir/trichocarpa.freq




