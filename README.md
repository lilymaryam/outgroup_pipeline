# Outgroup reroot pipeline for viral_usher_trees

## Set Up
Used UShER Conda local build instructions https://usher-wiki.readthedocs.io/en/latest/Installation.html
UShER version 0.7.0

Conda environment 
./envs/blast.yml

### Hardware
This code was run on a Linux server with 63 threads and 1Tb memory. Though these rules were set up to use Slurm this pipeline was run with a designated number of jobs and no cluster management. It could be adapted for Slurm.

## Make databases for blast
Databases can be placed anywhere. The path to the databases should be added to config file `./config.yaml`. DATABASE MUST HAVE appropriate taxids for anything to work. the RefSeq database I built has species level annotations.

### BLAST user guide
https://www.ncbi.nlm.nih.gov/books/NBK569850/

### Viral RefSeq BLAST database with TaxIds
My BLAST database built from RefSeq viral genomes (release 232, September 2025; 18,798 sequences), database constructed 2025-10-06.

Make a dir for the db:
`mkdir /path/to/dir/with/db/and/taxdb/rs_db`
`cd /path/to/dir/with/db/and/taxdb/rs_db`

Download the RefSeq viral genomes:
`wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.*.genomic.fna.gz`
`gunzip viral.*.genomic.fna.gz`

Concatenate all shards into one FASTA (makeblastdb -in takes a single file, so the glob has to be merged first):
`cat viral.*.genomic.fna > viral.all.genomic.fna`

Get TaxID map 
`wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz`
`gunzip nucl_gb.accession2taxid.gz`
`tail -n +2 nucl_gb.accession2taxid | cut -f2,3 > acc2taxid.2col`
`wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz`
`tar -xzvf taxdb.tar.gz`

**assuming building in current dir with all files**
`makeblastdb -in viral.all.genomic.fna -dbtype nucl -parse_seqids -taxid_map acc2taxid.2col -out viral_taxid_db`

**⚠️ Set BLASTDB — required for taxid filtering**
`export BLASTDB=/path/to/dir/with/db/and/taxdb/files/`

### Secondary GenBank Database for Samples that fail first blast

This is NCBI's pre-built `nt_viruses` database (viral subset of nt), not built from scratch — NCBI compiles it and hosts it, so `update_blastdb.pl` just downloads and unpacks it. Taxonomy is already built in (v5), so no taxid_map step is needed here.

**Prerequisite:** edirect must be available — it's in the conda env (envs/blast.yaml), so activate that first.

`update_blastdb.pl` downloads into the current working directory, so cd into the target directory first.
`update_blastdb.pl --decompress nt_viruses`

**Note:** there's no version number like RefSeq has, so write down the download date instead. Check it with `blastdbcmd -db nt_viruses -info` (Date field). This one: Sep 15, 2025.

**Final DB step: Add database paths to config variables refseq_db and genbank_db**

## Running outgroup_pipeline on all of viral_usher_trees 
First clone data to a dir of your choosing. Dataset is large--make sure to have adequate space.
`git clone https://github.com/AngieHinrichs/viral_usher_trees.git`
Set up this dir so that you can git pull on a monthly basis to get the most up-to-date dataset. This is less important if this is a one-time run. 

Record path to data in config.yaml variable `data_dir`. 

Config.yaml lists all viruses being tracked. If new viral trees are added, this will need to be updated in config.yaml or they will be skipped. 
This also means that config.yaml can be modified to focus on certain viruses. 

To run this snakemake pipeline the commmand `snakemake -s outgroup.smk --cores {n cores} --resources ncbi=1 --rerun-incomplete -k` will successfully run. The pipeline handles sample dropout by tracking logfiles instead of outputs. To identify sample dropouts, the log files can be queried for failures. This pipeline runs well on Linux servers and naturally accounts for ncbi resource request limits. It currently is not set up to run on a cluster if the login node is low-resource. This pipeline would need to be modified for that purpose. 

## Post outgrouping:
70 trees do not get a blast result. 40 of these are influenza. Failure to find outgroups is somewhat expected as we can only find a suitable outgroup if there is a viral sequence resembling but outside of the species TaxID of our virus of interest. The goal with candidate outgroups is to observe if the closest matching non-relative is a possible outgroup. Final decisions are currently made with comparison to other suitable but imperfect approaches. Ideal result is concordance among multiple approaches. 

