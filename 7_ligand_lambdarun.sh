Home="$PWD"


for i in $(cat $Home/pertlist); do 
a=${i:0:`expr index "$i" -`-1};
b=${i:`expr index "$i" -`};
c=L${a}_to_L${b};

cd $Home/Perturbations/$c/unbound; 
echo $PWD;
	for s in $(seq 0.0 0.1 1.0);
	do 
		mkdir lambda-${s} ;
		cd lambda-${s} ;
		somd-freenrg -t ../$c.prm7 -c ../$c.rst7 -m ../$c.pert -C $Home/Parameters/lambda.cfg -l $s ;
		echo "		=======================
				done $c  lambda $s 	
			======================="
		cd ../ ;
	done
   
done

cd $Home
conda deactivate
