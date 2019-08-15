Home="$PWD"

cd $Home/Ligands
rm list

for i in *.mol2; do f="${i%.*}"; echo ${f} >> list;done

# to prevent accidental editing
chmod -w $Home/Ligands/list


for f in $(cat $Home/Ligands/list); do mkdir $Home/Ligands/$f;
cd $Home/Ligands/$f;
pwd;
antechamber -i $Home/Ligands/$f.mol2 -fi mol2 -o ligand.mol2 -fo mol2 -c bcc -nc +1 -at gaff2 -eq 2 -rn UNK -ek "qm_theory='AM1',grms_tol=0.0002,tight_p_conv=1,
  scfconv=1.0d-10,itrmax=500,pseudo_diag=1,
  maxcyc=1000,
";

parmchk2 -s gaff2 -i ligand.mol2 -f mol2 -o UNK.frcmod;

echo "parametrising ligand $f done"
done

cd $Home

