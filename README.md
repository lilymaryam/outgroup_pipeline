This is my pipeline for finding outgroups for 432 viral MATS for the viral usher trees project. 
**Note! my pipeline is currently using usher locally built.**
**conda installation of usher failed on phoenix. unclear if due to conda issues or server. i built usher with a conda local build in base and fixed a dependenccy issue with the commands below:**
`conda install -c conda-forge boost-cpp=1.76`
`export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATHcs`
**note: disregard above, now i am doing a local build from my blast_env**

## Make a database for blast
Database can be placed anywhere. path to this database should be added to config file. 

### BLAST user guide
https://www.ncbi.nlm.nih.gov/books/NBK569850/

## actually worked this time
get refseq viral fastas
`wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.*.genomic.fna.gz`
`gunzip viral.*.genomic.fna.gz`
`wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz`
`gunzip nucl_gb.accession2taxid.gz`
`wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz`
`tar -xzvf taxdb.tar.gz`
**assuming building in current dir with all files**
this might actually be missing a step. acc2taxid is too many columns
`makeblastdb   -in viral.1.1.genomic.fna   -dbtype nucl   -parse_seqids   -taxid_map nucl_gb.accession2taxid   -out viral_taxid_db`
**important!!!! should be an absolute path**
`export BLASTDB=/path/to/dir/with/db/and/taxdb/files/`

To Do:
[ ] rewrite rule so that all trees have titles in taxonium (ASAP!!!)
[ ] make contingencies for edge cases 
[ ] figure out whats failing and whats working
[ ] improve documentation
[ ] imporve i/o
[ ] control resources
[ ] figure out dependencies

### Notes on data:
Questions i have:
how were these refs chosen? are they whole genomes or pieces 

233 samples do not get blast results. i am examining these to understand if there are no good options or if something else is wrong

#### Norovirus_GV (and probably all others): 
**there are 10 norovirus trees and all of them failed to get a blast result**
**multi tree viruses are not working in the current set up**
The taxonomy id in the config.toml file might be wrong? when i run a browser blast i get DQ285629.1 as the suggested outgroup. its already in the tree and its already rooted there. i wonder if this tree needs a reroot? i also wonder if this tree has more than 1 taxid though 
**norovirus may need more processing**

#### Rotovirus
blast didn't work locally. worked in browser but result did not change root sufficiently. not an appropriate choice ?




