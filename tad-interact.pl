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
our ($connect, $verbose, $efile, $help, $man, $nosql);
our (%MAINMENU, $verdict);
my $choice = 0;
my ($dbh, $sth, $fastbit);
#date
my $date = `date +%Y-%m-%d`;

#--------------------------------------------------------------------------------
OPTIONS();
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details
print "\tWELCOME TO TRANSATLASDB INTERACTIVE MODULE\n";
MAINMENU:
while ($choice < 1){
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

#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man ) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  
  #pod2usage(-msg=>"ERROR:\t Invalid syntax specified, choose -metadata or -data2db.") unless ( $metadata || $datadb);
  #pod2usage(-msg=>"ERROR:\t Invalid syntax specified for @ARGV.") if (($metadata && $datadb)||($vep && $annovar) || ($gene && $vep) || ($gene && $annovar) || ($gene && $variant));
   
  @ARGV==0 or pod2usage("Syntax error");

  $verbose ||=0;
  my $get = dirname(abs_path $0); #get source path
  $connect = $get.'/.connect.txt';
  #setup log file
  my $errfile = open_unique("db.tad_status.log");
	my $nosqlfile = open_unique(".nosqlout.txt"); 	$nosql = @$nosqlfile[1];
  open(LOG, ">>", @$errfile[1]) or die "\nERROR:\t cannot write LOG information to log file @$errfile[1] $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";
  $efile = @$errfile[1];
}

sub OPTIONS {
	%MAINMENU = ( 
								a=>'summary of samples in the database',
								b=>'metadata details of samples', 
								c=>'transcriptome analysis summary of samples',
								d=>'average expression (fpkm) values of individual genes',
								e=>'genes expression (fpkm) values across the samples',
								f=>'chromosomal variant distribution',
								g=>'gene associated variants with annotation information',
								h=>'chromosomal region associated variants with annotation information',
								x=>'exit'
							);

}



