The purpose of these tools is to analyse metagenome time series by searching the common parts from one metagenome into another.
The implementation is based on [MetaCherchant](https://github.com/ivartb/metacherchant) source code.

## Installation

You need to have JRE version 1.8 or higher installed, file `metacherchant.jar` and either of
these two files: `reads_classifier.sh` for two-category classification or `triple_reads_classifier.sh` for three-category classification.

Scripts have been tested under CentOS release 6.7, but should generally work on Linux/MacOS.

## Usage example

Both pipelines were intended to use for analysing human gut microbiota after 
[fecal microbiota transplantation](https://en.wikipedia.org/wiki/Fecal_microbiota_transplant).
Thus it takes three metagenome samples (namely: donor sample, pre-FMT recipient sample, and post-FMT recipient sample)
and split reads from each metagenome on different categories depending on their colonization the recipient's gut.

However, pipelines can be used for analysing any metagenome time series, but don't be confused with categories names.

### Simple reads classifier

Simple reads classifier uses hard splitting criteria and builds eight categories of reads.

Here is a bash script showing a typical usage of simple reads classifier:

~~~
./reads_classifier.sh -k 31 \
    -d <donor_1.fasta donor_2.fasta> \
    -b <before_1.fasta before_2.fasta> \
    -a <after_1.fasta after_2.fasta> \
    -w <workDir> \
    -o <outDir>
~~~

* `-k` --- the size of k-mer used in de Bruijn graph.
* `-d` --- two files with paired donor metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2.
* `-b` --- two files with paired pre-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2.
* `-a` --- two files with paired post-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2.
* `-w` --- directory with intermediate working files
* `-o` --- directory for final categories of reads

#### Output description

After the end of the analysis, the results can be found in the folder specified in `-o` parameter

* Reads from donor metagenome are split into two categories:

  * `settle_[1|2|s].fastq` --- reads which were found in post-FMT recipient metagenome

  * `not_settle_[1|2|s].fastq` --- reads which were not found in post-FMT recipient metagenome

* Reads from pre-FMT recipient metagenome are split into two categories:

  * `stay_[1|2|s].fastq` --- reads which were found in post-FMT recipient metagenome

  * `gone_[1|2|s].fastq` --- reads which were not found in post-FMT recipient metagenome

* Reads from post-FMT recipient metagenome are split into four categories:

  * `came_from_both[1|2|s].fastq` --- reads which were found both in donor and pre-FMT recipient metagenome

  * `came_from_donor[1|2|s].fastq` --- reads which were found only in donor metagenome

  * `came_from_before_[1|2|s].fastq` --- reads which were found only in pre-FMT recipient metagenome

  * `came_itself_[1|2|s].fastq` --- reads which were not found neither in donor metagenome nor in pre-FMT recipient metagenome


### Careful reads classifier

Careful reads classifier uses soft splitting criteria providing a user with thirteen categories of reads.
It also utilizes two values of `k` for building de Bruijn graph, which makes an algorithm be more accurate.

Here is a bash script showing a typical usage of careful reads classifier:

~~~
./triple_reads_classifier.sh -k 31 \
    -k2 61 \
    -d <donor_1.fasta donor_2.fasta> \
    -b <before_1.fasta before_2.fasta> \
    -a <after_1.fasta after_2.fasta> \
    -w <workDir> \
    -o <outDir>
~~~

* `-k` --- the size of k-mer used in de Bruijn graph.
* `-k2` --- the second size of k-mer used in de Bruijn graph. k2 > k
* `-d` --- two files with paired donor metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2.
* `-b` --- two files with paired pre-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2.
* `-a` --- two files with paired post-FMT recipient metagenomic reads. FASTA and FASTQ formats are supported, as well as compressed files *.gz or *.bz2.
* `-w` --- directory with intermediate working files
* `-o` --- directory for final categories of reads

#### Output description

After the end of the analysis, the results can be found in the folder specified in `-o` parameter

* Reads from donor metagenome are split into three categories:

  * `settle_[1|2|s].fastq` --- reads which were found in post-FMT recipient metagenome

  * `half_settle_[1|2|s].fastq` --- reads close to which were found in post-FMT recipient metagenome

  * `not_settle_[1|2|s].fastq` --- reads which were not found in post-FMT recipient metagenome

* Reads from pre-FMT recipient metagenome are split into three categories:

  * `stay_[1|2|s].fastq` --- reads which were found in post-FMT recipient metagenome

  * `half_stay_[1|2|s].fastq` --- reads close to which were found in post-FMT recipient metagenome

  * `gone_[1|2|s].fastq` --- reads which were not found in post-FMT recipient metagenome

* Reads from post-FMT recipient metagenome are split into seven categories:

  * `came_from_both[1|2|s].fastq` --- reads which were found both in donor and pre-FMT recipient metagenome

  * `came_from_donor[1|2|s].fastq` --- reads which were found only in donor metagenome

  * `came_from_before_[1|2|s].fastq` --- reads which were found only in pre-FMT recipient metagenome

  * `came_itself_[1|2|s].fastq` --- reads which were not found neither in donor metagenome nor in pre-FMT recipient metagenome

  * `strain_from_donor[1|2|s].fastq` --- reads which were found in donor metagenome and close to which were found in pre-FMT recipient metagenome

  * `strain_from_before_[1|2|s].fastq` --- reads which were found in pre-FMT recipient metagenome and close to which were found in donor metagenome

  * `strain_itself_[1|2|s].fastq` --- reads close to which were found both in donor and pre-FMT recipient metagenome
