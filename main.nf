#!/usr/bin/env nextflow


include { Bedtools_Intersect } from './modules/Bedtools_Intersect.nf'
include { Cram2BAM } from './modules/Cram2BAM.nf'
include { Samtools_index } from './modules/Samtools_index.nf'
include { Stats_offtarget_BAM } from './modules/Stats_offtarget_BAM.nf'
include { SamtoolsStats_BAM } from './modules/SamtoolsStats_BAM.nf'
include { SamtoolsStats_offtarget_BAM } from './modules/SamtoolsStats_offtarget_BAM.nf'
include { Final_Report } from './modules/Final_Report.nf'
include { MultiQC } from './modules/MultiQC.nf'


/*
Pipeline Parameters
*/
params{
    bed: Path
    CRAM: Path
    reference: Path
    reference_index: Path
}


/*
Workflow
*/
workflow{
    
    main:
    //Creo il canale che mi prende in ingresso i file BAM che scriverò in un csv
    Canale = channel.fromPath(params.CRAM)
                    .splitCsv()
    
    //Converto il file CRAM in BAM
    Cram2BAM(Canale, params.reference, params.reference_index)
    
    //Eseguo Bedtools intersect per ogni file Bam che inserisco
    Bedtools_Intersect(Cram2BAM.out, params.bed)

    //Eseguo l'indicizzazione del file BAM ottenuto da Bedtools intersect
    Samtools_index(Bedtools_Intersect.out)

    //Eseguo le statistiche sul file BAM ottenuto da Cram2BAM
    SamtoolsStats_BAM(Cram2BAM.out)

    //Eseguo le statistiche sul file BAM_offtarget ottenuto da Bedtools intersect
    SamtoolsStats_offtarget_BAM(Bedtools_Intersect.out)

    Stats_offtarget_BAM(Bedtools_Intersect.out)

    //Eseguo il report finale con le statistiche ottenute da Stats_BAM
    Final_Report(Stats_offtarget_BAM.out)

    //Eseguo MultiQC per ottenere un report generale sui file BAM ottenuti da Bedtools intersect
    Canale_MultiQC = SamtoolsStats_BAM.out.mix(SamtoolsStats_offtarget_BAM.out)
                                  .flatten()                   
                                  .collect()
    
    MultiQC(Canale_MultiQC)

    publish:
    first_output = Cram2BAM.out
    second_output = Bedtools_Intersect.out
    third_output = Samtools_index.out
    fourth_output = Final_Report.out
    fifth_output = MultiQC.out
}

output {
    first_output {
         path "Cram2BAM"
    }
    second_output {
         path "Bedtools_Intersect"
    }
    third_output {
         path "Samtools_index"
    }
    fourth_output {
         path "Final_Report"
    }
    fifth_output {
         path "MultiQC"
    }
}
