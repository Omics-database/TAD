#!/usr/bin/perl
use strict;
use DBI;
use Getopt::Long;
use Pod::Usage;
use lib '/home/modupe/SCRIPTS/SUB';
use passw;
use routine;

#ARGUMENTS
my($specifics,$output,$metadata, $sequence);
GetOptions("1|a|in|in1|list=s"=>\$specifics,"2|b|out|output=s"=>\$output,"m"=>\$metadata,"z"=>\$sequence);


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DATABASE VARIABLES
my ($dbh, $sth, $syntax, @row);
our ($VERSION, $DATE, $AUTHOR) = DEFAULTS;
$dbh = mysql();

#OPENING OUTPUT FILE
open (OUT, ">$output")  or die "it aint opening";

#SPECIFYING LIBRARIES OF INTEREST
my @headers = split("\,", $specifics);

if ($metadata) {
  # HEADER print out
  print OUT "library_id\tbird_id\tspecies\tline\ttissue\tmethod\t";
  print OUT "index\tchip_result\tscientist\tdate\tnotes\n";

  $syntax = "select * from bird_libraries where library_id in 
        ($specifics);";
  $sth = $dbh->prepare($syntax);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  
  while (@row = $sth->fetchrow_array() ) { 
        foreach my $real (0..$#row-1){
          print OUT "$row[$real]\t";
        }
        print OUT "$row[$#row]\n";
  }
}
if ($sequence) {
  #HEADER print
  print OUT "Library id\tLine\tSpecies\tTissue\tTotal reads\tMapped reads\tGenes\tIsoforms\tVariants\tSNPs\tINDELs\tSequences\tDate\n";
  
  $syntax = "select v.library_id,v.line,v.species, v.tissue, t.total_reads, v.mapped_reads, v.genes, v.isoforms,
              v.total_VARIANTS VARIANTS,v.total_SNPs SNPs, v.total_INDELs INDELs, f.sequences Sequences, t.Date Date from transcripts_summary as t
              join vw_libraryinfo as v on t.library_id = v.library_id join frnak_metadata as f on f.library_id = v.library_id where v.library_id in 
              ($specifics);";
  $sth = $dbh->prepare($syntax);
  $sth->execute or die "SQL Error: $DBI::errstr\n";
  
  while (@row = $sth->fetchrow_array() ) { 
        foreach my $real (0..$#row-1){
          print OUT "$row[$real]\t";
        }
        print OUT "$row[$#row]\n";
  }
}
# DISCONNECT FROM THE DATABASE
$dbh->disconnect();
close(OUT);



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - -T H E  E N D - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit;
