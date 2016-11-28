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

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-11-28 15:14:00 (Thu, 28 Nov 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------

our ($verbose, $efile, $help, $man, $nosql);
our ($dbh, $sth);
our ($connect);
my ($query, $output,);
my ($table, $outfile);
my %ARRAYQUERY;
#--------------------------------------------------------------------------------

sub printerr; #declare error routine
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details
if ($query) { #if user query mode selected
	$verbose and printerr "NOTICE:\t User query module selected\n";
	undef %ARRAYQUERY;
	$dbh = mysql($all_details{'MySQL-databasename'}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
  $sth = $dbh->prepare($query); $sth->execute();

	$table = Text::TabularDisplay->new( @{ $sth->{NAME_uc} } );#header
  my @header = @{ $sth->{NAME_uc} };
	my $i = 0;
	while (my @row = $sth->fetchrow_array()) {
		$i++; $table->add(@row); $ARRAYQUERY{$i} = [@row];
	}	
	if ($output) { #if output file is specified, else, result will be printed to the screen
		$outfile = @{ open_unique($output) }[1];
		open (OUT, ">$outfile") or die "ERROR:\t Output file $output can be not be created\n";
		print OUT join("\t", @header),"\n";
		foreach my $row (sort {$a <=> $b} keys %ARRAYQUERY) {
			no warnings 'uninitialized';
			print OUT join("\t", @{$ARRAYQUERY{$row}}),"\n";
		} close OUT;
	} else {
		printerr $table-> render, "\n\n"; #print display
	}
}

`rm -rf $nosql`;
#output: the end
printerr "-----------------------------------------------------------------\n";
if ($output) { printerr "NOTICE:\t Successful export of user report to '$outfile'\n"; }
printerr ("NOTICE:\t Summary in log file $efile\n");
printerr "-----------------------------------------------------------------\n";
print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n";
close (LOG);
`rm -rf $nosql`;

#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man, 'query=s'=>\$query, 'output=s'=>\$output) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  
  #pod2usage(-msg=>"ERROR:\t Invalid syntax specified, choose -metadata or -data2db.") unless ( $metadata || $datadb);
  #pod2usage(-msg=>"ERROR:\t Invalid syntax specified for @ARGV.") if (($metadata && $datadb)||($vep && $annovar) || ($gene && $vep) || ($gene && $annovar) || ($gene && $variant));
  #if ($vep || $annovar) {
	#	pod2usage(-msg=>"ERROR:\t Invalid syntax specified for @ARGV, specify -variant.") unless (($variant && $annovar)||($variant && $vep) || ($all && $annovar) || ($all && $vep));
	#}
   
  #@ARGV==1 or pod2usage("Syntax error");
  #$file2consider = $ARGV[0];

  $verbose ||=0;
  my $get = dirname(abs_path $0); #get source path
  $connect = $get.'/.connect.txt';
  #setup log file
	  #setup log file
	$efile = @{ open_unique("db.tad_status.log") }[1];
	$nosql = @{ open_unique(".nosqlout.txt") }[1];
  open(LOG, ">>", $efile) or die "\nERROR:\t cannot write LOG information to log file $efile $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";
}