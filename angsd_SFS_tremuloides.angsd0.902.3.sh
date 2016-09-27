#! /bin/bash -l

#SBATCH -A b2012141
#SBATCH -p core
#SBATCH -o angsd_unfoldedSFS_samtools_24tremuloides.out
#SBATCH -e angsd_unfoldedSFS_samtools_24tremuloides.err
#SBATCH -J angsd_unfoldedSFS_samtools_24tremuloides.job
#SBATCH -t 3-00:00:00

angsd="/proj/b2011141/tools/angsd0.902/angsd/angsd"
realSFS="/proj/b2011141/tools/angsd0.902/angsd/misc/realSFS"
thetaStat="/proj/b2011141/tools/angsd0.902/angsd/misc/thetaStat"

bam_list_tremuloides="/proj/b2011141/nobackup/tremula_vs_tremuloides_paper/bwa_mem_alignment/bam/tremuloides/tremuloides.bam.list"
ref="/proj/b2011141/nobackup/reference/nisqV3/Ptrichocarpa_v3.0_210.fa"
OutDir="/proj/b2010014/nobackup/population_genetics/tremuloides/ANGSD/trichocarpa/tremuloides_${1}_3"

if [ ! -d "$OutDir" ]; then
mkdir -p $OutDir
fi

region="/proj/b2010014/GenomePaper/population_genetics/pan_genome/annotation/features/${1}_2/$1.filter.$2.region"

nInd=$(cat $bam_list_tremuloides | wc -l)
#nChrom=$(echo "2*$nInd" | bc)
nChrom=$nInd

echo $nInd
echo $nChrom

cp $angsd $OutDir
angsd2="/proj/b2010014/nobackup/population_genetics/tremula/ANGSD/trichocarpa/tremula_${1}_4/$2/angsd"

#first generate .saf file
$angsd2 -bam $bam_list_tremuloides -minMapQ 30 -minQ 20 -GL 1 -doSaf 1 -out $OutDir/tremuloides_$1.$2 -anc $ref -rf $region -fold 1

rm $angsd2

#use emOptim2 to optimization
#$emOptim2 $OutDir/tremula_$1.saf $nChrom -maxIter 100 -P 4 > $OutDir/tremula_$1.sfs

#calculate thetas
#$angsd -bam $bam_list_tremula -out $OutDir/tremula_$1 -doThetas 1 -GL 1 -doSaf 1 -anc $ref -rf $chr -pest $OutDir/tremula_$1.sfs -minMapQ 30 -minQ 20

#calculate Tajimas
#$thetaStat make_bed $OutDir/tremula_$1.thetas.gz
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom -win 100000 -step 100000 -outnames $OutDir/tremula_$1.thetas100kbwindow.gz
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom -win 500000 -step 500000 -outnames $OutDir/tremula_$1.thetas500kbwindow.gz
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom -win 1000000 -step 1000000 -outnames $OutDir/tremula_$1.thetas1Mwindow.gz
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom -win 10000 -step 5000 -outnames $OutDir/tremula_$1.thetas10kbwindow.5kbsliding.gz
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom -win 100000 -step 10000 -outnames $OutDir/tremula_$1.thetas100kbwindow.10kbsliding.gz
#$thetaStat do_stat $OutDir/tremula_$1.thetas.gz -nChr $nChrom -win 500000 -step 50000 -outnames $OutDir/tremula_$1.thetas500kbwindow.50kbsliding.gz

#calculate posterior probabilities of sample allele frequencies
#$angsd -bam $bam_list_tremula -GL 1 -doSaf 1 -anc $ref -rf $chr -minMapQ 30 -minQ 20 -pest $OutDir/tremula_$1.sfs -out $OutDir/tremula_$1.rf


