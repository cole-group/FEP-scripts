# 1. protein prep better perform this manually to fix any issues.
Home="$PWD"

for f in $(cat $Home/Ligands/list); do cd $Home/Ligands/$f;
pwd;

cat > Tlig.in << EOF
loadamberparams gaff2.dat
loadamberparams UNK.frcmod
UNK = loadmol2 ligand.mol2
check UNK
saveoff UNK ligand.lib
savepdb UNK $f.pdb
quit
EOF

tleap -f Tlig.in;


#ligand solvation using qm optimised str sqm.pdb
cat > TligS.in << EOF
source leaprc.water.tip3p
loadamberparams frcmod.ionsjc_tip3p
loadamberparams gaff2.dat
loadamberparams UNK.frcmod
loadoff ligand.lib
lig = loadpdb sqm.pdb            #QM optimised str
solvatebox lig TIP3PBOX 12.0 0.7
charge lig
saveamberparm lig ${f}_S.prm7 ${f}_S.rst7
savepdb lig ${f}_S.pdb
quit
EOF

tleap -f TligS.in;

echo "Now running Equilibration of ligand $f";

mpirun -np 2 sander.MPI -O -i $Home/Parameters/Minimis.cfg -p ${f}_S.prm7 -c ${f}_S.rst7  -ref ${f}_S.rst7 -o ${f}_Sm.out -r ${f}_Sm.rst7 -x ${f}_Sm.mdcrd;
mpirun -np 2 sander.MPI -O -i $Home/Parameters/Eq1_nvt.cfg -p ${f}_S.prm7 -c ${f}_Sm.rst7 -ref ${f}_Sm.rst7 -o ${f}_Se1.out -r ${f}_Se1.rst7 -x ${f}_Se1.mdcrd;
mpirun -np 6 sander.MPI -O -i $Home/Parameters/Eq2_npt.cfg -p ${f}_S.prm7 -c ${f}_Se1.rst7 -ref ${f}_Se1.rst7 -o ${f}_Se2.out -r ${f}_Se2.rst7 -x ${f}_Se2.mdcrd;
mpirun -np 6 sander.MPI -O -i $Home/Parameters/Eq3_pre.cfg -p ${f}_S.prm7 -c ${f}_Se2.rst7 -ref ${f}_Se2.rst7 -o ${f}_Se3.out -r ${f}_Se3.rst7 -x ${f}_Se3.mdcrd;

cp ${f}_Se3.rst7 $Home/Equilibrium/${f}_Eq.rst7 ;
cp ${f}_S.prm7   $Home/Equilibrium/${f}_Eq.prm7;

done
cd $Home
