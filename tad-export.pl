#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use threads;
use Thread::Queue;
use CC::Create;
use CC::Parse;

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-11-28 15:14:00 (Thu, 28 Nov 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------

our ($verbose, $efile, $help, $man, $nosql, $tmpout);
our ($dbh, $sth, $found, $count, @header, $connect);
my ($query, $output,$avgfpkm, $gene, $tissue, $organism, $genexp, $chrvar, $sample, $chromosome);
my $dbdata;
my ($table, $outfile, $syntax);
my $tmpname = rand(20);
our (%ARRAYQUERY, %SAMPLE);

#genexp module
my (@genearray, @VAR, $newfile, @threads, @headers); #splicing the genes into threads
my ($realstart, $realstop, $queue);
my (%FPKM, %CHROM, %POSITION, %REALPOST);
	
my (%VARIANTS, %SNPS, %INDELS);	
#--------------------------------------------------------------------------------

sub printerr; #declare error routine
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details
if ($query) { #if user query mode selected
	$query =~ s/^\s+|\s+$//g;
	$verbose and printerr "NOTICE:\t User query module selected\n";
	undef %ARRAYQUERY;
	$dbh = mysql($all_details{'MySQL-databasename'}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
  $sth = $dbh->prepare($query); $sth->execute();

	$table = Text::TabularDisplay->new( @{ $sth->{NAME_uc} } );#header
  @header = @{ $sth->{NAME_uc} };
	$count = 0;
	while (my @row = $sth->fetchrow_array()) {
		$count++; $table->add(@row); $ARRAYQUERY{$count} = [@row];
	}	
	unless ($count == 0){
		if ($output) { #if output file is specified, else, result will be printed to the screen
			$outfile = @{ open_unique($output) }[1];
			open (OUT, ">$outfile") or die "ERROR:\t Output file $output can be not be created\n";
			print OUT join("\t", @header),"\n";
			foreach my $row (sort {$a <=> $b} keys %ARRAYQUERY) {
				#no warnings 'uninitialized';
				print OUT join("\t", @{$ARRAYQUERY{$row}}),"\n";
			} close OUT;
		} else {
			printerr $table-> render, "\n"; #print display
		}
		$verbose and printerr "NOTICE:\t Summary: $count rows in result\n";
	} else { printerr "NOTICE:\t No Results based on search criteria: '$query' \n"; }
} #end of user query module

if ($avgfpkm){
	undef %ARRAYQUERY;
	#making sure required attributes are specified.
	$verbose and printerr "TASK:\t Average Fpkm Values of Individual Genes\n";
	unless ($gene || $tissue || $organism){
		unless ($gene) {printerr "ERROR:\t Gene option '-gene' is not specified\n"; }
		unless ($tissue) {printerr "ERROR:\t Tissue option '-tissue' is not specified\n"; }
		unless ($organism) {printerr "ERROR:\t Organism option '-species' is not specified\n"; }
		pod2usage("ERROR:\t Details for -avgfpkm aren't specified. Review 'tad-interact.pl -d' for more information");
	}
	$dbh = mysql($all_details{'MySQL-databasename'}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
	#checking if the organism is in the database
	$organism =~ s/^\s+|\s+$//g;
	$sth = $dbh->prepare("select organism from Animal where organism = '$organism'");$sth->execute(); $found =$sth->fetch();
	unless ($found) { pod2usage("ERROR:\t Organism name '$organism' is invalid. Consult 'tad-interact.pl -d' for more information"); }
	$verbose and printerr "NOTICE:\t Organism selected: $organism\n";
	#checking if tissue is in the database
	my @tissue = split(",", $tissue); undef $tissue; 
	foreach (@tissue) {
		$_ =~ s/^\s+|\s+$//g;
		$sth = $dbh->prepare("select distinct tissue from Sample where tissue = '$_'");$sth->execute(); $found =$sth->fetch();
		unless ($found) { pod2usage("ERROR:\t Tissue name '$_' is invalid. Consult 'tad-interact.pl -d' for more information"); }
		$tissue .= $_ .",";
	}chop $tissue;
	$verbose and printerr "NOTICE:\t Tissue(s) selected: $tissue\n";
	#retrieving each genes from the database
	my @genes = split(",", $gene);
	foreach my $fgene (@genes){
		$fgene =~ s/^\s+|\s+$//g;
		$verbose and printerr "NOTICE:\t Gene(s) selected: $fgene\n";
		foreach my $ftissue (@tissue) {
			$syntax = "call usp_gdtissue(\"".$fgene."\",\"".$ftissue."\",\"". $organism."\")";
			$sth = $dbh->prepare($syntax);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			@header = @{ $sth->{NAME_uc} }; #header
			splice @header, 1, 0, 'TISSUE';
			$table = Text::TabularDisplay->new( @header );
			$count = 0;
			while (my ($genename, $max, $avg, $min) = $sth->fetchrow_array() ) { #content
				push my @row, ($genename, $ftissue, $max, $avg, $min);
				$count++;
				$ARRAYQUERY{$genename}{$ftissue} = [@row];
			}
		}
	}
	unless ($count == 0) {
		if ($output) { #if output file is specified, else, result will be printed to the screen
			$outfile = @{ open_unique($output) }[1];
			open (OUT, ">$outfile") or die "ERROR:\t Output file $output can be not be created\n";
			print OUT join("\t", @header),"\n";
			foreach my $a (sort keys %ARRAYQUERY){
				foreach my $b (sort keys % { $ARRAYQUERY{$a} }){
					print OUT join("\t", @{$ARRAYQUERY{$a}{$b}}),"\n";
					$table->add(@{$ARRAYQUERY{$a}{$b}});
				}
			} close OUT;
		} else {
			foreach my $a (sort keys %ARRAYQUERY){
				foreach my $b (sort keys % { $ARRAYQUERY{$a} }){
					$table->add(@{$ARRAYQUERY{$a}{$b}});
				}
			} 
			printerr $table-> render, "\n"; #print display
		}	
		$verbose and printerr "NOTICE:\t Summary: $count rows in result\n";
	} else { printerr "NOTICE:\t No Results based on search criteria: '$gene' \n"; }
} #end of avgfpkm module

if ($genexp){
	`mkdir -p tadtmp/`;
	$count = 0;
	#making sure required attributes are specified.
	$verbose and printerr "TASK:\t Gene Expression (FPKM) information across Samples\n";
	unless ($organism){
		printerr "ERROR:\t Organism option '-species' is not specified\n";
		pod2usage("ERROR:\t Details for -genexp aren't specified. Review 'tad-interact.pl -e' for more information");
	}
	$dbh = mysql($all_details{'MySQL-databasename'}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
	#checking if the organism is in the database
	$organism =~ s/^\s+|\s+$//g;
	$sth = $dbh->prepare("select organism from Animal where organism = '$organism'");$sth->execute(); $found =$sth->fetch();
	unless ($found) { pod2usage("ERROR:\t Organism name '$organism' is invalid. Consult 'tad-interact.pl -e' for more information"); }
	$verbose and printerr "NOTICE:\t Organism selected: $organism\n";
	#checking if sample is in the database
	if ($sample) {
		my @sample = split(",", $sample); undef $sample; 
		foreach (@sample) {
			$_ =~ s/^\s+|\s+$//g;
			$sth = $dbh->prepare("select distinct sampleid from Sample where sampleid = '$_'");$sth->execute(); $found =$sth->fetch();
			unless ($found) { pod2usage("ERROR:\t Sample ID '$_' is not in the database. Consult 'tad-interact.pl -e' for more information"); }
			$sample .= $_ .",";
		}chop $sample;
		$verbose and printerr "NOTICE:\t Sample(s) selected: $sample\n";
	} else {
		$verbose and printerr "NOTICE:\t Sample(s) selected: 'all samples for $organism'\n";
		$sth = $dbh->prepare("select sampleid from vw_sampleinfo where organism = '$organism' and genes is not null"); #get samples
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		my $snumber= 0;
		while (my $row = $sth->fetchrow_array() ) {
			$snumber++;
			$SAMPLE{$snumber} = $row;
			$sample .= $row.",";
		} chop $sample;
	} #checking sample options
	@headers = split(",", $sample);
	$syntax = "select geneshortname, fpkm, sampleid, chromnumber, chromstart, chromstop from GenesFpkm where";
	if ($gene) {
		$syntax .= " (";
		my @genes = split(",", $gene); undef $gene;
		foreach (@genes){
			$_ =~ s/^\s+|\s+$//g;
			$syntax .= " geneshortname like '%$_%' or";
			$gene .= $_.",";
		} chop $gene;
		$verbose and printerr "NOTICE:\t Gene(s) selected: '$gene'\n";
		$syntax = substr($syntax, 0, -2); $syntax .= " ) and";
	} else {
		$verbose and printerr "NOTICE:\t Gene(s) selected: 'all genes'\n";
	}
	printerr "NOTICE:\t Processing Gene Expression for each library .";
	foreach (@headers){ 
		printerr ".";
		my $newsyntax = $syntax." sampleid = '$_' ORDER BY geneid desc;";
		$sth = $dbh->prepare($newsyntax);
		$sth->execute or die "SQL Error:$DBI::errstr\n";
		while (my ($gene_id, $fpkm, $library_id, $chrom, $start, $stop) = $sth->fetchrow_array() ) {
			$FPKM{"$gene_id|$chrom"}{$library_id} = $fpkm;
			$CHROM{"$gene_id|$chrom"} = $chrom;
			$POSITION{"$gene_id|$chrom"}{$library_id} = "$start|$stop";
		}
	} #end foreach extracting information from th database	
	printerr " Done\n";
	printerr "NOTICE:\t Processing Results ...";
	foreach my $newgene (sort keys %CHROM){ #turning the genes into an array
		if ($newgene =~ /^[\d\w]/){ push @genearray, $newgene;}
	}
	push @VAR, [ splice @genearray, 0, 2000 ] while @genearray; #sub array the genes into a list of 2000

	foreach (0..$#VAR){ $newfile .= "tadtmp/tmp_".$tmpname."-".$_.".zzz "; } #foreach sub array create a temporary file
	$queue = new Thread::Queue();
	my $builder=threads->create(\&main); #create thread for each subarray into a thread
	push @threads, threads->create(\&processor) for 1..5; #execute 5 threads
	$builder->join; #join threads
	foreach (@threads){$_->join;}
	my $command="cat $newfile >> $tmpout"; #path into temporary output
	system($command);
	`rm -rf tadtmp/`; #remove all temporary files
	printerr " Done\n";
	@header = qw|GENE CHROM|; push @header, @headers;
	$count = `cat $tmpout | wc -l`; chomp $count;
	open my $content,"<",$tmpout; `rm -rf $tmpout`;
	$table = Text::TabularDisplay->new( @header );
	unless ($count == 0) {
		if ($output){
			$outfile = @{ open_unique($output) }[1];
			open (OUT, ">$outfile") or die "ERROR:\t Output file $output can be not be created\n";
			print OUT join("\t", @header),"\n";
			print OUT <$content>;
			close OUT;
		} else {
			while (<$content>){ chomp;$table->add(split "\t"); }
			printerr $table-> render, "\n"; #print display
		}
		$verbose and printerr "NOTICE:\t Summary: $count rows in result\n";
	} else { printerr "NOTICE:\t No Results based on search criteria \n"; }
} #end of genexp module

if ($chrvar){
	undef %SAMPLE; undef %ARRAYQUERY;
	$count = 0;
	#making sure required attributes are specified.
	$verbose and printerr "TASK:\t Chromosomal Variant Distribution Across Samples\n";
	unless ($organism){
		printerr "ERROR:\t Organism option '-species' is not specified\n";
		pod2usage("ERROR:\t Details for -chrvar aren't specified. Review 'tad-interact.pl -f' for more information");
	}
	$dbh = mysql($all_details{'MySQL-databasename'}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
	#checking if the organism is in the database
	$organism =~ s/^\s+|\s+$//g;
	$sth = $dbh->prepare("select organism from Animal where organism = '$organism'");$sth->execute(); $found =$sth->fetch();
	unless ($found) { pod2usage("ERROR:\t Organism name '$organism' is invalid. Consult 'tad-interact.pl -f' for more information"); }
	$verbose and printerr "NOTICE:\t Organism selected: $organism\n";
	#checking if sample is in the database
	if ($sample) {
		my @sample = split(",", $sample); undef $sample; 
		foreach (@sample) {
			$_ =~ s/^\s+|\s+$//g;
			$sth = $dbh->prepare("select distinct sampleid from Sample where sampleid = '$_'");$sth->execute(); $found =$sth->fetch();
			unless ($found) { pod2usage("ERROR:\t Sample ID '$_' is not in the database. Consult 'tad-interact.pl -f' for more information"); }
			$sample .= $_ .",";
		} chop $sample;
		$verbose and printerr "NOTICE:\t Sample(s) selected: $sample\n";
	} else {
		$verbose and printerr "NOTICE:\t Sample(s) selected: 'all samples for $organism'\n";
		$sth = $dbh->prepare("select sampleid from vw_sampleinfo where organism = '$organism' and totalvariants is not null"); #get samples
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		my $snumber= 0;
		while (my $row = $sth->fetchrow_array() ) {
			$snumber++;
			$SAMPLE{$snumber} = $row;
			$sample .= $row.",";
		} chop $sample;
	} #checking sample options
	@headers = split(",", $sample);
	$syntax = "select sampleid, chrom, count(*) from VarResult where sampleid in ( ";
	foreach (@headers) { $syntax .= "'$_',"; } chop $syntax; $syntax .= ")";			
	if ($chromosome) {
		my @chromosome = split(",", $chromosome); undef $chromosome;
		$syntax .= " and (";
		foreach (@chromosome) {
			$_ =~ s/^\s+|\s+$//g;
			$sth = $dbh->prepare("select distinct chrom from VarResult where chrom = '$_'");$sth->execute(); $found =$sth->fetch();
			unless ($found) { pod2usage("ERROR:\t Chromosome '$_' is not in the database. Consult 'tad-interact.pl -f' for more information"); }
			$syntax .= "chrom = '$_' or ";
			$chromosome .= $_ .",";
		} $syntax = substr($syntax,0, -3); $syntax .= ") "; chop $chromosome;
		$verbose and printerr "NOTICE:\t Chromosome(s) selected: $chromosome\n";
	} else {
		$verbose and printerr "NOTICE:\t Chromosome(s) selected: 'all chromosomes'\n";
	}
	my $endsyntax = "group by sampleid, chrom order by sampleid, length(chrom),chrom";
	my $allsyntax = $syntax.$endsyntax; 
	$sth = $dbh->prepare($allsyntax); 
	$sth->execute or die "SQL Error:$DBI::errstr\n";
	my $number = 0;
	while (my ($sampleid, $chrom, $counted) = $sth->fetchrow_array() ) {
		$number++;
		$CHROM{$sampleid}{$number} = $chrom;
		$VARIANTS{$sampleid}{$chrom} = $counted;
	}	
	$allsyntax = $syntax."and variantclass = 'SNV' ".$endsyntax; #counting SNPS
	$sth = $dbh->prepare($allsyntax); 
	$sth->execute or die "SQL Error:$DBI::errstr\n";
	while (my ($sampleid, $chrom, $counted) = $sth->fetchrow_array() ) {
		$SNPS{$sampleid}{$chrom} = $counted;
	}
	$allsyntax = $syntax."and (variantclass = 'insertion' or variantclass = 'deletion') ".$endsyntax; #counting INDELs
	$sth = $dbh->prepare($allsyntax); 
	$sth->execute or die "SQL Error:$DBI::errstr\n";
	while (my ($sampleid, $chrom, $counted) = $sth->fetchrow_array() ) {
		$INDELS{$sampleid}{$chrom} = $counted;
	}
	@header = qw(SAMPLE CHROMOSOME VARIANTS SNPs INDELs);
	$table = Text::TabularDisplay->new(@header);
	my @content;
	foreach my $ids (sort keys %VARIANTS){  
		if ($ids =~ /^[0-9a-zA-Z]/) {
			foreach my $no (sort {$a <=> $b} keys %{$CHROM{$ids} }) {
				$count++;
				my @row = ();
				push @row, ($ids, $CHROM{$ids}{$no}, $VARIANTS{$ids}{$CHROM{$ids}{$no}});
				if (exists $SNPS{$ids}{$CHROM{$ids}{$no}}){
					push @row, $SNPS{$ids}{$CHROM{$ids}{$no}};
				} else {
					push @row, "0";
				}
				if (exists $INDELS{$ids}{$CHROM{$ids}{$no}}){
					push @row, $INDELS{$ids}{$CHROM{$ids}{$no}};
				}
				else {
					push @row, "0";
				}
				$table->add(@row);
				$ARRAYQUERY{$count} = [@row];
			}
		}
	}
	unless ($count == 0) {
		if ($output){
			$outfile = @{ open_unique($output) }[1];
			open (OUT, ">$outfile") or die "ERROR:\t Output file $output can be not be created\n";
			print OUT join("\t", @header),"\n";
			my @newcontent = split("\n", @content);
			foreach (sort keys %ARRAYQUERY) { print OUT join("\t",@{$ARRAYQUERY{$_}}), "\n"; }
			close OUT;
		} else {
			printerr $table-> render, "\n"; #print display
		}
		$verbose and printerr "NOTICE:\t Summary: $count rows in result\n";
	} else { printerr "NOTICE:\t No Results based on search criteria \n"; }
} #end of chrvar module



#output: the end
printerr "-----------------------------------------------------------------\n";
unless ($count == 0) { if ($output) { printerr "NOTICE:\t Successful export of user report to '$outfile'\n"; } }
printerr ("NOTICE:\t Summary in log file $efile\n");
printerr "-----------------------------------------------------------------\n";
print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n";
close (LOG);


#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man, 'query=s'=>\$query, 'db2data'=>\$dbdata, 'output=s'=>\$output,
						 'avgfpkm'=>\$avgfpkm, 'gene=s'=>\$gene, 'tissue=s'=>\$tissue, 'species=s'=>\$organism, 'genexp'=>\$genexp,
						 'samples|sample=s'=>\$sample, 'chrvar'=>\$chrvar, 'chromosome=s'=>\$chromosome
						 
						 
						 ) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  pod2usage(-msg=>"ERROR:\t Invalid syntax specified, choose -metadata or -data2db.") unless ( $query || $dbdata);
  #pod2usage(-msg=>"ERROR:\t Invalid syntax specified for @ARGV.") if (($query && $dbdata)||($avgfpkm && $genexp) || ($gene && $vep) || ($gene && $annovar) || ($gene && $variant));
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
	$tmpout = @{ open_unique(".export.txt") }[1]; `rm -rf $tmpout`;
  open(LOG, ">>", $efile) or die "\nERROR:\t cannot write LOG information to log file $efile $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";
}

sub main {
    foreach my $count (0..$#VAR) {
		my $namefile = "tadtmp/tmp_".$tmpname."-".$count.".zzz";
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
		if ($status eq "forward"){
			$realstart = (sort {$a <=> $b} @newstartarray)[0];
			$realstop = (sort {$b <=> $a} @newstoparray)[0];	
		}
		elsif ($status eq "reverse"){
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
