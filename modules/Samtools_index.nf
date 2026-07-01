process Samtools_index{

    conda 'bioconda::samtools=1.23.1'

    input:
    path BAM_file

    output:
    tuple path(BAM_file), path("${BAM_file}.bai")

    script:
    """
    samtools index ${BAM_file}
    """
}
