#!/usr/bin/env nextflow

include { BED_Slop_and_Merge } from './modules/BED_Slop_and_Merge.nf'
include { Bedtools_Intersect } from './modules/Bedtools_Intersect.nf'
include { Cram2BAM } from './modules/Cram2BAM.nf'
include { Samtools_index } from './modules/Samtools_index.nf'
include { SamtoolsStats_BAM } from './modules/SamtoolsStats_BAM.nf'
include { Mosdepth_BAM } from './modules/Mosdepth_BAM.nf'
include { MultiQC } from './modules/MultiQC.nf'



/*
Pipeline Parameters
*/
params {
	slop: Integer
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
    

	if (params.BED_Slop_and_Merge) {
		//Eseguo Bedtools slop e merge sul file BED che inserisco solo se lo dichiaro true da terminale con il parametro --BED_Slop_and_Merge true
		BED_Slop_and_Merge(params.reference_index, params.bed, params.slop)

		Bedtools_Intersect(Cram2BAM.out, BED_Slop_and_Merge.out)
	}
	else {
    	//Eseguo Bedtools intersect normalmente usano il file bed di default indicato nel file nextflow.config
   		Bedtools_Intersect(Cram2BAM.out, params.bed)
	}

    channel_for_indexing = Bedtools_Intersect.out.mix(Cram2BAM.out)

    //Eseguo l'indicizzazione del file BAM ottenuto da Bedtools intersect
    Samtools_index(channel_for_indexing)

    channel_for_stats = Bedtools_Intersect.out.mix(Cram2BAM.out)

    //Ricavo le statistiche del file BAM ottenuto da Cram2BAM con Samtools
    SamtoolsStats_BAM(channel_for_stats)

    //Ricavo le statistiche del file BAM ottenuto da Cram2BAM con Mosdepth
    Mosdepth_BAM(Samtools_index.out) 

    //Eseguo MultiQC per ottenere un report generale sui file BAM ottenuti da Bedtools intersect
    Canale_MultiQC = SamtoolsStats_BAM.out.mix(Mosdepth_BAM.out)
                                  .flatten()                   
                                  .collect()
    
    MultiQC(Canale_MultiQC)

    publish:
    first_output = Cram2BAM.out
    second_output = Bedtools_Intersect.out
    third_output = Samtools_index.out.map { _bam, bai -> bai } 
    fourth_output = SamtoolsStats_BAM.out 
    fifth_output = Mosdepth_BAM.out
    sixth_output = MultiQC.out
    seventh_output = BED_Slop_and_Merge.out

}

output {
    first_output {
         path "Cram2BAM"
		 mode 'copy'
    }
    second_output {
         path "Bedtools_Intersect"
		 mode 'copy'
    }
    third_output {
         path "Samtools_index"
		 mode 'copy'
    }
    fourth_output {
         path "SamtoolsStats_BAM"
		 mode 'copy'
    }
    fifth_output {
         path "Mosdepth_BAM"
		 mode 'copy'
    }
     sixth_output {
           path "MultiQC"
		   mode 'copy'
    }
    seventh_output {
          path "BED_Slop_and_Merge"
		  mode 'copy'
    }
}
