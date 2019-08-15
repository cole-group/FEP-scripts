Home="$PWD"


for i in $(cat $Home/pertlist); do 
a=${i:0:`expr index "$i" -`-1};
b=${i:`expr index "$i" -`};
c=L${a}_to_L${b};

mkdir $Home/Perturbations/$c;
mkdir $Home/Perturbations/$c/unbound ;
cd $Home/Perturbations/$c/unbound; 
python $Home/Parameters/prepareFEP.py --input1 $Home/Equilibrium/Lig${a}_Eq.prm7 $Home/Equilibrium/Lig${a}_Eq.rst7 --input2 $Home/Equilibrium/Lig${b}_Eq.prm7 $Home/Equilibrium/Lig${b}_Eq.rst7 --output $c ;

echo "################
   $c done
################";
done

cd $Home
source deactivate
