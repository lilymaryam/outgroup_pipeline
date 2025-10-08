import os

configfile: "config.yaml"

rule all:
    input:
        expand(os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz"), virus=config["viruses"][:3])
        #expand("outgroup/{virus}_outgroup.vcf", virus=config["viruses"][:3])
        #expand(os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz"), virus=config["viruses"][:3])


rule get_virus:
    input:
        tsv = os.path.join(config["data_dir"], "{virus}/config.toml")
    output:
        fna="fastas/{virus}.fasta", taxid="taxids/{virus}.txt"
    log: "logs/get_{virus}.log"
    #conda:
    #    "envs/blast.yaml"
    shell:
        """
        mkdir -p fastas
        mkdir -p taxids
        # Extract accession from TSV
        acc=$(grep refseq_acc {input.tsv} | cut -d'=' -f2 | tr -d ",' ")
        tax=$(grep taxonomy_id {input.tsv} | cut -d'=' -f2 | tr -d ",' ")
        echo $tax > {output.taxid}
        datasets download virus genome accession $acc --filename $acc.zip
        unzip -p $acc.zip ncbi_dataset/data/genomic.fna > {output.fna}
        rm $acc.zip        
        """

rule blast:
    input:
        fna="fastas/{virus}.fasta",taxid="taxids/{virus}.txt"
    output:
        "blast/{virus}_blast.txt"
    #conda:
    #    "envs/blast.yaml"
    shell:
        """
        mkdir -p blast
        tax=$(cat {input.taxid})
        blastn -db {config[database]} -query {input.fna} -out blast/{wildcards.virus}_blast.txt -outfmt '6 qseqid sseqid pident evalue staxids sscinames' -negative_taxids $tax -max_target_seqs 10
        """

rule get_outgroup:
    input:
        blast="blast/{virus}_blast.txt"
    output:
        og="outgroup/{virus}_outgroup.fasta"
    #    log: "logs/get_{outgroup}.log"
    #conda:
    #    "envs/blast.yaml"
    shell:
        """
        mkdir -p outgroup
        acc=$(head -n 1 {input.blast} | cut -f2 | perl -pe 's/ref//g' | perl -pe 's/\|//g')
        if [ ! -f fastas/$acc.fasta ]; then
            datasets download virus genome accession $acc --filename $acc.zip
            unzip -p $acc.zip ncbi_dataset/data/genomic.fna > {output.og}
            rm $acc.zip
        else
            cp fastas/$acc.fasta {output.og}
        fi
        """

rule align:
    input:
        og="outgroup/{virus}_outgroup.fasta",
        ref="fastas/{virus}.fasta"
    output:
        "outgroup/{virus}_aligned_outgroup.fasta"
    shell:
        """
        cat {input.ref} {input.og} > outgroup/{wildcards.virus}_to_align.fasta
        mafft outgroup/{wildcards.virus}_to_align.fasta > {output}
        rm outgroup/{wildcards.virus}_to_align.fasta
        """

rule make_vcf:
    input:
        og="outgroup/{virus}_aligned_outgroup.fasta",
        #tree = os.path.join(config["data_dir"], "{virus}/optimized.pb.gz")
    output:
        vcf="outgroup/{virus}_outgroup.vcf"

        #newtree = os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz")
    shell:
        """
        faToVcf {input.og} outgroup/{wildcards.virus}_outgroup.vcf
        """


rule usher:
    input:
        og="outgroup/{virus}_outgroup.vcf",
        tree = os.path.join(config["data_dir"], "{virus}/optimized.pb.gz")
    output:
        newtree = os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz")
        #vcf="outgroup/{virus}_outgroup.vcf"

    shell:
        """
        usher-sampled -i {input.tree} -v outgroup/{wildcards.virus}_outgroup.vcf -o {output.newtree}
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