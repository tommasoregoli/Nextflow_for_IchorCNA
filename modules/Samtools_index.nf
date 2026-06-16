process Samtools_index{

    conda 'bioconda::samtools=1.23.1'

    input:
    path BAM_file_offtarget

    output:
    path "${BAM_file_offtarget}.bai"

    script:
    """
    samtools index ${BAM_file_offtarget}
    """

}
