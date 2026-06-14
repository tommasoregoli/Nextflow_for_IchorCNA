process Stats_BAM{

    container 'community.wave.seqera.io/library/samtools:1.23.1--e8c68bc6da750dc8'

    input:
    path BAM_file

    output:
    tuple val("${BAM_file.baseName}"), path("${BAM_file.baseName}_stats_raw.txt"), path("${BAM_file.baseName}_coverage_raw.txt")

    script:
    """
    samtools view -c ${BAM_file} > ${BAM_file.baseName}_stats_raw.txt

    samtools coverage ${BAM_file} > ${BAM_file.baseName}_coverage_raw.txt
    """

}