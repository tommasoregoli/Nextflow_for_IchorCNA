process MultiQC{

    conda 'bioconda::multiqc=1.35'

    input:
    path file_list

    output:
    path "multiqc_report"

    script:
    """
    multiqc . -o multiqc_report
    """
}
