process Mosdepth_BAM {

    conda 'bioconda::mosdepth=0.3.14'

    input:
    tuple path(bam), path(bam_bai)

    output:
    tuple path("${bam.baseName}.mosdepth.global.dist.txt"), path("${bam.baseName}.mosdepth.summary.txt")

    script:
    """
    mosdepth -n -F 1024 -Q 20 ${bam.baseName} ${bam}
    """
}