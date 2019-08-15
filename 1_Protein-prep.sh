# 1. protein prep better perform this manually to fix any issues.
Home="$PWD"
cd $Home/Protein
pwd

tleap -f $Home/Parameters/TLeap_prot.in

echo "Protein preparation done"
cd $Home

