import os

configfile: "config.yaml"

rule all:
    input:
        expand("logs/{virus}_status.log", virus=config["viruses"])

        #expand("blast/{virus}_blast.txt", virus=config["viruses"][:10])

        #expand("logs/{virus}_status.log", virus=config["viruses"])
        #expand(os.path.join(config["data_dir"], "{virus}/{virus}_rerooted_outgroup_optimized.jsonl.gz"), virus=config["viruses"])

        #expand("blast/{virus}_blast.txt", virus=config["viruses"])

        #expand(os.path.join(config["data_dir"], "{virus}/{virus}_rerooted_outgroup_optimized.jsonl.gz"), virus=config["viruses"])
        #expand(os.path.join(config["data_dir"], "{virus}/rerooted_outgroup_optimized.pb.gz"), virus=config["viruses"][:15])
        #expand(os.path.join(config["data_dir"], "{virus}/{virus}_rerooted_outgroup_optimized.jsonl.gz"), virus=config["viruses"])
        #expand("blast/{virus}_blast.txt", virus=config["viruses"])
        #expand(os.path.join(config["data_dir"], "{virus}/{virus}_rerooted_outgroup_optimized.jsonl.gz"), virus=config["viruses"][:10])
        #expand("outgroup/{virus}_outgroup.vcf", virus=config["viruses"][:3])
        #expand(os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz"), virus=config["viruses"][:3])


rule get_virus:
    input:
        tsv = os.path.join(config["data_dir"], "{virus}/config.toml")
    output:
        fna="fastas/{virus}.fasta", taxid="taxids/{virus}.txt"
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
    shell:
        """
        mkdir -p logs
        mkdir -p blast
        tax=$(cat {input.taxid})
        #check against refseq first, then genbank
        blastn -db {config[refseq_database]} -query {input.fna} -out blast/{wildcards.virus}_blast.txt -outfmt '6 qseqid sacc pident evalue staxids sscinames' -negative_taxids $tax -max_target_seqs 10
        #if refseq returns no hits, try genbank (nt_viruses has been most successful)
        if [ $(wc -l < blast/{wildcards.virus}_blast.txt) -eq 0 ]; then
            blastn -db {config[genbank_database]} -query {input.fna} -out blast/{wildcards.virus}_blast.txt -outfmt '6 qseqid sacc pident evalue staxids sscinames' -negative_taxids $tax -max_target_seqs 10
            echo "Used genbank for {wildcards.virus}" >> logs/database.log
        fi
        #note that if both return no hits, the output file will be empty
        """

rule get_outgroup:
    input:
        blast="blast/{virus}_blast.txt"
    output:
        og="outgroup/{virus}_outgroup.fasta"
    shell:
        """
        mkdir -p outgroup
        mkdir -p logs
        #if blast file is empty, write to status log and exit
        #hopefully add another blast method at some point 
        if [ ! -s {input.blast} ]; then
            echo "{wildcards.virus} blast failed" > logs/{wildcards.virus}_status.log
            exit 0
        fi
        #at this point nothing should be empty
        #this command fails due to a faulty assumption about the format acc=$(head -n 1 {input.blast} | cut -f2 | perl -pe 's/ref//g' | perl -pe 's/\|//g')
        acc=$(head -n 1 {input.blast} | cut -f2 )
        if [[ $acc != *.* ]]; then
            acc="$acc.1"
        fi
        #check if outgroup fasta already downloaded
        #this doent do anything rn since fastas arent named by accession.
        if [ ! -f fastas/$acc.fasta ]; then
            timeout 5m datasets download virus genome accession $acc --filename $acc.zip
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
    log:
        "logs/{virus}_align.log"
    shell:
        """
        cat {input.ref} {input.og} > outgroup/{wildcards.virus}_to_align.fasta
        mafft outgroup/{wildcards.virus}_to_align.fasta > {output} 2> {log}
        rm outgroup/{wildcards.virus}_to_align.fasta
        """

rule make_vcf:
    input:
        og="outgroup/{virus}_aligned_outgroup.fasta",
        #tree = os.path.join(config["data_dir"], "{virus}/optimized.pb.gz")
    output:
        vcf="outgroup/{virus}_outgroup.vcf"

        #newtree = os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz")
    log:
        "logs/{virus}_faToVcf.log"
    shell:
        """
        faToVcf {input.og} outgroup/{wildcards.virus}_outgroup.vcf 2> {log}
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
        usher-sampled -i {input.tree} -v outgroup/{wildcards.virus}_outgroup.vcf -o {output.newtree} -T 1
        """

rule reroot:
    input:
        tree = os.path.join(config["data_dir"], "{virus}/outgroup_optimized.pb.gz"),
        og="outgroup/{virus}_outgroup.fasta"
    output:
        newtree = os.path.join(config["data_dir"], "{virus}/rerooted_outgroup_optimized.pb.gz")
    shell:
        """
        newroot=$(head -n 1 {input.og} | cut -d ' ' -f1 | perl -pe 's/>//g')
        echo $newroot
        matUtils extract -i {input.tree} -y $newroot -o {output.newtree}
        """

'''
rule convert:
    input:
        tree = os.path.join(config["data_dir"], "{virus}/rerooted_outgroup_optimized.pb.gz"),
        metadata = os.path.join(config["data_dir"], "{virus}/metadata.tsv.gz")
    output:
        jsonl = os.path.join(config["data_dir"], "{virus}/{virus}_rerooted_outgroup_optimized.jsonl.gz"),status="logs/{virus}_status.log"
    log:
        "logs/{virus}_convert.log"
    shell:
        """
        echo "{wildcards.virus} conversion started" > logs/{wildcards.virus}_jsonl.log
        header=$(zcat {input.metadata} | head -n 1 | tr '\t' ',' )
        echo $header > logs/${wildcards.virus}_header.log
        (usher_to_taxonium -i {input.tree} -m {input.metadata} -c $header -t {wildcards.virus} -o {output.jsonl}  > {log} 2>&1)
        echo "Converted {wildcards.virus} to jsonl" > logs/{wildcards.virus}_status.log
        """
'''

rule convert:
    input:
        tree=os.path.join(config["data_dir"], "{virus}/rerooted_outgroup_optimized.pb.gz"),
        metadata=os.path.join(config["data_dir"], "{virus}/metadata.tsv.gz")
    output:
        jsonl=os.path.join(config["data_dir"], "{virus}/{virus}_rerooted_outgroup_optimized.jsonl.gz"),
        status="logs/{virus}_status.log"
    log:
        "logs/{virus}_convert.log"
    shell:
        """
        # Run usher_to_taxonium, redirect stdout+stderr to the log
        usher_to_taxonium -i {input.tree} -m {input.metadata} -c {config[header]} -t {wildcards.virus} -o {output.jsonl} >> {log} 2>&1
        # Mark completion only if previous command succeeded
        #if [ $? -eq 0 ]; then
        echo "Converted {wildcards.virus} to jsonl" > {output.status}
        #else
        #    echo "{wildcards.virus} conversion failed" >> {log} 2>&1
        #    exit 1
        #fi
        """



