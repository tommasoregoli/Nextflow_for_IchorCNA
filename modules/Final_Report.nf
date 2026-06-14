process Final_Report{

    container 'ubuntu:latest'

    input:
    tuple val(Nome_BAM), path(Numero_letture_BAM), path(Statistiche_coverage_raw_BAM)

    output:
    path "${Nome_BAM}_stats.txt"

    script:
    """
    echo "Numero di reads nel file BAM ${Nome_BAM}:" > ${Nome_BAM}_stats.txt
    cat ${Numero_letture_BAM} >> ${Nome_BAM}_stats.txt

    echo "Statistiche di copertura del file BAM ${Nome_BAM}:" >> ${Nome_BAM}_stats.txt
    
    cat ${Statistiche_coverage_raw_BAM} | awk '
    NR==1 { print \$0; next }
    NR<=25 {
    	print \$0;
        Peso_chr = \$3*\$7;
    	sum4+=\$4;
     	sum6+=\$6;
     	sum7+=\$7;
        Peso_tot += Peso_chr;
        Totale_basi += \$3;
     	count++
}
    NR>25 { next }
    END {
	if(count>0){
		printf "\\n"
		printf "SOMMA\\t-\\t-\\t%.0f\\t-\\t-\\t-\\t-\\t-\\n", sum4;
		printf "MEDIA\\t-\\t-\\t-\\t-\\t%.4f\\t%.4f\\t-\\t-\\n", sum6/count, sum7/count;
        printf "MEDIA_PONDERATA\\t-\\t-\\t-\\t-\\t-\\t%.4f\\t-\\t-\\n", Peso_tot/Totale_basi;
	}
}' >> ${Nome_BAM}_stats.txt
    """

}