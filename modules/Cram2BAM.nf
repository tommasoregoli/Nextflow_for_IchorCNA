process Cram2BAM{

    conda 'bioconda::samtools=1.23.1'

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
