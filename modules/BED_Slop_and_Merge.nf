process BED_Slop_and_Merge{

    conda 'bioconda::bedtools=2.31.1'

    input:
    path reference_index
    path Bed_file
    val slop

    output:
    path "${Bed_file.baseName}_slop${slop}_merged.bed"


    script:
    """
    cut -f1,2 ${reference_index} > reference.size

    bedtools slop -i ${Bed_file} -g reference.size -b ${slop} > ${Bed_file.baseName}_slop${slop}.bed
  
    bedtools sort -i ${Bed_file.baseName}_slop${slop}.bed | bedtools merge -i stdin -c 4 -o distinct > ${Bed_file.baseName}_slop${slop}_merged.bed
    """
}
