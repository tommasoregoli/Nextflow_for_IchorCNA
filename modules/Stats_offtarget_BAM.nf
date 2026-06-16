process Stats_offtarget_BAM{

    conda 'bioconda::samtools=1.23.1'

    input:
    path offtarget_BAM_file

    output:
    tuple val("${offtarget_BAM_file.baseName}"), path("${offtarget_BAM_file.baseName}_stats_raw.txt"), path("${offtarget_BAM_file.baseName}_coverage_raw.txt")

    script:
    """
    samtools view -c ${offtarget_BAM_file} > ${offtarget_BAM_file.baseName}_stats_raw.txt

    samtools coverage ${offtarget_BAM_file} > ${offtarget_BAM_file.baseName}_coverage_raw.txt
    """

}
