process Mosdepth_offtarget_BAM{

    conda 'bioconda::mosdepth=0.3.14'

    input:
    path offtarget_BAM_file

    output:
    tuple path("${offtarget_BAM_file.baseName}.mosdepth.global.dist.txt"), path("${offtarget_BAM_file.baseName}.mosdepth.summary.txt")

    script:
    """
    mosdepth -n ${offtarget_BAM_file.baseName} ${offtarget_BAM_file}
    """

}