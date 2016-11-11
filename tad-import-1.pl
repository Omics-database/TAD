#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use DBI;
use CC::Create;
use CC::Parse;

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-10-28 14:40:00 (Fri, 28 Oct 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------

our ($verbose, $help, $man);
our ($metadata, $tab, $excel, $datadb, $gene, $variant, $all, $vep, $annovar);
our ($file2consider,$connect);
my ($sth,$dbh,$schema); #connect to database;
our (%specimen, %filecontent, %description, %organism);
our (%Mapresults, %Sampleresults);
my ($name, $description, $derivedfrom, $organism, $tissue, $collection, $scientist, $organization);

#--------------------------------------------------------------------------------

sub printerr; #declare error routine
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details

#PROCESSING METADATA
if ($metadata){
  $dbh = mysql($all_details{"MySQL-databasename"}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
  if ($tab) { #unix tab delimited file
    $verbose and printerr "Job: Importing Sample Information from tab-delimited file => $file2consider\n"; #status
    %filecontent = %{ tabcontent($file2consider) }; #get content from tab-delimited file
    foreach my $row (sort keys %filecontent){
      SampleCheck();  #check to avoid duplicate entry
      if (exists $filecontent{$row}{'sample name'}) { #sample name
	$name = $filecontent{$row}{'sample name'};
      } else {
	pod2usage("Warning: Error in tab-delimited file \"$file2consider\".\n\tCheck => ROW: $row, COLUMN: \"Sample Name\"");
      } #end if for getting sample information 
      unless (exists $Sampleresults{$name}) { #if sample isn't in the database
	$scientist = $filecontent{$row}{'scientist'};  #scientist
	$organization = $filecontent{$row}{'organization name'}; #organization name
		
	if (exists $filecontent{$row}{'organism'}) { #organism
 	  $organism = $filecontent{$row}{'organism'};
	} else {
	  die "\nWarning: Error in tab-delimited file \"$file2consider\".\n\tCheck => ROW: $row, COLUMN: \"Organism\"\n";
	} #end if for animal info
	$description = $filecontent{$row}{'sample description'}; #description
	if (exists $filecontent{$row}{'derived from'}) { #animal
	  $derivedfrom = uc($filecontent{$row}{'derived from'});
	} else {
	  die "\nWarning: Error in tab-delimited file \"$file2consider\".\n\tCheck => ROW: $row, COLUMN: \"Derived From\"\n";
	} #end if for animal id
	unless (exists $filecontent{$row}{'organism part'}) { #tissue
	  $tissue = $filecontent{$row}{'organism part'};
	} else {
	  $tissue = $filecontent{$row}{'sample description'};
	} #end if for tissue
	if (exists $filecontent{$row}{'specimen collection date'}){
	  $collection =$filecontent{$row}{'specimen collection date'};
	my @date = split('-', $collection);
	if ($#date == 0) {$collection = $date[0]."0101";}
	elsif ($#date == 1) { $collection = $date[0].$date[1]."01";}
	elsif ($#date == 2) { $collection = $date[0].$date[1].$date[2];}
	else {$collection = undef;}
	} else {
	  $collection = undef;
	} #end id for specimen collection date
	$sth = $dbh->prepare("insert into Sample (sampleid, sampleinfo, derivedfrom, organism, tissue, collectiondate, scientist, organizationname) values (?,?,?,?,?,?,?,?)");
	$sth->execute($name, $description,$derivedfrom,$organism, $tissue, $collection, $scientist, $organization);
	$verbose and printerr "Inserted:\t$name\n"; #import to database
	$sth-> finish; #end of query
      } else {
        $verbose and printerr "Duplicate (Already exists):\t$name\n"; #import to database
      } #end unless in the database
    } #end foreach filecontent
  } #end if (tab-delimited)
  
  else { #import faang excel sheet
    $verbose and printerr "Job: Importing Sample Information from excel file => $file2consider\n"; #status    
    %filecontent = %{ excelcontent($file2consider) }; #get excel content
    #get name information
    if (exists $filecontent{2}{'person%person first name'}){
      $scientist = "$filecontent{2}{'person%person first name'} $filecontent{2}{'person%person initials'} $filecontent{2}{'person%person last name'}";
    } else {$scientist = undef;} #end if for scientist
    if (exists $filecontent{2}{'organization%organization name'}){
      $organization = $filecontent{2}{'organization%organization name'};
    } else {$organization = undef;} #end if for organization name
    #get specimen information
    foreach my $row (sort keys %filecontent){
      foreach my $column (keys %{$filecontent{$row}}){
	if ($column =~ /^specimen.*/){
  	  $specimen{$row}{$column} = $filecontent{$row}{$column};
	} #end if for getting sample information
      } #end foreach
    } #end foreach
		
    #get animal information
    foreach my $row (sort keys %filecontent){
      foreach my $column (keys %{$filecontent{$row}}){
        if ($column =~ /^animal%sample name/){
	  $description{uc($filecontent{$row}{'animal%sample name'})}= $filecontent{$row}{'animal%sample description'};
	  if (exists $filecontent{$row}{'animal%organism'}) {
	    $organism{uc($filecontent{$row}{'animal%sample name'})}= $filecontent{$row}{'animal%organism'};
	  } else {
	    die "\nWarning: Error in Excel file \"$file2consider\".\n\tCheck => SHEET: animal, ROW: $row, COLUMN: \"Organism\"\n";
	  } #end if for animal information
	} #end if for animal id
      } #end foreach
    } #end foreach
		
    #attributes of interest
    foreach my $row  (sort keys %specimen){
      SampleCheck(); #check to avoid duplicate entry
      if (exists $filecontent{$row}{'specimen%sample name'}) {
	$name = $filecontent{$row}{'specimen%sample name'};
      } else {
	die "\nWarning: Error in Excel file \"$file2consider\".\n\tCheck => SHEET: specimen, ROW: $row, COLUMN: \"Sample Name\"\n";
      } #end if to get sampleid
      unless (exists $Sampleresults{$name}) { #if sample isn't in the database
	if (exists $filecontent{$row}{'specimen%derived from'}) {
  	  $derivedfrom = uc($filecontent{$row}{'specimen%derived from'});
	} else {
	  die "\nWarning: Error in Excel file \"$file2consider\".\n\tCheck => SHEET: specimen, ROW: $row, COLUMN: \"Derived From\"\n";
	} #end if for animal id
	unless (exists $filecontent{$row}{'specimen%organism part'}) {
	  $tissue = $filecontent{$row}{'specimen%organism part'};
	} else {
	  $tissue = $filecontent{$row}{'specimen%sample description'};
	} #end if for tissue 
	if (exists $filecontent{$row}{'specimen%specimen collection date'}){
	  $collection =$filecontent{$row}{'specimen%specimen collection date'};
	  my @date = split('-', $collection);
	  if ($#date == 0) {$collection = $date[0]."0101";}
	  elsif ($#date == 1) { $collection = $date[0].$date[1]."01";}
	  elsif ($#date == 2) { $collection = $date[0].$date[1].$date[2];}
	  else {$collection = undef;}
	} else {
	  $collection = undef;
	} #end if for specimen collection date
	$sth = $dbh->prepare("insert into Sample (sampleid, sampleinfo, derivedfrom, organism, tissue, collectiondate, scientist, organizationname) values (?,?,?,?,?,?,?,?)");
	unless (exists $organism{$derivedfrom}) {
	  die "\nWarning: Error in Excel file \"$file2consider\".\n\tAnimal \"$derivedfrom\" information is not provided in SHEET: animal\n";
	} #check to make sure animal information from specimen sheet is provided
	$sth->execute($name, $description{$derivedfrom},$derivedfrom,$organism{$derivedfrom}, $tissue, $collection, $scientist, $organization);
	$verbose and printerr "Inserted:\t$name\n"; #import to database
        $sth-> finish; #end of query
      } else {
        $verbose and printerr "Duplicate (Already exists):\t$name\n"; #import to database
      } #end unless in the database
    } #end foreach specimen; attribute of interest
  } #end if excel
  $dbh-> disconnect;
} #end if metadata

#PROCESSING DATA IMPORT
if ($datadb) {
print "not this script\t working version\n"; exit;
}
#output: the end
if ($metadata){
  printerr ("Success: Import of Sample Information in \"$file2consider\"\n");
  print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n\n";
}
if ($datadb){
  printerr ("Success: Import of RNA Seq analysis information in \"$file2consider\"\n");
  print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n\n";
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
close (LOG);
#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man, 'metadata'=>\$metadata,
	'data2db'=>\$datadb, 'gene'=>\$gene, 'variant'=>\$variant, 'all'=>\$all, 'vep'=>\$vep,
	'annovar'=>\$annovar, 't|tab'=>\$tab, 'x|excel'=>\$excel ) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  
  pod2usage(-msg=>"Error: Invalid syntax specified, choose -metadata or -data2db") unless ( $metadata || $datadb);
  pod2usage(-msg=>"Error: Invalid syntax specified @ARGV.") if (($metadata && $datadb)||($vep && $annovar) || ($gene && $vep) || ($gene && $annovar) || ($gene && $variant));
  
  @ARGV==1 or pod2usage("Syntax error");
  $file2consider = $ARGV[0];

  $verbose ||=0;
  my $get = dirname(abs_path $0); #get source path
  $connect = $get.'/.connect.txt';
  #setup log file
  my $errfile = open_unique("db.tad_status.log"); 
  open(LOG, ">>", @$errfile[1]) or die "Error: cannot write LOG information to log file @$errfile[1] $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";
}


sub printerr {
  print STDERR @_;
  print LOG @_;
}

sub SampleCheck {
  #CHECKING THE LIBRARIES ALREADY IN THE DATABASE
  my $syntax = "select sampleid , date from MapStats";
  $sth = $dbh->prepare($syntax);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  while (my ($row1,$row2) = $sth->fetchrow_array() ) {
    $Mapresults{$row1} = $row2;
  }
  $syntax = "select sampleid from Sample";
  $sth = $dbh->prepare($syntax);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  my $number = 0;
  while (my $row = $sth->fetchrow_array() ) {
    $Sampleresults{$row} = $number; $number++;
  }
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


        Arguments to control metadata import
	    -x, --excel         metadata will import the faang excel file provided (default)
      -t, --tab         	metadata will import the tab-delimited file provided
	     


	Arguments to control data2db import
            --gene     		data2db will import only the alignment file [TopHat2] and expression profiling files [Cufflinks] (default)
            --variant           data2db will import only the alignment file [TopHat2] and variant analysis files [.vcf]
            --all          	data2db will import all data files specified


        Arguments to fine-tune variant import procedure
            --vep		import ensembl vep variant annotation file [tab-delimited format] [suffix: .vep.txt] (in variant operation)
	    --annovar		import annovar variant annotation file [suffix: .multianno.txt] (in variant operation)


  Function: import data files into the database
 
  Example: #import metadata files
 	   tad-import.pl -metadata -v -t example/metadata/TEMPLATE/metadata_GGA_UD.txt
	   tad-import.pl -metadata -x -v example/metadata/FAANG/FAANG_GGA_UD.xlsx
 	   
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

import metadata file provided.
Metadata files accepted is either a tab-delmited (suffix: '.txt') file 
or FAANG biosamples excel (suffix: '.xls') file

=item B<--tab>

specify the file provided is in tab-delimited format (suffix: '.txt'). (default)

=item B<--excel>

specify the file provided is an excel spreadsheet (suffix: '.xls'/'.xlsx')

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


