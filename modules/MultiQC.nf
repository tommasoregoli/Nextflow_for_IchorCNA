process MultiQC{

    container 'multiqc/multiqc:latest'

    input:
    path file_list

    output:
    path "multiqc_report"

    script:
    """
    multiqc . -o multiqc_report
    """

}