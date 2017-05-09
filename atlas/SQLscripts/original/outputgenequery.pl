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
my($specifics,$output1, $ibis);
GetOptions("1|a|in|in1|list=s"=>\$specifics,"2|b|out1|output1=s"=>\$output1);

#my ($dbh, $sth, $syntax, @row);
our ($VERSION, $DATE, $AUTHOR) = DEFAULTS();
our ($chickengenes, $mousegenes, $alligatorgenes) = FBGENES();

#$dbh = mysql();

#VARIABLES
my (@threads, @gene_ids, @genearray, @VAR);
my $tmpname = rand(20);
 
#HASH TABLES
my (%CHROM, %FPKM, %POSITION, %REALPOST, %CHESS);
my ($realstart, $realstop, $fuzzylogic, $check);
# OPENING OUTPUT FILE
open (OUT, ">$output1.txt");

#SPECIFYING LIBRARIES OF INTEREST
my @headers = split("\,", $specifics);
# HEADER print out
print OUT "GENE\tCHROM\t";
foreach my $name (0..$#headers-1){
	print OUT "library_$headers[$name]\t";
}
print OUT "library_$headers[$#headers]\n";
close(OUT);
# - - - - - - - - - - - - - - - - M A I N  W O R K F L O W - - - - - - - - - - - - - -

#TABLE COLUMNS
foreach (@headers){
	my $filenamearray = "$output1.v1,$output1.v2,$output1.v3";
	$ibis = "/home/modupe/.bin/bin/ibis -d $chickengenes -q 'select genename, fpkm, library, chrom, chromstart, chromstop where library = $_ order by genename, chrom, chromstart' -v -o $output1.v1"; `$ibis`;
	$ibis = "/home/modupe/.bin/bin/ibis -d $mousegenes -q 'select genename, fpkm, library, chrom, chromstart, chromstop where library = $_' -v -o $output1.v2"; `$ibis`;
	$ibis = "/home/modupe/.bin/bin/ibis -d $alligatorgenes -q 'select genename, fpkm, library, chrom, chromstart, chromstop where library = $_' -v -o $output1.v3"; `$ibis`;

	foreach my $filename (split(",", $filenamearray)){
		open (IN, "<", $filename);
		while (<IN>){
			chomp;
			my ($genez, $fpkm, $library, $chrom, $start, $stop) = split(/\, /, $_, 6);
			#removing the quotation marks from the words
			$genez = substr($genez,1,-1); $chrom= substr($chrom,1,-1);  $fpkm = sprintf("%.5f",$fpkm); 
			if ($genez =~ /NULL/) { $genez = "-"; }
			$check = "no";
			if (exists $CHESS{"$genez|$chrom"}) { #if the key is already in the array.
				foreach my $fuzzy (@{$CHESS{"$genez|$chrom"}}) {
					unless ($check eq "yes") {
						my $thedets = (split('\|', $fuzzy))[2]; #if ($fuzzy != /^-/){ print "$fuzzy, $thedets\n";}
						my $enddets = (split('\|', $fuzzy))[3]; #if ($fuzzy != /^-/){ print "$fuzzy, $enddets\n";}
						if (($start >= $thedets-200) && ($start < $thedets+200)) {
							$fuzzylogic = $fuzzy;
							$check = "yes";
						} elsif (($stop >= $enddets-200) && ($stop < $enddets+200)) {
							$fuzzylogic = $fuzzy;
							$check = "yes";
						} 
					}
				}
				unless ($check eq "yes") { #making sure the new key is push into the array
					push $CHESS{"$genez|$chrom"}, "$genez|$chrom|$start|$stop";
					$fuzzylogic = "$genez|$chrom|$start|$stop";
					$check = "yes";
				}
			} else {
				push (@{$CHESS{"$genez|$chrom"}}, "$genez|$chrom|$start|$stop");
				$fuzzylogic = "$genez|$chrom|$start|$stop";
				$check = "yes";
			}
				
			if ($check eq "yes") { 
				$FPKM{$fuzzylogic}{$library} = $fpkm;
				$CHROM{$fuzzylogic} = $chrom;
				$POSITION{$fuzzylogic}{$library}= "$start|$stop";
			} else {die "Something is wrong with your fuzzy logic\n"};
		} close (IN);
	}
}
@headers = split("\,", $specifics);

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

my $command="cat $newfile >> $output1.txt";
system($command);

# - - - - - - - - - - - - - - -S U B R O U T I N E S- - - - - - - - - - - - - - - - -
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
# - - - - - - - - - - - - - - - - -T H E  E N D - - - - - - - - - - - - - - - - - - -
exit;
