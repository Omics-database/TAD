#!/usr/bin/perl
use strict;
use DBI;
use Getopt::Long;
use Pod::Usage;
use threads;
use Thread::Queue;
use lib '/home/modupe/SCRIPTS/SUB';
use passw;
use routine;


chdir "/home/modupe/public_html/atlas/OUTPUT";
#ARGUMENTS
my($specifics,$output1);
GetOptions("1|a|in|in1|list=s"=>\$specifics,"2|b|out1|output1=s"=>\$output1);

my ($dbh, $sth, $syntax, @row);
our ($VERSION, $DATE, $AUTHOR) = DEFAULTS;
$dbh = mysql();
#VARIABLES
my (@threads, @gene_ids, @genearray, @VAR);
my $tmpname = rand(20);
 
#HASH TABLES
my (%CHROM, %FPKM, %POSITION, %REALPOST);
my ($realstart, $realstop);
# OPENING OUTPUT FILE
open (OUT, ">$output1");

#SPECIFYING LIBRARIES OF INTEREST
my @headers = split("\,", $specifics);

# HEADER print out
print OUT "GENE\tCHROM\t";
foreach my $name (0..$#headers-1){
	print OUT "library_$headers[$name]\t";
}
print OUT "library_$headers[$#headers]\n";
close(OUT);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N  W O R K F L O W - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#TABLE COLUMNS
foreach (@headers){
	$syntax = "select gene_short_name, fpkm, library_id, chrom_no, chrom_start,
				chrom_stop from genes_fpkm where library_id = $_ ORDER BY gene_id desc;";
	$sth = $dbh->prepare($syntax);
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	while (my ($gene_id, $fpkm, $library_id, $chrom, $start, $stop) = $sth->fetchrow_array() ) {
		$FPKM{"$gene_id|$chrom"}{$library_id} = $fpkm;
		$CHROM{"$gene_id|$chrom"} = $chrom;
		$POSITION{"$gene_id|$chrom"}{$library_id} = "$start|$stop";
	}
}

# DISCONNECT FROM THE DATABASE
$dbh->disconnect();

foreach my $newgene (sort keys %CHROM){
	if ($newgene =~ /^[\d\w]/){
		push @genearray, $newgene;
	}
}
push @VAR, [ splice @genearray, 0, 2000 ] while @genearray;
my $newfile;
foreach (0..$#VAR){
	$newfile .= "tmp_".$tmpname."-".$_.".zzz ";
}
my $queue = new Thread::Queue();
my $builder=threads->create(\&main);
push @threads, threads->create(\&processor) for 1..5;
$builder->join;
foreach (@threads){$_->join;}

my $command="cat $newfile >> $output1";
system($command);


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - -S U B R O U T I N E S- - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub main {
    foreach my $count (0..$#VAR) {
		my $namefile = "tmp_".$tmpname."-".$count.".zzz";
		push $VAR[$count], $namefile;
		while(1) {
			if ($queue->pending() <100) {
				$queue->enqueue($VAR[$count]);
				last;
			}
		}
	}
	foreach(1..5) { $queue-> enqueue(undef); }
}

sub processor {
	my $query;
	while ($query = $queue->dequeue()){
		collectsort(@$query);
	}
}

sub collectsort{
	my $file = pop @_;
	open(OUT2, ">$file");
	foreach (@_){	
		sortposition($_);
	}
	foreach my $genename (sort @_){
		if ($genename =~ /^\S/){
			my ($realstart,$realstop) = split('\|',$REALPOST{$genename},2);
			my $realgenes = (split('\|',$genename))[0];
			print OUT2 $realgenes."\t".$CHROM{$genename}."\:".$realstart."\-".$realstop."\t";
			foreach my $lib (0..$#headers-1){
				if (exists $FPKM{$genename}{$headers[$lib]}){
					print OUT2 "$FPKM{$genename}{$headers[$lib]}\t";
				}
				else {
					print OUT2 "0\t";
				}
			}
			if (exists $FPKM{$genename}{$headers[$#headers]}){
				print OUT2 "$FPKM{$genename}{$headers[$#headers]}\n";
			}
			else {
				print OUT2 "0\n";
			}
		}
    }
}

sub sortposition {
    my $genename = $_[0];
    my $status = "nothing";
	my @newstartarray; my @newstoparray;
	foreach my $libest (sort keys % {$POSITION{$genename}} ) {
		my ($astart, $astop, $status) = VERDICT(split('\|',$POSITION{$genename}{$libest},2));
        push @newstartarray, $astart;
		push @newstoparray, $astop;
		if ($status == "forward"){
			$realstart = (sort {$a <=> $b} @newstartarray)[0];
			$realstop = (sort {$b <=> $a} @newstoparray)[0];	
		}
		elsif ($status == "reverse"){
			$realstart = (sort {$b <=> $a} @newstartarray)[0];
			$realstop = (sort {$a <=> $b} @newstoparray)[0];
		}
		else { die "Something is wrong\n"; }
		$REALPOST{$genename} = "$realstart|$realstop";
	}
	
}

sub VERDICT {
    my (@array) = @_;
    my $status = "nothing";
    my (@newstartarray, @newstoparray);
    if ($array[0] > $array[1]) {
        $status = "reverse";
    }
    elsif ($array[0] < $array[1]) {
        $status = "forward";
    }
    return $array[0], $array[1], $status;
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - -T H E  E N D - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit;
