# This is my pipeline for finding outgroups for 432 viral MATS for the viral usher trees project. 
**Note! my pipeline is currently using usher locally built because usher on conda fails and breaks environment.**
**conda installation of usher failed on phoenix. unclear if due to conda issues or server. i built usher with a conda local build in base and fixed a dependenccy issue with the commands below:**
`conda install -c conda-forge boost-cpp=1.76`
`export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATHcs`
**note: disregard above, now i am doing a local build from my blast_env**

**note: (to myself for now) usher conda does not work. i think im doing a local build from my blast_env but i will need to try a fresh build somewhere to figure out exactly what worked**

**usher issues make running it with slurm very hard. current version not recommended for cluster**

## Make a database for blast
Database can be placed anywhere. path to this database should be added to config file. DATABASE MUST HAVE appropriate taxids for anything to work. the refseq database i built has species level annotations (from what ive seen). any further databases must be carefully annotated with the correct taxids 

### BLAST user guide
https://www.ncbi.nlm.nih.gov/books/NBK569850/

## Viral RefSeq BLAST database with TaxIds
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

## Secondary GenBank Database for Samples that fail first blast  
i dont fully remember how i set this one up but its premade and once i downloaded entrez direct it started working perfectly. i should do a from scratch build so i can explain it better . i might acually only need one db 
`update_blastdb.pl --decompress nt_viruses`

## Running with refseq first appears to be appropriate. its much faster and refseq sequences can be relied on. it may be worth running some things with both. still unclear how to deal with qc for some outgroups. 

## Post outgrouping:
70 trees do not get a blast result. 40 of these are influenza. i need to address this

of the 354 trees. a certain number are not appearing to be reasonably outgrouped. I wrote check trees to get a sense of these ones. checktrees.py is still an estimate though. 




To Do:
[ ] rewrite rule so that all trees have titles in taxonium (ASAP!!!)
[ ] make contingencies for edge cases 
[ ] figure out whats failing and whats working
[ ] improve documentation
[ ] imporve i/o
[ ] control resources
[ ] figure out dependencies






