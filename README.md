# Nextflow_for_IchorCNA
Nextflow Pipeline per Analisi Off-Target e QC (IchorCNA Prep)

Questa pipeline basata su Nextflow è progettata per processare file CRAM, convertirli in BAM, estrarre le *reads* off-target rispetto a un file BED di riferimento (utilizzando `bedtools`) ed eseguire un controllo qualità completo (QC) tramite `samtools`, `mosdepth` e `MultiQC`.

La pipeline include una funzionalità opzionale per allargare (slop) e unire (merge) dinamicamente le regioni del file BED prima dell'intersezione.

---

## 📦 Prerequisiti

Per eseguire la pipeline sul tuo sistema, assicurati di avere:

* **Nextflow** (versione aggiornata, che supporti la sintassi `output {}` e il resource limits)
* **Docker** o un gestore di ambienti (come Conda). La pipeline è configurata di default con `docker.enabled = true` e `wave.enabled = true`.

---

## 🚀 Utilizzo Rapido

Esecuzione standard (utilizzando il file BED di default così com'è):

```bash
nextflow run main.nf \
  -c risorse_pc.config \
  --CRAM ./samples.csv \
  --bed /path/to/regions.bed \
  --reference /path/to/ref.fasta \
  --reference_index /path/to/ref.fasta.fai 

```

**Esecuzione con Allargamento del BED (Slop & Merge):**
Se desideri allargare le regioni del file BED prima dell'intersezione, devi attivare il modulo condizionale e specificare il numero di paia di basi (bp):

```bash
nextflow run main.nf \
  -c risorse_pc.config \
  --BED_Slop_and_Merge true \
  --slop 100 \
  --CRAM ./samples.csv \
  --bed /path/to/regions.bed \
  --reference /path/to/ref.fasta \
  --reference_index /path/to/ref.fasta.fai 

```
---

## ⚙️ Parametri della Pipeline

Tutti i parametri possono essere modificati nel file `nextflow.config` o passati da riga di comando con il prefisso `--`.

| Parametro | Descrizione | Valore di Default |
| --- | --- | --- |
| `outdir` | Cartella in cui verranno salvati i risultati finali. | `./results` |
| `publish_dir_mode` | Metodo di pubblicazione dei file di output (es. `copy`, `symlink`). | `copy` |
| `CRAM` | File CSV contenente i percorsi dei file CRAM di input. | `./samples.csv` |
| `bed` | Percorso del file BED di riferimento per l'intersezione. | `PATH/of/your/BED/file` |
| `reference` | Genoma di riferimento in formato FASTA. | `PATH/of/your/reference/...` |
| `reference_index` | Indice del genoma di riferimento (`.fai`). | `PATH/of/your/reference/index` |
| `BED_Slop_and_Merge` | **Flag booleano**. Se impostato a `true`, esegue il modulo di slop/merge sul file BED prima dell'intersezione. | `false` |
| `slop` | Numero di basi (bp) per allargare le regioni del BED. Viene usato solo se `BED_Slop_and_Merge` è `true`. | `0` |

---


## 🧩 Moduli della Pipeline

La pipeline è modulare e utilizza i seguenti processi:

* **`Cram2BAM`**: Converte i file in input dal formato CRAM al formato BAM utilizzando `samtools view`.
* **`BED_Slop_and_Merge` (*Opzionale*)**: Viene eseguito solo se esplicitamente richiesto. Utilizza il reference_index per trovare le dimensioni dei cromosomi del genoma di riferimento indicato, prende il file BED in input, ne allarga i confini usando `bedtools slop` in base al parametro `--slop` e unisce le regioni sovrapposte con `bedtools merge`.
* **`Bedtools_Intersect`**: Identifica e trattiene solo le reads off-target (parametro `-v`). Interseca i file BAM generati con il file BED originale o, se attivato, con il file BED modificato dallo step precedente.
* **`Samtools_index`**: Genera l'indice (`.bai`) sia per i BAM completi che per quelli risultanti dall'intersezione.
* **`SamtoolsStats_BAM`**: Genera le statistiche generali e i flag (mappate, non mappate, duplicati) tramite `samtools stats` e `samtools flagstat`.
* **`Mosdepth_BAM`**: Calcola la profondità di copertura (depth) in modo ultra-veloce partendo dai BAM indicizzati.
* **`MultiQC`**: Raccoglie tutti i log e le statistiche generati nei passaggi precedenti (Samtools e Mosdepth) compilandoli in un unico report interattivo HTML.

---

## 💻 Risorse e Configurazione Hardware

La pipeline è configurata con limiti di risorse di sicurezza per evitare di saturare i cluster o il PC locale.

Nel file `nextflow.config` è possibile gestire i profili hardware:

* **Default Process**: Ogni job richiede 6 CPU e 4 GB di RAM.
* **Resource Limits**: Nessun job supererà mai le 12 CPU, 24 GB di RAM o 96 ore di tempo, proteggendo il sistema da crash dovuti a processi fuori controllo.

Leggere il file nextflow.config per crearsi un proprio risorse_pc.config da richiamare al momento dell'esecuzione della pipeline

---

## 📁 Struttura dell'Output

I risultati finali saranno organizzati nella directory specificata da `--outdir` secondo il blocco `output` integrato (feature DSL2 moderna). Troverai i file raggruppati nelle seguenti sottocartelle:

* `Cram2BAM/` : File `.bam` completi convertiti.
* `Bedtools_Intersect/` : File `.bam` off-target generati dall'intersezione.
* `Samtools_index/` : Indici `.bai` associati ai BAM.
* `SamtoolsStats_BAM/` : File di testo con log `.stats` e `.flagstat`.
* `Mosdepth_BAM/` : Distribuzioni e riepiloghi globali prodotti da mosdepth.
* `MultiQC/` : Report HTML unificato pronto da visualizzare nel browser.
