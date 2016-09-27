#! /bin/bash -l


#SBATCH -A b2010014
#SBATCH -p core
#SBATCH -o est_dfe.summary.out
#SBATCH -e est_dfe.summary.err
#SBATCH -J est_dfe.summary.job
#SBATCH -t 1-00:00:00


####this script is used to summarize the output of the dfe software packages

###the title of summary file should be 

##name,N2,t2,Nw,b,Es,f0,L,Nes<1,1<Nes<10,10<Nes<100,Nes>100,lambda,selected_divergence,alpha,omega_A

anno=$1
OutDir="/proj/b2010014/GenomePaper/population_genetics/pan_genome/dfe/tremuloides/$anno/summary"

if [ ! -d "$OutDir" ]; then
mkdir -p $OutDir
fi

echo -e "Name\tN2\tt2\tNw\tb\tEs\tf0\tL\tNes_1\tNes_1_10\tNes_10_100\tNes_100\tlambda\tselected_divergence\talpha\tomega_A" > $OutDir/tremuloides.dfe.$anno.summary

#####the real data
Input_real="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/$anno/dfe/tremuloides/real"

N2=$(cut -f 4 -d " " $Input_real/results_dir_sel/est_dfe.out)
t2=$(cut -f 6 -d " " $Input_real/results_dir_sel/est_dfe.out)
Nw=$(cut -f 8 -d " " $Input_real/results_dir_sel/est_dfe.out)
b=$(cut -f 10 -d " " $Input_real/results_dir_sel/est_dfe.out)
Es=$(cut -f 12 -d " " $Input_real/results_dir_sel/est_dfe.out)
f0=$(cut -f 14 -d " " $Input_real/results_dir_sel/est_dfe.out)
L=$(cut -f 16 -d " " $Input_real/results_dir_sel/est_dfe.out)
Nes_1=$(cut -f 3 -d " " $Input_real/results_dir_sel/prop_muls_in_s_ranges.output)
Nes_1_10=$(cut -f 6 -d " " $Input_real/results_dir_sel/prop_muls_in_s_ranges.output)
Nes_10_100=$(cut -f 9 -d " " $Input_real/results_dir_sel/prop_muls_in_s_ranges.output)
Nes_100=$(cut -f 12 -d " " $Input_real/results_dir_sel/prop_muls_in_s_ranges.output)

lambda=$(cut -f 2 -d " " $Input_real/est_alpha_omega.$anno.out)
selected_divergence=$(cut -f 4 -d " " $Input_real/est_alpha_omega.$anno.out)
alpha=$(cut -f 6 -d " " $Input_real/est_alpha_omega.$anno.out)
omega_A=$(cut -f 8 -d " " $Input_real/est_alpha_omega.$anno.out)

echo -e "real\t$N2\t$t2\t$Nw\t$b\t$Es\t$f0\t$L\t$Nes_1\t$Nes_1_10\t$Nes_10_100\t$Nes_100\t$lambda\t$selected_divergence\t$alpha\t$omega_A" >> $OutDir/tremuloides.dfe.$anno.summary

###bootstrap

for n in {1..200}
do
Input_bootstrap="/proj/b2010014/GenomePaper/population_genetics/pan_genome/shared/three_species/$anno/dfe/tremuloides/bootstrap/bootstrap$n"

N2=$(cut -f 4 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
t2=$(cut -f 6 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
Nw=$(cut -f 8 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
b=$(cut -f 10 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
Es=$(cut -f 12 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
f0=$(cut -f 14 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
L=$(cut -f 16 -d " " $Input_bootstrap/results_dir_sel/est_dfe.out)
Nes_1=$(cut -f 3 -d " " $Input_bootstrap/results_dir_sel/prop_muls_in_s_ranges.output)
Nes_1_10=$(cut -f 6 -d " " $Input_bootstrap/results_dir_sel/prop_muls_in_s_ranges.output)
Nes_10_100=$(cut -f 9 -d " " $Input_bootstrap/results_dir_sel/prop_muls_in_s_ranges.output)
Nes_100=$(cut -f 12 -d " " $Input_bootstrap/results_dir_sel/prop_muls_in_s_ranges.output)

lambda=$(cut -f 2 -d " " $Input_bootstrap/est_alpha_omega.$anno.out)
selected_divergence=$(cut -f 4 -d " " $Input_bootstrap/est_alpha_omega.$anno.out)
alpha=$(cut -f 6 -d " " $Input_bootstrap/est_alpha_omega.$anno.out)
omega_A=$(cut -f 8 -d " " $Input_bootstrap/est_alpha_omega.$anno.out)

echo -e "bootstrap$n\t$N2\t$t2\t$Nw\t$b\t$Es\t$f0\t$L\t$Nes_1\t$Nes_1_10\t$Nes_10_100\t$Nes_100\t$lambda\t$selected_divergence\t$alpha\t$omega_A" >> $OutDir/tremuloides.dfe.$anno.summary
done


