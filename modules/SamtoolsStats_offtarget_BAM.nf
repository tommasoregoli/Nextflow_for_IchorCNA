process SamtoolsStats_offtarget_BAM{

    conda 'bioconda::samtools=1.23.1'

    input:
    path offtarget_BAM_file

    output:
    tuple path("${offtarget_BAM_file.baseName}_stats.txt"), path("${offtarget_BAM_file.baseName}_flagstat.txt")

    script:
    """
    # Genera le statistiche generali supportate da MultiQC
    samtools stats ${offtarget_BAM_file} > ${offtarget_BAM_file.baseName}_stats.txt
    
    # Genera il riepilogo dei flag (ottimo per vedere mappate/non mappate/duplicati)
    samtools flagstat ${offtarget_BAM_file} > ${offtarget_BAM_file.baseName}_flagstat.txt

    """
}