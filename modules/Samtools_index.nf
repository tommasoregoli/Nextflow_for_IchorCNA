process Samtools_index{

    container 'community.wave.seqera.io/library/samtools:1.23.1--e8c68bc6da750dc8'

    input:
    path BAM_file_offtarget

    output:
    path "${BAM_file_offtarget}.bai"

    script:
    """
    samtools index ${BAM_file_offtarget}
    """

}