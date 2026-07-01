process Bedtools_Intersect{

    conda 'bioconda::bedtools=2.31.1'

    input:
    path BAM_file
    path Bed_file

    output:
    path "${BAM_file.baseName}_offtarget.bam"

    script:
    """
    bedtools intersect -v \
      -a ${BAM_file} \
      -b ${Bed_file} \
      > ${BAM_file.baseName}_offtarget.bam
    """
}
