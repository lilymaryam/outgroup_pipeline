This is my pipeline for finding outgroups for 432 viral MATS for the viral usher trees project. 
**Note! my pipeline is currently using usher locally built.**
**conda installation of usher failed on phoenix. unclear if due to conda issues or server. i built usher with a conda local build in base and fixed a dependenccy issue with the commands below:**
`conda install -c conda-forge boost-cpp=1.76`
`export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATHcs`
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
`makeblastdb   -in viral.1.1.genomic.fna   -dbtype nucl   -parse_seqids   -taxid_map nucl_gb.accession2taxid   -out viral_taxid_db`
**important!!!! should be an absolute path**
`export BLASTDB=/path/to/dir/with/db/and/taxdb/files/`

To Do:
[ ] improve documentation
[ ] imporve i/o
[ ] control resources
[ ] figure out dependencies



