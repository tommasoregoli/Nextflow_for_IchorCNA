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
    //Program creates the channel that takes the CRAM files as input from the samples.csv file
    Canale = channel.fromPath(params.CRAM)
                    .splitCsv()
    
    //Convert CRAM file to BAM file
    Cram2BAM(Canale, params.reference, params.reference_index)
    
    //The program runs Bedtools slop and merge on the BED file only if parameter --BED_Slop_and_Merge is setted as true in the nextflow command
	if (params.BED_Slop_and_Merge) {
		BED_Slop_and_Merge(params.reference_index, params.bed, params.slop)

		Bedtools_Intersect(Cram2BAM.out, BED_Slop_and_Merge.out)
	}
	else {
    	//Program runs Bedtools intersect with default bed file in nextflow.config
   		Bedtools_Intersect(Cram2BAM.out, params.bed)
	}

    channel_for_indexing = Bedtools_Intersect.out.mix(Cram2BAM.out)

    //The program indexes the BAM file obtained from Bedtools intersect
    Samtools_index(channel_for_indexing)

    channel_for_stats = Bedtools_Intersect.out.mix(Cram2BAM.out)

    //The program evaluates the statistics of the BAM file obtained from Cram2BAM using Samtools
    SamtoolsStats_BAM(channel_for_stats)

    //The program evaluates the statistics of the BAM file obtained from Cram2BAM using Mosdepth
    Mosdepth_BAM(Samtools_index.out) 

    //The program runs MultiQC to generate a summary report on the normal and off-target BAM files 
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
