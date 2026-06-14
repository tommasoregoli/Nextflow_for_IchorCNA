process Bedtools_Intersect{

    container 'community.wave.seqera.io/library/bedtools:2.31.1--efd79503b8c63422'

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