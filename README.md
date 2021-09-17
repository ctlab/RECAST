**RECAST (Recipient intestinE Colonisation AnalysiS Tool)** is a tool for analysing metagenome time series and distinguish which reads of one metagenome sample are found in other samples.
The implementation is based on [MetaCherchant](https://github.com/ivartb/metacherchant) source code.

## Table of contents
<!--ts-->
  * [Installation](#installation)
  * [Usage example](#usage-example)
    * [Simple reads classifier](#simple-reads-classifier)
      * [Output](#output-description)
      * [Results visualisation](#results-visualisation)
    * [Accurate reads classifier](#accurate-reads-classifier)
      * [Output](#output-description-1) 
  * [Using k-mers for speed up](#using-k-mers-for-speed-up)
  * [Citation](#citation)
<!--te-->

## Installation

You need to have JRE version 1.8 or higher installed, file `metacherchant.jar` and either of
these two files: `reads_classifier.sh` for two-category classification or `triple_reads_classifier.sh` for three-category classification.

Scripts have been tested under CentOS release 6.7, but should generally work on Linux/MacOS.

## Usage example

Both pipelines were intended to use for analysing human gut microbiota after 
[fecal microbiota transplantation](https://en.wikipedia.org/wiki/Fecal_microbiota_transplant).
Thus it takes three metagenome samples (namely: donor sample, pre-FMT recipient sample, and post-FMT recipient sample)
and split reads from each metagenome into different categories depending on their colonization of the recipient's gut.

However, pipelines can be used for analysing any metagenome time series, but don't be confused with categories names.

### Simple reads classifier

Simple reads classifier uses hard splitting criteria and builds eight categories of reads.

Here is a bash script showing a typical usage of simple reads classifier:

~~~
./reads_classifier.sh -k 31 \
    -d <donor_1.fasta donor_2.fasta> \
    -b <before_1.fasta before_2.fasta> \
    -a <after_1.fasta after_2.fasta> \
    -found 90 \
    -w <workDir> \
    -o <outDir> \
    -corr \
    -m <mem> \
    -p <proc> \
    -interval95 \
    -v \
    -dk <donor.kmers.bin> \
    -bk <before.kmers.bin> \
    -ak <after.kmers.bin>
~~~

* `-k` — the size of k-mer used in de Bruijn graph
* `-d` — two files with paired donor metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2 
* `-b` — two files with paired pre-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2
* `-a` — two files with paired post-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2
* `-found` — Minimum coverage breadth for reads from class found \[0 - 100 %\] (optional, default: 90)
* `-w` — directory with intermediate working files (optional, default: workDir)
* `-o` — directory for final categories of reads (optional, default: outDir)
* `-corr` — do replacement of nucleotide in read with one low quality position (optional)
* `-m` — memory to use (for example: 1500M, 4G, etc.) (optional, default: 2 Gb)
* `-p` — available processors (optional, default: all)
* `-interval95` — set the interval width to probability 0.95 (optional)
* `-v` — enable debug output (optional)
* `-dk` — one file with donor k-mers in binary form (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-bk` — one file with pre-FMT recipient k-mers in binary form (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-ak` — one file with post-FMT recipient k-mers in binary form (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))

#### Output description

After the end of the analysis, the results can be found in the folder specified in `-o` parameter

* Reads from donor metagenome are split into two categories:

  * `settle_[1|2|s].fastq` — reads which were found in post-FMT recipient metagenome

  * `not_settle_[1|2|s].fastq` — reads which were not found in post-FMT recipient metagenome

* Reads from pre-FMT recipient metagenome are split into two categories:

  * `stay_[1|2|s].fastq` — reads which were found in post-FMT recipient metagenome

  * `gone_[1|2|s].fastq` — reads which were not found in post-FMT recipient metagenome

* Reads from post-FMT recipient metagenome are split into four categories:

  * `came_from_both_[1|2|s].fastq` — reads which were found both in donor and pre-FMT recipient metagenome

  * `came_from_donor_[1|2|s].fastq` — reads which were found only in donor metagenome

  * `came_from_baseline_[1|2|s].fastq` — reads which were found only in pre-FMT recipient metagenome

  * `came_itself_[1|2|s].fastq` — reads which were not found neither in donor metagenome nor in pre-FMT recipient metagenome

### Results visualisation

One can get the visual representation of a nucleotide sequence coverage by classified reads in post-FMT de Bruijn graphs in tool [Bandage](https://rrwick.github.io/Bandage/). Run `fmt_visualiser.sh` script as in the example below:

~~~
./fmt_visualiser.sh -k 31 \
    -seq <seq.fasta> \
    -a <after_1.fasta after_2.fasta> \
    -i <inputDir> \
    -w <workDir> \
    -o <outDir> \
    -m <mem> \
    -p <proc> \
    -v
~~~

* `-k` — the size of k-mer used in de Bruijn graph (must be the **same** as in `reads_classifier.sh`)
* `-seq` — file with sequences to visualise in FASTA format
* `-a` — two files with paired post-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2  (must be the **same** as in `reads_classifier.sh`)
* `-i` — directory containing output of `reads_classifier.sh` FMT classification script
* `-w` — directory with intermediate working files (optional, default: workDir)
* `-o` — directory for final visualisation files (optional, default: outDir)
* `-m` — memory to use (for example: 1500M, 4G, etc.) (optional, default: 2 Gb)
* `-p` — available processors (optional, default: all)
* `-v` — enable debug output (optional) 

In the output folder (specified by `-o`) you can find files:

* `*.fasta` — fasta files containing merged nodes for graph of post-FMT recipient around sequences with information about neighbors in description line

* `*.gfa` — files of post-FMT graphs around sequences in [GFA format](https://github.com/GFA-spec/GFA-spec/blob/master/GFA-spec.md) accepted by Bandage as input files. Follow the instructions of Bandage tool to get the colorful visualisation of classification results.

**Post-FMT recipient graphs (`after/*.gfa`)** are colored with five colors:

![](https://via.placeholder.com/15/008000?text=+) green nodes — parts of graph, which classified as `came from both`

![](https://via.placeholder.com/15/ff0000?text=+) red nodes — parts of graph, which classified as `came from donor`

![](https://via.placeholder.com/15/0000ff?text=+) blue nodes — parts of graph, which classified as `came from baseline`

![](https://via.placeholder.com/15/ffff00?text=+) yellow nodes — parts of graph, which classified as `came itself`

![](https://via.placeholder.com/15/999999?text=+) grey nodes — parts of graph, which are covered by multiple categories


### Accurate reads classifier

Accurate reads classifier uses soft splitting criteria providing a user with thirteen categories of reads.
It also utilizes two values of `k` for building de Bruijn graph, which makes an algorithm to be more accurate.

Here is a bash script showing a typical usage of accurate reads classifier:

~~~
./triple_reads_classifier.sh -k 31 \
    -k2 61 \
    -d <donor_1.fasta donor_2.fasta> \
    -b <before_1.fasta before_2.fasta> \
    -a <after_1.fasta after_2.fasta> \
    -found 90 \
    -half 40 \
    -w <workDir> \
    -o <outDir> \
    -corr \
    -m <mem> \
    -p <proc> \
    -interval95 \
    -v \
    -dk1 <donor_k.kmers.bin> \
    -dk2 <donor_k2.kmers.bin>\
    -bk1 <before_k.kmers.bin> \
    -bk2 <before_k2.kmers.bin>\
    -ak1 <after_k.kmers.bin> \
    -ak2 <after_k2.kmers.bin>
~~~

* `-k` — the size of k-mer used in de Bruijn graph
* `-k2` — the second size of k-mer used in de Bruijn graph. k2 > k
* `-d` — two files with paired donor metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2
* `-b` — two files with paired pre-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2
* `-a` — two files with paired post-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2
* `-found` — Minimum coverage breadth for reads from class found \[0 - 100 %\] (optional, default: 90)
* `-half` — Minimum coverage breadth for reads from class half-found \[0 - 100 %\] (optional, default: 40)
* `-w` — directory with intermediate working files (optional, default: workDir)
* `-o` — directory for final categories of reads (optional, default: outDir)
* `-corr` — do replacement of nucleotide in read with one low quality position (optional)
* `-m` — memory to use (for example: 1500M, 4G, etc.) (optional, default: 2 Gb)
* `-p` — available processors (optional, default: all)
* `-interval95` — set the interval width to probability 0.95 (optional)
* `-v` — enable debug output (optional)
* `-dk1` — one file with donor k-mers in binary form with k=**k** (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-dk2` — one file with donor k-mers in binary form with k=**k2** (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-bk1` — one file with pre-FMT recipient k-mers in binary form with k=**k** (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-bk2` — one file with pre-FMT recipient k-mers in binary form with k=**k2** (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-ak1` — one file with post-FMT recipient k-mers in binary form with k=**k** (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))
* `-ak2` — one file with post-FMT recipient k-mers in binary form with k=**k2** (SEE: [Using k-mers for speed up](#using-k-mers-for-speed-up))

#### Output description

After the end of the analysis, the results can be found in the folder specified in `-o` parameter

* Reads from donor metagenome are split into three categories:

  * `settle_[1|2|s].fastq` — reads which were found in post-FMT recipient metagenome

  * `half_settle_[1|2|s].fastq` — reads close to which were found in post-FMT recipient metagenome

  * `not_settle_[1|2|s].fastq` — reads which were not found in post-FMT recipient metagenome

* Reads from pre-FMT recipient metagenome are split into three categories:

  * `stay_[1|2|s].fastq` — reads which were found in post-FMT recipient metagenome

  * `half_stay_[1|2|s].fastq` — reads close to which were found in post-FMT recipient metagenome

  * `gone_[1|2|s].fastq` — reads which were not found in post-FMT recipient metagenome

* Reads from post-FMT recipient metagenome are split into seven categories:

  * `came_from_both_[1|2|s].fastq` — reads which were found both in donor and pre-FMT recipient metagenome

  * `came_from_donor_[1|2|s].fastq` — reads which were found only in donor metagenome

  * `came_from_baseline_[1|2|s].fastq` — reads which were found only in pre-FMT recipient metagenome

  * `came_itself_[1|2|s].fastq` — reads which were not found neither in donor metagenome nor in pre-FMT recipient metagenome

  * `strain_from_donor_[1|2|s].fastq` — reads which were found in donor metagenome and close to which were found in pre-FMT recipient metagenome

  * `strain_from_baseline_[1|2|s].fastq` — reads which were found in pre-FMT recipient metagenome and close to which were found in donor metagenome

  * `strain_itself_[1|2|s].fastq` — reads close to which were found both in donor and pre-FMT recipient metagenome


## Using k-mers for speed-up

De Bruijn graphs of k-mers extracted from input reads are utilised multiple times during execution. Thus, it is highly recommended to extract k-mers from reads at preprocession stage and provide files with extracted k-mers in binary format as input parameters. One should use `kmer-counter` tool from `metacherchant.jar` to perform this action.

Here is a command showing usage of the tool:

~~~
java -jar metacherchant.jar -t kmer-counter \
    -k 31 \
    -i <reads_1.fasta reads_2.fasta> \
    -w <workDir> \
    -o <outDir> \
    -m <mem> \
    -p <proc> \
    -v
~~~

* `-k` — the size of k-mer to extract from reads
* `-i` — two files with paired metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2 
* `-w` — directory with intermediate working files (optional, default: workDir)
* `-o` — directory for final categories of reads (optional, default: outDir)
* `-m` — memory to use (for example: 1500M, 4G, etc.) (optional, default: 2 Gb)
* `-p` — available processors (optional, default: all)
* `-v` — enable debug output (optional)


## Citation

If you use RECAST in your research, please cite the following publication:

Olekhnovich, E. I., Ivanov, A. B., Ulyantsev, V. I., & Ilina, E. N. (2021). Separation of Donor and Recipient Microbial Diversity Allows Determination of Taxonomic and Functional Features of Gut Microbiota Restructuring following Fecal Transplantation. Msystems, 6(4), e00811-21. [https://doi.org/10.1128/mSystems.00811-21](https://doi.org/10.1128/mSystems.00811-21)
