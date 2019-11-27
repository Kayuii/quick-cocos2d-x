#!/bin/bash
# rm -rf *.pch *.dep *.idb *.exp *.pdb *.obj *.idb *.aps *.res *.plg *.opt *.ncb *.bak *.tmp *.idb *.exp *.ilk *.map *.pdb *.tli *.tlh disasm.asm *.trg *.pch *.~* *.ddp *.sbr *.manifest *.dmp *.suo *.log *.unsuccessfulbuild *.user *.bsc *.ib_pdb_index *.ib_tag *.sdf *.tlog *.lastbuildstate *.suo

mkdir -p ./tmp/empty/
# rsnyc
rsync --delete-before -a -H -v --progress --stats ./tmp/empty/ ./build/
for file in .DS_Store;
do 
find . -path ./tmp -prune -o -name $file -type f -print -exec mv {} ./tmp \;

# find . -name $file -type f -print -exec echo {} \;  # rm -rf {} \;
# ext=${file%.*};
# mv $file $ext;
done
# find . -name '*.exe' -type f -print -exec rm -rf {} \;


