process Cram2BAM{

    container 'community.wave.seqera.io/library/samtools:1.23.1--e8c68bc6da750dc8'

    input:
    path Cram_file
    path Reference_genome
    path Reference_genome_index

    output:
    path "${Cram_file.baseName}.bam"

    script:
    """
    samtools view -b -T ${Reference_genome} ${Cram_file} > ${Cram_file.baseName}.bam
    """

}