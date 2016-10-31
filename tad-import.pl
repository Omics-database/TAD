#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use DBI;
use CC::Create;

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-10-28 14:40:00 (Fri, 28 Oct 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------

our ($verbose, $help, $man);
our ($metadata, $datadb, $gene, $variant, $all, $vep, $annovar);
our ($file2consider,$connect);
my ($sth,$dbh,$schema); #connect to database;

#--------------------------------------------------------------------------------

sub printerr; #declare error routine
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details

$dbh = mysql($all_details{"MySQL-databasename"}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql

if ($metadata){
  my $metafile = $file2consider;
  open (META, $metafile) or pod2usage("Error: Can not open metadata file \"$metafile\" for reading");
  
  close (META);
} 
 
if ($datadb) {
  my $datafolder = $file2consider;
  opendir (DATA, $datafolder); close (DATA);
}

#Import schema to mysql
# open (SQL, $sqlfile) or die "Error: Can't open file \"$sqlfile\" for reading";
# while (my $sqlStatement = <SQL>) {
#   $sth = $dbh->prepare($sqlStatement)
#      or die (qq(Error: Can't prepare $sqlStatement));

#   $sth->execute()
#      or die qq(Error: Can't execute $sqlStatement);
#   $verbose and printerr "Executed:\t$sqlStatement\n";
# }

#create FastBit path on connection details
# our $ffastbit = fastbit($all_details{"FastBit-path"},$all_details{"FastBit-foldername"});


#printerr ("Success: Creation of MySQL database ==> \"".$all_details{"MySQL-databasename"}."\"\n");
#printerr ("Success: Creation of FastBit folder ==> \"".$ffastbit."\"\n");

#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man, 'metadata'=>\$metadata,
	'data2db'=>\$datadb, 'gene'=>\$gene, 'variant'=>\$variant, 'all'=>\$all, 'vep'=>\$vep,
	'annovar'=>\$annovar ) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  
  pod2usage(-msg=>"Error: Invalid syntax specified @ARGV.") if (($metadata && $datadb)||($vep && $annovar) || ($gene && $vep) || ($gene && $annovar) || ($gene && $variant));
  pod2usage(-msg=>"Select an option.") if (!$metadata || !$datadb);

  @ARGV==1 or pod2usage("Syntax error");
  $file2consider = $ARGV[0];

  $verbose ||=0;
  my $get = dirname(abs_path $0); #get source path
  $connect = $get.'/.connect.txt';
  #setup log file
  my $errfile = "transatlasdb_import.log";
  open(LOG, ">>$errfile") or die "Error: cannot write LOG information to log file $errfile $!\n";
  print LOG "TransAtlasDB Version:\n\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\n\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\n\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\n\t", scalar(localtime),"\n";
}


sub printerr {
  print STDERR @_;
  print LOG @_;
}

#--------------------------------------------------------------------------------

=head1 SYNOPSIS

  tad-import.pl [arguments] <metadata-file|sample-location>

  Optional arguments:
	-h, --help		print help message
  	-m, --man		print complete documentation
  	-v, --verbose		use verbose output


        Arguments to import metadata or sample analysis
            --metadata          import metadata file provided
            --data2db		import data files from gene expression profiling and/or variant analysis (default: --gene)


        Arguments to control data2db import
            --gene     		data2db will import only the alignment file [TopHat2] and expression profiling files [Cufflinks] (default)
            --variant           data2db will import only the alignment file [TopHat2] and variant analysis files [.vcf]
            --all          	data2db will import all data files specified


        Arguments to fine-tune variant import procedure
            --vep		import ensembl vep variant annotation file [tab-delimited format] [suffix: .vep.txt] (in variant operation)
	    --annovar		import annovar variant annotation file [suffix: .multianno.txt] (in variant operation)


  Function: import data files into the database
 
  Example: #import metadata files
 	   tad-import.pl -metadata example/metadata/metadata-01.txt
	   tad-import.pl -metadata example/metadata/BioSample-01.xls -v
 	   
  	   #import transcriptome analysis data files
 	   tad-import.pl -data2db example/MMU_UD_23/
	   tad-import.pl -data2db -all -vep example/GGA_UD_1000/
	   tad-import.pl -data2db -variant -annovar example/GGA_UD_1001/


  Version: $Date: 2016-10-28 15:50:08 (Fri, 28 Oct 2016) $

=head1 OPTIONS

=over 8

=item B<--help>

print a brief usage message and detailed explantion of options.

=item B<--man>

print the complete manual of the program.

=item B<--verbose>

use verbose output.

=item B<--metadata>

import metadata file provided in the tab-delimited format 
using the template provided or the BioSamples.xls template

=item B<--data2db>

import data files from gene expression profiling analysis 
derived from using TopHat2 and Cufflinks. Optionally 
import variant file (see: variant file format) and 
variant annotation file from annovar or vep.

=item B<--gene>

specify only expression files will be imported. (default)

=item B<--variant>

specify only variant files will be imported.

=item B<--all>

specify both expression and variant files will be imported.

=item B<--vep>

specify annotation file provided was generated using Ensembl Variant Effect Predictor (VEP).

=item B<--annovar>

specify annotation file provided was predicted using ANNOVAR.

=back

=head1 DESCRIPTION

TransAtlasDB is a database management system for organization of gene expression
profiling from numerous amounts of RNAseq data.

TransAtlasDB toolkit comprises of a suite of Perl script for easy archival and 
retrival of transcriptome profiling and genetic variants.

TransAtlasDB requires all analysis be stored in a single folder location for 
successful processing.

Detailed documentation for TransAtlasDB should be viewed on github.

=over 8 

=item * B<directory/folder structure>
A sample directory structure contains file output from TopHat2 software, 
Cufflinks software, variant file from any bioinformatics variant analysis package
such as GATK, SAMtools, and (optional) variant annotation results from ANNOVAR 
or Ensembl VEP in tab-delimited format having suffix '.multianno.txt' and '.vep.txt' 
respectively. An example is shown below:

	/sample_name/
	/sample_name/tophat_folder/
	/sample_name/tophat_folder/accepted_hits.bam
	/sample_name/tophat_folder/align_summary.txt
	/sample_name/tophat_folder/deletions.bed
	/sample_name/tophat_folder/insertions.bed
	/sample_name/tophat_folder/junctions.bed
	/sample_name/tophat_folder/prep_reads.info
	/sample_name/tophat_folder/unmapped.bam
	/sample_name/cufflinks_folder/
        /sample_name/cufflinks_folder/genes.fpkm_tracking
        /sample_name/cufflinks_folder/isoforms.fpkm_tracking
        /sample_name/cufflinks_folder/skipped.gtf
        /sample_name/cufflinks_folder/transcripts.gtf
        /sample_name/variant_folder/
        /sample_name/variant_folder/<filename>.vcf
        /sample_name/variant_folder/<filename>.multianno.txt
        /sample_name/variant_folder/<filename>.vep.txt

=item * B<variant file format>

A sample variant file contains one variant per line, with the fields being chr,
start, end, reference allele, observed allele, other information. The other
information can be anything (for example, it may contain sample identifiers for
the corresponding variant.) An example is shown below:

        16      49303427        49303427        C       T       rs2066844       R702W (NOD2)
        16      49314041        49314041        G       C       rs2066845       G908R (NOD2)
        16      49321279        49321279        -       C       rs2066847       c.3016_3017insC (NOD2)
        16      49290897        49290897        C       T       rs9999999       intronic (NOD2)
        16      49288500        49288500        A       T       rs8888888       intergenic (NOD2)
        16      49288552        49288552        T       -       rs7777777       UTR5 (NOD2)
        18      56190256        56190256        C       T       rs2229616       V103I (MC4R)

=item * B<invalid input>

If any of the files input contain invalid arguments or format, TransAtlas 
will terminate the program and the invalid input with the outputted. 
Users should manually examine this file and identify sources of error.

=back


--------------------------------------------------------------------------------

TransAtlasDB is free for academic, personal and non-profit use.

For questions or comments, please contact $ Author: Modupe Adetunji <amodupe@udel.edu> $.

=cut


