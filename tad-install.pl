#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use CC::Create;
use DBD::mysql;

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-10-25 13:19:08 (Tue, 25 Oct 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------

our ($verbose, $help, $man);
our ($sqlfile,$connect);
my ($dbname,$username,$password,$location,$fbname);
my ($sth,$dbh,$schema); #connect to database;

#--------------------------------------------------------------------------------

sub printerr; #declare error routine
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

#create schema attributes 
$dbh = mysql_create($dbname, $username, $password); #connect to mysql to create database (if applicable)
$schema = "CREATE SCHEMA IF NOT EXISTS $dbname";
$sth = $dbh->prepare($schema);
$sth->execute() or die (qq(Error: Can't create database, make sure user has create schema  priviledges or use an existing database.));
$dbh->disconnect();
$verbose and printerr "Executed:\tUsing SCHEMA $dbname\n";

$dbh = mysql($dbname, $username, $password); #connect to mysql
#Import schema to mysql
open (SQL, "$sqlfile") or die "Error: Can't open file schema file for reading, contact $AUTHOR\n";
while (my $sqlStatement = <SQL>) {
   $sth = $dbh->prepare($sqlStatement)
      or die (qq(Error: Can't prepare $sqlStatement));

   $sth->execute()
      or die qq(Error: Can't execute $sqlStatement);
   $verbose and printerr "Executed:\t$sqlStatement\n";
}
$dbh->disconnect();

#create FastBit path on connection details
our $ffastbit = fastbit($location, $fbname); 
`rm -rf $ffastbit`; $verbose and printerr "Executed:\tRemoved Fastbit folder $ffastbit\n\n";
`mkdir $ffastbit`; $verbose and printerr "Executed:\tCreated Fastbit folder $ffastbit\n\n"; 

#output
printerr ("Success: Creation of MySQL database ==> \"$dbname\"\n");
printerr ("Success: Creation of FastBit folder ==> \"".$ffastbit."\"\n");
print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n\n";

#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man, 'databasename|d=s'=>\$dbname,
		'username|u=s'=>\$username, 'password|p=s'=>\$password, 'location|l=s'=>\$location,
		'fastbitname|n=s'=>\$fbname ) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  pod2usage(-msg=>"Error: Required argument -p (MySQL password) not provided.") if (!$password);

  #set defaults
  $verbose ||=0;
  my $get = dirname(abs_path $0); #get source path
  $dbname = "transatlasdb" if (! $dbname);
  $fbname = "transatlasfb" if (! $fbname);
  $username = "root" if (! $username);
  if (! $location) {$location = `pwd`; chomp $location;}

  #setup log file
  my $errfile = open_unique("db.tad_status.log"); 
  open(LOG, ">>", @$errfile[1]) or die "Error: cannot write LOG information to log file @$errfile[1] $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";

  $sqlfile = "$get/schema/\.transatlasdb-ddl.sql";
  open(CONNECT, ">$get/\.connect.txt"); 
  my $connectcontent = "MySQL\n  username $username\n  password $password\n  databasename $dbname\nFastBit\n  path $location\n  foldername $fbname";
  print CONNECT $connectcontent; close (CONNECT);
}


sub printerr {
  print STDERR @_;
  print LOG @_;
}

#--------------------------------------------------------------------------------

=head1 SYNOPSIS

 tad-install.pl [arguments] -p <MySQLpassword>

 Optional arguments:
       -h, --help                      print help message
       -m, --man                       print complete documentation
       -v, --verbose                   use verbose output

 Arguments to install transatlasdb on MySQL
       -u, --username <string>         specify MySQL username (default: root)
       -p, --password <string>         specify MySQL password
       -d, --databasename <string>     specify DatabaseName (default: transatlasdb)

 Arguments to install transatlasdb on FastBit
       -l, --location <directory>	specify FastBit directory (default: current working directory)
       -n, --fastbitname <directory>    specify FastBitName (default: transatlasfb)

 Function: create the TransAtlasDB tables in MySQL and FastBit location on local disk
 
 Example: #create TransAtlasDB with mysql root password as 'password' and using default options
          tad-install.pl -p password
        
          #create TransAtlasDB database with username:root, password:root, databasename:testmysql, fastbitname:testfastbit
          tad-install.pl -u root -p root -d testmysql -n testfastbit


 Version: $Date: 2016-10-25 13:19:08 (Tue, 25 Oct 2016) $

=head1 OPTIONS

=over 8

=item B<--help>

print a brief usage message and detailed explantion of options.

=item B<--man>

print the complete manual of the program.

=item B<--verbose>

use verbose output.


=item B<-u| --username>

specify MySQL username with 'GRANT ALL' priviledge, if other than 'root' (default: root). 

=item B<-p|--password>

specify MySQL password (required)

=item B<-d|--databasename>

specify MySQL databasename if other than 'transatlasdb' (default: transatlasdb)

=item B<-l|--location>

specify FastBit storage path if other than current working directory (default will be the current dirrectory)

=item B<-n|--fastbitname>

specify FastBit storage name if other than 'transatlasfb'(default: transatlasfb)

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

For questions or comments, please contact $Author: Modupe Adetunji <amodupe@udel.edu> $.

=cut


