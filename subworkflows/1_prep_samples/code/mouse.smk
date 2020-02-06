
with open("data/mouse/SRR_Acc_List.txt", 'r') as file:
    mouse_filenames = [f"data/mouse/raw/{line.strip()}" for line in file]

rule download_mouse:
    input:
        list="data/mouse/SRR_Acc_List.txt",
        sh="code/download.sh"
    output:
        files=mouse_filenames
    params:
        tar="data/mouse/StabilityNoMetaG.tar",
        url="http://www.mothur.org/MiSeqDevelopmentData/StabilityNoMetaG.tar"
    benchmark:
        "benchmarks/mouse/download.txt"
    shell:
        """
        wget -N -P data/mouse/ {params.url}
        tar -xvf {params.tar} -C data/mouse/raw/
        rm {params.tar}
        """

rule names_file_mouse:
    input:
        files=rules.download_mouse.output.files,
        script="code/mouse.py"
    output:
        file="data/mouse/mouse.files"
    params:
        dir="data/mouse/raw"
    benchmark:
        "benchmarks/mouse/names_file.txt"
    shell:
        "python {input.script}"