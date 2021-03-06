#! /bin/bash -l


#SBATCH -A b2010014
#SBATCH -p core
#SBATCH -o est_dfe.out
#SBATCH -e est_dfe.err
#SBATCH -J est_dfe.job
#SBATCH -t 3-00:00:00


est_dfe="/proj/b2011141/tools/dfe-alpha-release-2.14/est_dfe"
est_alpha_omega="/proj/b2011141/tools/dfe-alpha-release-2.14/est_alpha_omega"
prop_muts_in_s_ranges="/proj/b2011141/tools/dfe-alpha-release-2.14/prop_muts_in_s_ranges"
input_rscript="/proj/b2011141/pipeline/R/genomic_adaptation_paper/angsd/trichocarpa_2.real.DFE_input.R"

for file in {zero_fold,intron,intergenic,utr3,utr5}
do
OutDir="/proj/b2010014/nobackup/population_genetics/DFE/trichocarpa2/$file/real"
echo $OutDir
if [ ! -d "$OutDir" ]; then
mkdir -p $OutDir
fi
done

Rscript $input_rscript

for anno in {zero_fold,intron,intergenic,utr3,utr5}
do
OutDir="/proj/b2010014/nobackup/population_genetics/DFE/trichocarpa2/$anno/real"

#####Step1:site_class_0
echo  "data_path_1    /proj/b2011141/tools/dfe-alpha-release-2.14/data" > $OutDir/est_dfe.${anno}.site_class-0.txt 
echo  "data_path_2    /proj/b2011141/tools/dfe-alpha-release-2.14/data/data-three-epoch" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "sfs_input_file  $OutDir/trichocarpa2.$anno.real.txt" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "est_dfe_results_dir   $OutDir/results_dir_neut/" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "site_class  0" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "fold   1">> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "epochs  2" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "search_n2  1" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "t2_variable   1" >> $OutDir/est_dfe.${anno}.site_class-0.txt
echo "t2 50" >> $OutDir/est_dfe.${anno}.site_class-0.txt

$est_dfe -c $OutDir/est_dfe.${anno}.site_class-0.txt


#####Step2:site_class_1
echo  "data_path_1    /proj/b2011141/tools/dfe-alpha-release-2.14/data" > $OutDir/est_dfe.${anno}.site_class-1.txt
echo  "data_path_2    /proj/b2011141/tools/dfe-alpha-release-2.14/data/data-three-epoch" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "sfs_input_file  $OutDir/trichocarpa2.$anno.real.txt" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "est_dfe_results_dir   $OutDir/results_dir_sel/" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "est_dfe_demography_results_file   $OutDir/results_dir_neut/est_dfe.out" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "site_class  1" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "fold   1">> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "epochs  2" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "mean_s_variable  1" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "mean_s   -0.1" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "beta_variable  1" >> $OutDir/est_dfe.${anno}.site_class-1.txt
echo "beta   0.5" >> $OutDir/est_dfe.${anno}.site_class-1.txt

$est_dfe -c $OutDir/est_dfe.${anno}.site_class-1.txt

$prop_muts_in_s_ranges -c $OutDir/results_dir_sel/est_dfe.out -o $OutDir/results_dir_sel/prop_muls_in_s_ranges.output
done

for anno in {zero_fold,intron,intergenic,utr3,utr5}
do
OutDir="/proj/b2010014/nobackup/population_genetics/DFE/trichocarpa2/$anno/real"

#####Step3: est_alpha_omega

echo  "data_path_1    /proj/b2011141/tools/dfe-alpha-release-2.14/data/" > $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "divergence_file  $OutDir/trichocarpa2.$anno.omega.txt" >> $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "est_alpha_omega_results_file   $OutDir/est_alpha_omega.$anno.out" >> $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "est_dfe_results_file  $OutDir/results_dir_sel/est_dfe.out" >> $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "neut_egf_file  $OutDir/results_dir_neut/neut_egf.out" >> $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "sel_egf_file  $OutDir/results_dir_sel/sel_egf.out" >> $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "do_jukes_cantor  1" >> $OutDir/est_dfe.${anno}.alpha_omega.txt
echo "remove_poly  0" >> $OutDir/est_dfe.${anno}.alpha_omega.txt

$est_alpha_omega -c $OutDir/est_dfe.${anno}.alpha_omega.txt

done


