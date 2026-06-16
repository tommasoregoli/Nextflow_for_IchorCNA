process Stats_BAM{

    conda 'bioconda::samtools=1.23.1'

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