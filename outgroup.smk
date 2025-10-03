import os

configfile: "config.yaml"

rule all:
    input:
        expand("fastas/{virus}.fasta", virus=config["viruses"][:3])


rule get_virus:
    input:
        tsv = os.path.join(config["data_dir"], "{virus}/output_stats.tsv")
    output:
        "fastas/{virus}.fasta"
    log: "logs/get_{virus}.log"
    #conda:
    #    "envs/blast.yaml"
    shell:
        #efetch -db nucleotide -id $acc -format fasta > {output}
        """
        mkdir -p fastas
        # Extract accession from TSV
        acc=$(sed -n '2p' {input.tsv} | cut -f1)
        datasets download virus genome accession $acc --filename $acc.zip
        unzip -p $acc.zip ncbi_dataset/data/genomic.fna > {output}
        rm $acc.zip        
        """





# rule extract_accessions:
#     input:
#         expand("{datadir}/{virus}/output_stats.tsv", virus=config["viruses"], datadir=config["data_dir"])
#     output:
#         "accessions.txt"
#     shell:
#         """
#         for virus in {config[viruses]}; do
#             echo -n "$virus: "
#             sed -n '2p' {config[data_dir]}/$virus/output_stats.tsv | cut -f1
#         done > {output}
#         """

# rule get_fastas:
#     input:
#         "accessions.txt"
#     output:
#         directory("fastas")
#     conda:
#         "envs/blast.yaml"
#     shell:
#         """
#         mkdir -p fastas
#         while read line; do
#             acc=$(echo $line | cut -d':' -f2 | tr -d ' ')
#             efetch -db nucleotide -id $acc -format fasta > fastas/$acc.fasta
#         done < {input}
#         """