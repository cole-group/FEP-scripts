Home="$PWD"

for f in $(cat $Home/Ligands/list); do 
mkdir $Home/Complex/$f ;
cd $Home/Complex/$f; 

cat > Tcom.in << EOF
source leaprc.protein.ff14SB
source leaprc.water.tip3p
loadamberparams frcmod.ionsjc_tip3p
loadamberparams gaff2.dat
loadamberparams $Home/Ligands/$f/UNK.frcmod
loadoff $Home/Ligands/$f/ligand.lib
lig = loadpdb $Home/Ligands/$f/$f.pdb
rec = loadpdb $Home/Protein/rec.pdb
complex = combine { lig rec }
check complex
saveamberparm complex complex.prm7 complex.rst7
savepdb complex complex.pdb
quit
EOF

tleap -f Tcom.in;

mpirun -np 2 sander.MPI -O -i $Home/Parameters/complexmin.in -p complex.prm7 -c complex.rst7 -ref complex.rst7 -r complexmin.rst7 -x complexmin.mdcrd -o complexmin.out;

cat > convert2pdb << EOF
parm complex.prm7
trajin complexmin.rst7
trajout complexmin.pdb pdb
go
quitNow running Equilibration of ligand Lig1

EOF

cpptraj -i convert2pdb;


cat > Tcom-sol.in << EOF
source leaprc.protein.ff14SB
source leaprc.water.tip3p
loadamberparams frcmod.ionsjc_tip3p
loadamberparams gaff2.dat
loadamberparams $Home/Ligands/$f/UNK.frcmod
loadoff $Home/Ligands/$f/ligand.lib
complex = loadpdb complexmin.pdb
check complex
solvatebox complex TIP3PBOX 12.0 0.7
charge complex
addIons2 complex Na+ 0
saveamberparm complex ${f}_CS.prm7 ${f}_CS.rst7
savepdb complex ${f}_CS.pdb
quit
EOF

tleap -f Tcom-sol.in;



echo "Now running Equilibration for $f-protein complex";
mpirun -np 6 sander.MPI -O -i $Home/Parameters/Watermi.cfg -p ${f}_CS.prm7 -c ${f}_CS.rst7  -ref ${f}_CS.rst7 -o ${f}_CSw.out -r ${f}_CSw.rst7 -x ${f}_CSw.mdcrd;
mpirun -np 35 sander.MPI -O -i $Home/Parameters/Minimis.cfg -p ${f}_CS.prm7 -c ${f}_CSw.rst7  -ref ${f}_CSw.rst7 -o ${f}_CSm.out -r ${f}_CSm.rst7 -x ${f}_CSm.mdcrd;
mpirun -np 35 sander.MPI -O -i $Home/Parameters/Eq1_nvt.cfg -p ${f}_CS.prm7 -c ${f}_CSm.rst7 -ref ${f}_CSm.rst7 -o ${f}_CSe1.out -r ${f}_CSe1.rst7 -x ${f}_CSe1.mdcrd;
mpirun -np 35 sander.MPI -O -i $Home/Parameters/Eq2_npt.cfg -p ${f}_CS.prm7 -c ${f}_CSe1.rst7 -ref ${f}_CSe1.rst7 -o ${f}_CSe2.out -r ${f}_CSe2.rst7 -x ${f}_CSe2.mdcrd;
mpirun -np 35 sander.MPI -O -i $Home/Parameters/Eq3_pre.cfg -p ${f}_CS.prm7 -c ${f}_CSe2.rst7 -ref ${f}_CSe2.rst7 -o ${f}_CSe3.out -r ${f}_CSe3.rst7 -x ${f}_CSe3.mdcrd;

rm convert2pdb;
cat > convert2pdb << EOF
parm ${f}_CS.prm7
trajin ${f}_CSe3.rst7
trajout ${f}_CSe3.pdb pdb
go
quit
EOF

cpptraj -i convert2pdb;
rm convert2pdb;

cp ${f}_CSe3.rst7 $Home/Equilibrium/Pro_${f}_Eq.rst7 ;
cp ${f}_CS.prm7   $Home/Equilibrium/Pro_${f}_Eq.prm7;

done

cd $Home
