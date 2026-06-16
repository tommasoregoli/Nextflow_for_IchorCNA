process SamtoolsStats_BAM{

    conda 'bioconda::samtools=1.23.1'

    input:
    path BAM_file

    output:
    tuple path("${BAM_file.baseName}_stats.txt"), path("${BAM_file.baseName}_flagstat.txt"), path("${BAM_file.baseName}_coverage.txt")

    script:
    """
    # Genera le statistiche generali supportate da MultiQC
    samtools stats ${BAM_file} > ${BAM_file.baseName}_stats.txt
    
    # Genera il riepilogo dei flag (ottimo per vedere mappate/non mappate/duplicati)
    samtools flagstat ${BAM_file} > ${BAM_file.baseName}_flagstat.txt

    # 3. Percentuale di copertura
    samtools coverage ${BAM_file} > ${BAM_file.baseName}_coverage.txt
    """
}