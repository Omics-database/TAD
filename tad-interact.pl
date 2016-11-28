#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use CC::Create;
use CC::Parse;
use Term::ANSIColor;

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-11-17 17:38:00 (Thu, 17 Nov 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------
our ($connect, $efile, $help, $man, $nosql);
our (%MAINMENU, $verdict);
my $choice = 0;
my ($dbh, $sth, $fastbit);
#date
my $date = `date +%Y-%m-%d`;
my ($opa, $opb, $opc, $opd,$ope, $opf, $opg, $opj);
#--------------------------------------------------------------------------------
OPTIONS();
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details
print "\tWELCOME TO TRANSATLASDB INTERACTIVE MODULE\n";
MAINMENU:
while ($choice < 1){
	$verdict = undef;
	$verdict = "a" if ($opa); undef $opa; #process command line options
	$verdict = "b" if ($opb); undef $opb;
	$verdict = "c" if ($opc); undef $opc;
	$verdict = "d" if ($opd); undef $opd;
	$verdict = "e" if ($ope); undef $ope;
	$verdict = "f" if ($opf); undef $opf;
	$verdict = "g" if ($opg); undef $opg;
	$verdict = "h" if ($opj); undef $opj;
	
	unless ($verdict) {
	print color ('bold');
	print "\n--------------------------------MAIN  MENU--------------------------------\n";
	print "--------------------------------------------------------------------------\n";
	print color('reset');
	print "Choose from the following options : \n";
	foreach (sort {$a cmp $b} keys %MAINMENU) { print "  ", uc($_),"\.  $MAINMENU{$_}\n";}
	print color('bold');
	print "--------------------------------------------------------------------------\n";
	print "--------------------------------------------------------------------------\n";
	print color('reset');
	print "\nSelect an option : ";
	chomp ($verdict = lc (<>)); print "\n";
	}
	if ($verdict =~ /^[a-h]/){
		if ($verdict =~ /^exit/) { $choice = 1; next; }
		$choice = 0;
		$dbh = mysql($all_details{'MySQL-databasename'}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
		$fastbit = fastbit($all_details{'FastBit-path'}, $all_details{'FastBit-foldername'});  #connect to fastbit
		SUMMARY($dbh, $efile) if $verdict =~ /^a/;
		METADATA($dbh, $efile) if $verdict =~ /^b/;
		TRANSCRIPT($dbh,$efile) if $verdict =~ /^c/;
		AVERAGE($dbh,$efile) if $verdict =~ /^d/;
		GENEXP($dbh,$efile) if $verdict =~ /^e/;
		CHRVAR($dbh,$efile) if $verdict =~ /^f/;
		VARANNO($dbh,$fastbit,$efile,$nosql) if $verdict =~ /^g/;
		CHRANNO($dbh,$fastbit,$efile,$nosql) if $verdict =~ /^h/;
	} elsif ($verdict =~ /^x/) {
		$choice = 1;
	} elsif ($verdict =~ /^q/) {
		$choice = 1;
	} elsif ($verdict) {
		printerr "ERROR:\t Invalid Option\n";
	} else {
		printerr "NOTICE:\t No Option selected\n";
	}
}
`rm -rf $nosql`;
#output: the end
printerr "-----------------------------------------------------------------\n";
printerr ("SUCCESS: Clean exit from TransAtlasDB interaction module\n");
printerr ("NOTICE:\t Summary in log file $efile\n");
printerr "-----------------------------------------------------------------\n";
print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n";
close (LOG);
`rm -rf $nosql`;

#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('help|h'=>\$help, 'man|m'=>\$man, 'a|summary'=>\$opa,'b|metadata'=>\$opb,
						 'c|transummary'=>\$opc, 'd|avgfpkm'=>\$opd, 'e|genexp'=>\$ope,'f|chrvar'=>\$opf,
						 'g|varanno'=>\$opg, 'j|chranno'=>\$opj) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  
  @ARGV==0 or pod2usage("Syntax error");

	#process command line options

  my $get = dirname(abs_path $0); #get source path
  $connect = $get.'/.connect.txt';
  #setup log file
  $efile = @{ open_unique("db.tad_status.log") }[1];
	$nosql = @{ open_unique(".nosqlout.txt") }[1];
  open(LOG, ">>", $efile) or die "\nERROR:\t cannot write LOG information to log file $efile $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";
}

sub OPTIONS {
	%MAINMENU = ( 
								a=>'Summary of samples in the database',
								b=>'Metadata details of samples', 
								c=>'Transcriptome analysis summary of samples',
								d=>'Average expression (fpkm) values of individual genes',
								e=>'Genes expression (fpkm) values across the samples',
								f=>'Chromosomal variant distribution',
								g=>'Gene-associated Variants with annotation information',
								h=>'Chromosomal region-associated Variants with annotation information',
								x=>'exit'
							);

}


#--------------------------------------------------------------------------------

=head1 SYNOPSIS

  tad-interact.pl <argument>

	
 Optional arguments:
       -h, --help                      print help message
       -m, --man                       print complete documentation

 Interactive options:
       -a, --summary                   summary of samples in the database
       -b, --metadata                  metadata details of samples
       -c, --transummary               transcriptome analysis summary of samples
       -d, --avgfpkm                   average expression (fpkm) values of individual genesm
       -e, --genexp                    genes expression (fpkm) values across the samples
       -f, --chrvar                    chromosomal variant distribution
       -g, --varanno                   gene-associated variants with respecitive annotation information
       -j, --chranno                   chromsomal region-associated variants with annotation information


 Function: interactive database module
 
 Example: #enter default interactive module
	  tad-interact.pl

	 #view summary of samples in the database
          tad-interact.pl -a
	  tad-interact.pl -summary


 Version: $Date: 2016-10-28 15:50:08 (Fri, 28 Oct 2016) $

=head1 OPTIONS

=over 8

=item B<--help>

print a brief usage message and detailed explantion of options.

=item B<--man>

print the complete manual of the program.

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

If any of the files input contain invalid arguments or format, TransAtlasDB
will terminate the program and the invalid input with the outputted. 
Users should manually examine this file and identify sources of error.

=back


--------------------------------------------------------------------------------

TransAtlasDB is free for academic, personal and non-profit use.

For questions or comments, please contact $ Author: Modupe Adetunji <amodupe@udel.edu> $.

=cut


