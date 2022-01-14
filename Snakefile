rule all:
    input: 
        expand('sixframe/{lib}.pep.hmmer_out', lib=config['assem'])

rule sixframe:
    input: lambda wildcards: config['assem'][wildcards.lib]
    output:
        cds="sixframe/{lib}.cds",
        pep="sixframe/{lib}.pep"
    conda: "envs/porc.yml"
    shell:
        "/ebio/abt2_projects/ag-swart-loxodes/opt/PORC/six_frame_pep_and_cds.py {input} {output.cds} {output.pep}"

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
        matrix="porc/{lib}.mat",
        porc="porc/{lib}.porc"
    conda: "envs/porc.yml"
    shell:
        "/ebio/abt2_projects/ag-swart-loxodes/opt/PORC/porc_cod_usage.py --cds {input.cds} --hmmer {input.hmmer_out} --matrix {output.matrix} > {output.porc}"

# rule weblogo:
#     input: "porc/{lib}.mat"
#     output: "porc/{lib}.weblogo.png"
#     conda: "envs/porc.yml"
#     shell:
#         "weblogo -n64 --scale-width no -c chemistry -U probability -A protein -F png < {input} > {output}"

