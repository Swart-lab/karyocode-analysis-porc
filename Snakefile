rule all:
    input: 
        # expand('porc_out/{lib}.porc.counts.tsv', lib=config['assem'])
        expand('porc_out/{lib}.porc.weblogo.png', lib=config['assem'])

rule sixframe:
    input: lambda wildcards: config['assem'][wildcards.lib]
    output:
        cds="sixframe/{lib}.cds",
        pep="sixframe/{lib}.pep"
    conda: "envs/porc.yml"
    shell:
        "/ebio/abt2_projects/ag-swart-karyocode/analysis/porc/opt/PORC/six_frame_pep_and_cds.py {input} {output.cds} {output.pep}"

rule hmmer:
    input: "sixframe/{lib}.pep"
    params:
        pfam_db=config['pfam_db']
    output: "sixframe/{lib}.pep.hmmer_out"
    conda: "envs/porc.yml"
    threads: 2
    shell: "hmmsearch --cpu {threads} -o {output} {params.pfam_db} {input}"

rule porc_main:
    input:
        cds="sixframe/{lib}.cds",
        hmmer_out="sixframe/{lib}.pep.hmmer_out"
    output:
        matrix="porc_out/{lib}.porc.mat",
        counts="porc_out/{lib}.porc.counts.tsv",
        porc="porc_out/{lib}.porc.out"
    conda: "envs/porc.yml"
    shell:
        "/ebio/abt2_projects/ag-swart-karyocode/analysis/porc/opt/PORC/porc_cod_usage.py --cds {input.cds} --hmmer {input.hmmer_out} --counts {output.counts} --matrix {output.matrix} > {output.porc}"

rule weblogo:
    input: "porc_out/{lib}.porc.mat",
    output: "porc_out/{lib}.porc.weblogo.png"
    conda: "envs/porc.yml"
    shell:
        "weblogo -n64 --scale-width no -c chemistry -U probability -A protein -F png < {input} > {output}"

