process Mosdepth_BAM{

    conda 'bioconda::mosdepth=0.3.14'

    input:
    path BAM_file

    output:
    tuple path("${BAM_file.baseName}.mosdepth.global.dist.txt"), path("${BAM_file.baseName}.mosdepth.summary.txt")

    script:
    """
    mosdepth -n ${BAM_file.baseName} ${BAM_file}
    """

}