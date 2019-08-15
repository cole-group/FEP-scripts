Home="$PWD"


for i in $(cat $Home/pertlist); do 
a=${i:0:`expr index "$i" -`-1};
b=${i:`expr index "$i" -`};
c=L${a}_to_L${b};

mkdir $Home/Perturbations/$c/bound ;
cd $Home/Perturbations/$c/bound; 
python $Home/Parameters/prepareFEP.py --input1 $Home/Equilibrium/Pro_Lig${a}_Eq.prm7 $Home/Equilibrium/Pro_Lig${a}_Eq.rst7 --input2 $Home/Equilibrium/Pro_Lig${b}_Eq.prm7 $Home/Equilibrium/Pro_Lig${b}_Eq.rst7 --output $c ;

echo "################
   complex $c done
################";
done

cd $Home
source deactivate
