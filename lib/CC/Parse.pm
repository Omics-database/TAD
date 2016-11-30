#package CC::Parse;
use strict;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) .'/lib/lib/perl5';
use Spreadsheet::Read;
use Text::TabularDisplay;
use Term::ANSIColor;
use List::MoreUtils qw(uniq);

my ($sth, $dbh, $t, $fastbit);
my ($precount, $count, $verdict);
sub excelcontent { #read excel content
  my $workbook = ReadData($_[0]) or pod2usage("Error: Could not open excel file \"$_[0]\"");
  my ($odacontent, $source_cell);
  foreach my $source_sheet_number (1..length($workbook)) {
    my @rows = Spreadsheet::Read::rows($workbook->[$source_sheet_number]);
    my @column = Spreadsheet::Read::row($workbook->[$source_sheet_number],1);
    unless ($#rows < 0) {
      $odacontent .= "%%$workbook->[$source_sheet_number]{label}\n";
      foreach my $row_index (1..$#rows+1) {
        foreach my $col_index (1..$#column+1) {
          $source_cell = $workbook->[$source_sheet_number]{cell}[$col_index][$row_index];
          $odacontent .= $source_cell. "?abc?";
        }
        $odacontent .= "\n";
      }
    }
  }
  my @content = split('%%', $odacontent);
	@content = @content[2..$#content]; 
  return @content;
}

sub tabcontent { #read tadcontent
  open (BOOK,"<",$_[0]) or pod2usuage ("Error: Could not open source file \"$_[0]\"");
  my @content = <BOOK>; close (BOOK); chomp @content;
  our (%INDEX, %columnpos);
  my @header = split("\t", $content[0]);

	foreach my $no (0..$#header){
			$header[$no] =~ s/\s+$//;
      $columnpos{$no} = lc($header[$no]);
  }
  foreach (1..$#content) {
    my @value = split ("\t", $content[$_]);
    if (length $value[0] > 1){
      foreach my $na (0..$#value){
        $INDEX{$_}{$columnpos{$na}} = $value[$na];
      }
    }
  }
	
  return \%INDEX;
}

sub SUMMARY {
	printerr colored("A.\tSUMMARY OF SAMPLES IN THE DATABASE.", 'bright_red on_black'),"\n";
	$dbh = $_[0];	
	#first: Total number of animals (organism, count)
		$t = Text::TabularDisplay->new(qw(Organism Count));
		$sth = $dbh->prepare("select organism, count(*) from Animal group by organism");
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		while (my @row = $sth->fetchrow_array() ) {
			$t->add(@row);
		}
		$sth = $dbh->prepare("select count(*) from Animal"); #FINAL ROW
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		while (my @row = $sth->fetchrow_array() ) {
			$t->add("Total", @row);
		}
		printerr colored("Summary of Organisms.", 'bold red'), "\n";
		printerr color('red');printerr $t-> render, "\n\n";printerr color('reset');
	
	#second: Total number of samples (organism, tissue, count)
		$t = Text::TabularDisplay->new(qw(Organism Tissue Count));
		$sth = $dbh->prepare("select organism , tissue, count(*) from Animal a join Sample b on a.animalid = b.derivedfrom group by organism, tissue");
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		while (my @row = $sth->fetchrow_array() ) {
			$t->add(@row);
		}
		printerr colored("Summary of Samples.", 'bold green'), "\n";
		printerr color('green');printerr $t-> render, "\n\n";printerr color('reset');
	
	#third: Summary of libraries processed (organism, sample, processed samples)
		$sth = $dbh->prepare("select a.organism, format(count(b.sampleid),0), format(count(c.sampleid),0), format(count(d.sampleid),0), format(count(e.sampleid),0) from Animal a join Sample b on a.animalid = b.derivedfrom left outer join vw_sampleinfo c on b.sampleid = c.sampleid left outer join GeneStats d on c.sampleid = d.sampleid left outer join VarSummary e on c.sampleid = e.sampleid group by a.organism");
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		$t = Text::TabularDisplay->new(qw(ORGANISM RECORDED PROCESSED GENES VARIANTS));
		while (my @row = $sth->fetchrow_array() ) {
			$t->add(@row);
		}
		$sth = $dbh->prepare("select format(count(b.sampleid),0), format(count(c.sampleid),0), format(count(d.sampleid),0), format(count(e.sampleid),0) from Animal a join Sample b on a.animalid = b.derivedfrom left outer join vw_sampleinfo c on b.sampleid = c.sampleid left outer join GeneStats d on c.sampleid = d.sampleid left outer join VarSummary e on c.sampleid = e.sampleid"); #FINAL ROW
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		while (my @row = $sth->fetchrow_array() ) {
			$t->add("Total", @row);
		}
		printerr colored("Summary of Samples processed.", 'bold magenta'), "\n";
		printerr color('magenta');printerr $t-> render, "\n\n";printerr color('reset');
		
	##fourth: Summary of database content
		$sth = $dbh->prepare("select organism Species, format(sum(genes),0) Genes, format(sum(totalvariants),0) Variants from vw_sampleinfo group by species");
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		$t = Text::TabularDisplay->new(qw(ORGANISM GENES(total) VARIANTS(total)));
		while (my @row = $sth->fetchrow_array() ) {
			$t->add(@row);
		}
		$sth = $dbh->prepare("select format(sum(genes),0) Genes, format(sum(totalvariants ),0) Variants from vw_sampleinfo"); #FINAL ROW
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		while (my @row = $sth->fetchrow_array() ) {
			$t->add("Total", @row);
		}
		printerr colored("Summary of Database Content.", 'bold blue'), "\n";
		printerr color('blue');printerr $t-> render, "\n\n";printerr color('reset');
}

sub METADATA {
	open(LOG, ">>", $_[1]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n"; #open log file
	printerr colored("B.\tMETADATA OF SAMPLES.", 'bright_red on_black'),"\n";
	$dbh = $_[0]; 
	$t = Text::TabularDisplay->new(qw(SampleID	AnimalID Organism Tissue Scientist Organization AnimalDescription SampleDescription DateImported)); #header
	$precount = 0; $precount = $dbh->selectrow_array("select count(*) from vw_metadata"); #count all info in metadata
	my $indent = "";
	unless ($precount > 9) { #preset the output to be less than 10 row
		$sth = $dbh->prepare("select * from vw_metadata order by date");
	} else {
		$precount= 10; $indent = "Only";
		$sth = $dbh->prepare("select * from vw_metadata order by date desc limit $precount");
	}
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	while (my @row = $sth->fetchrow_array() ) {
		$t->add(@row);
	}
	$count = 0; $count = $dbh->selectrow_array("select count(*) from Sample");
	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n"; #print results
	
	printerr color('bright_black'); #additional procedure
	printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "NOTICE:\t $indent $precount samples are displayed.\n";
	printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
	printerr "\ttad-export.pl --query 'select * from vw_metadata'\n";
	printerr "\ttad-export.pl --query 'select * from vw_metadata' --output output.txt\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr color('reset'); printerr "\n\n";
}

sub TRANSCRIPT {
	open(LOG, ">>", $_[1]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n"; #open log file
	printerr colored("C.\tTRANSCRIPTOME ANALYSIS SUMMARY OF SAMPLES.", 'bright_red on_black'),"\n";
	$dbh = $_[0]; 
	$t = Text::TabularDisplay->new(qw(SampleID	Organism Tissue TotalReads MappedReads	Genes(total) Isoforms(total) Variants(total) SNVs(total) InDELs(total))); #header
	$precount = 0; $precount = $dbh->selectrow_array("select count(*) from vw_sampleinfo"); #count all info in processed samples
	my $indent = "";
	$count = $precount;
	unless ($precount > 9) { #preset the output to be less than 10 rows
		$sth = $dbh->prepare("select * from vw_sampleinfo");
	} else {
		$precount= 10; $indent = "Only";
		$sth = $dbh->prepare("select * from vw_sampleinfo limit $precount");
	}
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	while (my @row = $sth->fetchrow_array() ) {
		$t->add(@row);
	}
	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n"; #print results
	
	printerr color('bright_black'); #additional procedure
	printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "NOTICE:\t $indent $precount samples are displayed.\n";
	printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
	printerr "\ttad-export.pl --query 'select * from vw_sampleinfo'\n";
	printerr "\ttad-export.pl --query 'select * from vw_sampleinfo' --output output.txt\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr color('reset'); printerr "\n\n";
}

sub AVERAGE {
	open(LOG, ">>", $_[1]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n"; #open log file
	printerr colored("D.\tAVERAGE FPKM VALUES OF INDIVIDUAL GENES.", 'bright_red on_black'),"\n";
	$dbh = $_[0];
	my (%TISSUE, %GENES, %AVGFPKM, $tissue, $genes , $species, %ORGANISM);
	$count = 0;
	$sth = $dbh->prepare("select distinct organism from vw_sampleinfo where genes is not null"); #get organism(s)
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	my $number = 0;
	while (my $row = $sth->fetchrow_array() ) {
		$number++;
		$ORGANISM{$number} = $row;
	}
	if ($number > 1) { #if there are more than one processed organism
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nThe following organisms are available; select an organism : \n";
		foreach (sort {$a <=> $b} keys %ORGANISM) { print "  ", $_,"\.  $ORGANISM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\n ? : ";
		chomp ($verdict = int(<>)); print "\n";
	} else { $verdict = 1; } #else if there's only one organism 
	if ($verdict >= 1 && $verdict <= $number ) {
		$species = $ORGANISM{$verdict};
		printerr "\nORGANISM : $species\n";
		print "\nSelect genes (multiple genes can be separated by comma) ? "; #ask for genes
	  chomp ($verdict = uc(<>)); 
		$verdict =~ s/\s+//g;
		unless ($verdict) { printerr "ERROR:\t Gene(s) not provided\n"; next MAINMENU; } # if genes aren't provided
		$genes = $verdict;
		my @genes = split(",", $verdict); 
		$sth = $dbh->prepare("select distinct tissue from vw_sampleinfo where genes is not null and organism = '$species'"); #get tissues
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		my $tnumber = 0;
		while (my $row = $sth->fetchrow_array() ) {
			$tnumber++;
			$TISSUE{$tnumber} = $row;
			$tissue .= $row.",";
		} chop $tissue;
		$verdict = undef;
		if ($tnumber > 1) {
			print color ('bold');
			print "--------------------------------------------------------------------------\n";
			print color('reset');
			foreach (sort {$a <=> $b || $a cmp $b} keys %TISSUE) { print "  ", $_," :  $TISSUE{$_}\n";}
			print color('bold');
			print "--------------------------------------------------------------------------\n";
			print color('reset');
			print "\nSelect tissue (multiple tissues can be separated by comma or 0 for all) ? "; #ask for tissues
			chomp ($verdict = <>); print "\n";
		} else { $verdict = 0;}
		$TISSUE{0} = $tissue;
		$verdict =~ s/\s+//g;
		unless ($verdict) { $verdict = 0; }
		my @tissue = split(",", $verdict); undef $tissue; 
		foreach (@tissue) {
			unless (exists $TISSUE{$_}){
				printerr "ERROR\t: Tissue number $_ not valid\n"; next MAINMENU; #if tissue isn't provided
			} else {
				$tissue .= $TISSUE{$_}.",";
			}
		} chop $tissue;
		printerr "\nTISSUE(S) selected: $tissue\n";
		@tissue = split("\,",$tissue);
		foreach my $gene (@genes){
			foreach my $ftissue (@tissue) {
				my $syntax = "call usp_gdtissue(\"".$gene."\",\"".$ftissue."\",\"". $species."\")";
				$sth = $dbh->prepare($syntax);
				$sth->execute or die "SQL Error: $DBI::errstr\n";
				while (my ($genename, $max, $avg, $min) = $sth->fetchrow_array() ) {
					$AVGFPKM{$genename}{$ftissue} = "$max|$avg|$min";
				}
			}
		}
		$count = scalar keys %AVGFPKM;
	} elsif ($number == 0){
		pod2usage("ERROR:\tEmpty dataset, import data using tad-import.pl");
	} else {
		printerr "ERROR:\t Organism number was not valid \n"; next MAINMENU;
	}
  $t = Text::TabularDisplay->new(qw(GeneName Tissue MaximumFpkm AverageFpkm MinimumFpkm)); #header
	$precount = 0;
	foreach my $a (sort keys %AVGFPKM){ #preset to 10 rows
		unless ($precount >= 10) { 
			foreach my $b (sort keys % {$AVGFPKM{$a} }){
				unless ($precount >= 10) {
					my @all = split('\|', $AVGFPKM{$a}{$b}, 3);
					$precount++;
					$t->add($a, $b, $all[0], $all[1], $all[2]);
				}
			}
    }    
  }
	my $indent;
	if ($precount >= $count) {
		$indent = "";
	} else {
		$indent = "Only";
	}

	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n"; #print display
	
	if ($count >0 ) {
		printerr color('bright_black'); #additional procedure
		printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr "NOTICE:\t $indent $precount sample(s) displayed.\n";
		printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
		printerr "\ttad-export.pl --db2data --avgfpkm --species '$species' --gene '$genes' --tissue '$tissue'\n";
		printerr "\ttad-export.pl --db2data --avgfpkm --species '$species' --gene '$genes' --tissue '$tissue' --output output.txt\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr color('reset'); printerr "\n\n";
	} else {
		printerr "NOTICE:\t No Results based on search criteria: $genes\n";
	}
}

sub GENEXP {
	open(LOG, ">>", $_[1]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n"; # open log file
	printerr colored("E.\tGENE EXPRESSION ACROSS SAMPLES.", 'bright_red on_black'),"\n";
	$dbh = $_[0];
	my (%FPKM, %POSITION, %ORGANISM, %SAMPLE, %REALPOST, %CHROM, $species, $sample, $finalsample, $genes, $syntax, @row, $indent);
	$count = 0;
	$sth = $dbh->prepare("select distinct organism from vw_sampleinfo where genes is not null"); #get organisms
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	my $number = 0;
	while (my $row = $sth->fetchrow_array() ) {
		$number++;
		$ORGANISM{$number} = $row;
	}
	if ($number > 1) {
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nThe following organisms are available; select an organism : \n";
		foreach (sort {$a <=> $b} keys %ORGANISM) { print "  ", $_,"\.  $ORGANISM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\n ? : ";
		chomp ($verdict = int(<>)); print "\n";
	} else { $verdict = 1; }
	if ($verdict >= 1 && $verdict <= $number ) {
		$species = $ORGANISM{$verdict};
		$sth = $dbh->prepare("select sampleid from vw_sampleinfo where organism = '$species' and genes is not null"); #get samples
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		my $snumber= 0;
		while (my $row = $sth->fetchrow_array() ) {
			$snumber++;
			$SAMPLE{$snumber} = $row;
			$sample .= $row.",";
		} chop $sample;
		printerr "\nORGANISM : $species\n";
		$verdict = undef;
		if ($snumber > 1) {
			print color ('bold');
			print "--------------------------------------------------------------------------\n";
			print color('reset');
			foreach (sort {$a <=> $b || $a cmp $b} keys %SAMPLE) { print "  ", $_," :  $SAMPLE{$_}\n";}
			print color('bold');
			print "--------------------------------------------------------------------------\n";
			print color('reset');
			print "\nSelect sample (multiple samples can be separated by comma or 0 for all) ? ";
			chomp ($verdict = <>); print "\n";
		} else { $verdict = 0;}
		$SAMPLE{0} = $sample;
		$verdict =~ s/\s+//g;
		unless ($verdict) { $verdict = 0; }
		my @sample = split(",", $verdict); undef $sample;
		foreach (@sample) {
			unless (exists $SAMPLE{$_}){
				printerr "ERROR\t: Sample number $_ not valid\n"; next MAINMENU; #if sample is not provided
			} else {
				$sample .= $SAMPLE{$_}.",";
			}
		} chop $sample;
		if ($verdict =~ /^0/) {
			printerr "\nSAMPLE(S) selected: 'all samples for $species'\n";
		} else {
			printerr "\nSAMPLE(S) selected: $sample\n";
			$finalsample = $sample;
		}
		my @newsample;
		@sample = split("\,",$sample);
		if ($#sample > 1) {
			@newsample = @sample[0..1];
		} else { @newsample = @sample;}
		my @array = ("GENE", "CHROM", @newsample);
		$t = Text::TabularDisplay->new(@array);
		print "\nSelect genes (multiple genes can be separated by comma or 0 for all) ? "; #type in genes 
	  chomp ($verdict = uc(<>)); print "\n";
		$verdict =~ s/\s+//g;
		unless ($verdict) { $verdict = 0; }
		if ($verdict =~ /^0/) { 
			printerr "\nGENE(S) selected : 'all genes'\n";
			$syntax = "select geneshortname, fpkm, sampleid, chromnumber, chromstart, chromstop from GenesFpkm where sampleid in ("; #syntax
			foreach (@newsample) { $syntax .= "'$_',";} chop $syntax; $syntax .= ") order by geneid desc";
		}else {
			my @genes = split(",", $verdict);
			$genes = $verdict;
			printerr "\nGENE(S) selected : $verdict\n";
			$syntax = "select geneshortname, fpkm, sampleid, chromnumber, chromstart, chromstop from GenesFpkm where sampleid in (";
			foreach (@newsample) { $syntax .= "'$_',";} chop $syntax; $syntax .= ") and (";
			foreach (@genes) { $syntax .= " geneshortname like '%$_%' or"; } $syntax = substr($syntax, 0, -2); $syntax .= ") order by geneid desc";
		}
		$sth = $dbh->prepare($syntax);
		$sth->execute or die "SQL Error:$DBI::errstr\n";
		$count = 0;
		while (my ($gene_id, $fpkm, $library_id, $chrom, $start, $stop) = $sth->fetchrow_array() ) {
			$count++;
			$FPKM{"$gene_id|$chrom"}{$library_id} = $fpkm;
			$CHROM{"$gene_id|$chrom"} = $chrom;
			$POSITION{"$gene_id|$chrom"}{$library_id} = "$start|$stop";
		}
		
		foreach my $genest (sort keys %POSITION) {
			if ($genest =~ /^[0-9a-zA-Z]/){
				my $status = "nothing";
				my (@newstartarray,@newstoparray,$realstart, $realstop);
				foreach my $libest (sort keys % {$POSITION{$genest}} ){
					my @newposition = split('\|',$POSITION{$genest}{$libest},2);  
					my $status = "nothing";
				
					if ($newposition[0] > $newposition[1]) {
						$status = "reverse";
					}
					elsif ($newposition[0] < $newposition[1]) {
						$status = "forward";
					}
					push @newstartarray, $newposition[0];
					push @newstoparray, $newposition[1];
					
					if ($status =~ /forward/){
						$realstart = (sort {$a <=> $b} @newstartarray)[0];
						$realstop = (sort {$b <=> $a} @newstoparray)[0];
					}
					elsif ($status =~ /reverse/){
						$realstart = (sort {$b <=> $a} @newstartarray)[0];
						$realstop = (sort {$a <=> $b} @newstoparray)[0];
					}
					else { die "ERROR:\t Chromsomal position for $genest in sample $libest is unusual\n"; }
				}
				$REALPOST{$genest} = "$realstart|$realstop";
			}
		}
		$precount = 0;
		$indent = '';
		foreach my $genename (sort keys %FPKM){  
			if ($genename =~ /^[0-9a-zA-Z]/){
				if ($precount < 10) {
					my ($newrealstart,$newrealstop) = split('\|',$REALPOST{$genename},2);
					@row = ();
					my $realgenes = (split('\|',$genename))[0];
					push @row, ($realgenes, $CHROM{$genename}."\:".$newrealstart."\-".$newrealstop);
					foreach (0..$#newsample) { 
						if (exists $FPKM{$genename}{$newsample[$_]}){
							push @row, $FPKM{$genename}{$newsample[$_]};
						}
						else {
							push @row, "0";
						}
					} 
				} else { $indent = "Only"; next;} #adding the ten count conditionality
				$precount++;
				$t->add(@row);
			} 
		}
	} elsif ($number == 0){
		pod2usage("ERROR:\tEmpty dataset, import data using tad-import.pl");
	} else {
		printerr "ERROR:\t Organism number was not valid \n"; next MAINMENU;
	}

	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n"; #print display
	
	my ($dgenes, $dsamples);
	if ($genes) {$dgenes = "--gene '$genes'";}
	if ($finalsample) {$dsamples = " --samples '$sample'";}
	printerr color('bright_black'); #additional procedure
	printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "NOTICE:\t $indent $precount sample(s) displayed.\n";
	printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
	printerr "\ttad-export.pl --db2data --genexp --species '$species' $dgenes$dsamples\n";
	printerr "\ttad-export.pl --db2data --genexp --species '$species' $dgenes$dsamples --output output.txt\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr color('reset'); printerr "\n\n";
}

sub CHRVAR {
	open(LOG, ">>", $_[1]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n"; #open log file
	printerr colored("F.\tVARIANT CHROMOSOMAL DISTRIBUTION ACROSS SAMPLES.", 'bright_red on_black'),"\n";
	$dbh = $_[0];
	my (%VARIANTS, %SNPS, %INDELS, %ORGANISM, %SAMPLE, %CHROM, $species, $chromsyntax, $sample, $chromosome, $syntax, @row, @newsample, @sample, $indent);
	
	$count = 0;
	$sth = $dbh->prepare("select distinct organism from vw_sampleinfo where totalvariants is not null"); #get organism
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	my $number = 0;
	while (my $row = $sth->fetchrow_array() ) {
		$number++;
		$ORGANISM{$number} = $row;
	}
	if ($number > 1) {
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nThe following organisms are available; select an organism : \n";
		foreach (sort {$a <=> $b} keys %ORGANISM) { print "  ", $_,"\.  $ORGANISM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\n ? : ";
		chomp ($verdict = int(<>)); print "\n";
	} else { $verdict = 1; }
	if ($verdict >= 1 && $verdict <= $number ) {
		$species = $ORGANISM{$verdict};
		$sth = $dbh->prepare("select distinct sampleid from vw_sampleinfo where organism = '$species' and totalvariants is not null"); #get sampleids
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		my $snumber= 0;
		while (my $row = $sth->fetchrow_array() ) {
			$snumber++;
			$SAMPLE{$snumber} = $row;
			$sample .= $row.",";
		} chop $sample;
		printerr "\nORGANISM : $species\n";
		$verdict = undef;
		if ($snumber > 1) {
			print color ('bold');
			print "--------------------------------------------------------------------------\n";
			print color('reset');
			foreach (sort {$a <=> $b || $a cmp $b} keys %SAMPLE) { print "  ", $_," :  $SAMPLE{$_}\n";}
			print color('bold');
			print "--------------------------------------------------------------------------\n";
			print color('reset');
			print "\nSelect sample (multiple samples can be separated by comma or 0 for all) ? ";
			chomp ($verdict = <>); print "\n";
		} else { $verdict = 0;}
		$SAMPLE{0} = $sample;
		undef $sample;
		$verdict =~ s/\s+//g;
		unless ($verdict) { $verdict = 0; }
		if ($verdict =~ /^0/) {
			printerr "\nSAMPLE(S) selected : 'all samples'\n";
			$syntax = "select sampleid, chrom, count(*) from VarResult ";
			@sample = split(",", $SAMPLE{0});
		}else {
			@sample = split(",", $verdict);
			foreach (@sample) {
				if ($_ >= 1 && $_ <= $snumber) {
					$sample .= $SAMPLE{$_}.",";
				} else {
					printerr "ERROR:\t Sample number was not valid \n"; next MAINMENU;
				}
			} chop $sample;
			printerr "\nSAMPLE(S) selected: $sample\n";
			@sample = split(",",$sample);
			if ($#sample > 1) {
				@newsample = @sample[0..1];
			} else { @newsample = @sample;}
			$syntax = "select sampleid, chrom, count(*) from VarResult where sampleid in (";
			foreach (@newsample) { $syntax .= "'$_',";} chop $syntax; $syntax .= ") ";
		}
		$chromsyntax = "select distinct chrom from VarResult where sampleid in (";
		foreach (@sample) { $chromsyntax .= "'$_',";} chop $chromsyntax; $chromsyntax .= ") ";									 
		$chromsyntax .= "order by length(chrom), chrom";
		$t = Text::TabularDisplay->new(qw(SAMPLE CHROM VARIANTS SNPs INDELs));
		$sth = $dbh->prepare($chromsyntax);
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		$number = 0;
		while (my $row = $sth->fetchrow_array() ) {
			$number++;
			$CHROM{$number} = $row;
		}
		$verdict = undef;
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		foreach (sort {$a <=> $b || $a cmp $b} keys %CHROM) { print "  ", $_," :  $CHROM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nSelect chromosome (multiple chromosomes can be separated by comma or 0 for all) ? ";
	  chomp ($verdict = <>); print "\n";
		$verdict =~ s/\s+//g;
		unless ($verdict) { $verdict = 0; }
		unless ($verdict =~ /^0/) {
			unless ($syntax =~ /where/){ $syntax .= "where ("; }
			else { $syntax .= "and ("; }
			my @chromosomes = split(",", $verdict);
			foreach (@chromosomes) {
				$_ =int($_);
				if ($_ >= 1 && $_ <= $number) {
					$chromosome .= $CHROM{$_}.",";
				} else {
					printerr "ERROR:\t Chromosome number was not valid \n"; next MAINMENU;
				}
			} chop $chromosome;
			printerr "\nCHROMOSOME(S) selected : $chromosome\n";
		  @chromosomes = split(",", $chromosome);
			foreach (@chromosomes) { $syntax .= "chrom = '$_' or "; } $syntax = substr($syntax,0, -3); $syntax .= ") ";
		} else {
			printerr "\nCHROMOSOME(S) selected : 'all chromosomes'\n";
		}
		my $endsyntax = "group by sampleid, chrom order by sampleid, length(chrom),chrom";
		my $allsyntax = $syntax.$endsyntax; 
		$number = 0; 
		$sth = $dbh->prepare($allsyntax); 
		$sth->execute or die "SQL Error:$DBI::errstr\n";
		while (my ($sampleid, $chrom, $counted) = $sth->fetchrow_array() ) {
			$number++;
			$count++;
			$CHROM{$sampleid}{$number} = $chrom;
			$VARIANTS{$sampleid}{$chrom} = $counted;
		}
		$allsyntax = $syntax;
		unless ($allsyntax =~ /where/){ $allsyntax .= "where "; }
		else { $allsyntax .= "and "; }
		$allsyntax .= "variantclass = 'SNV' ".$endsyntax;
		$sth = $dbh->prepare($allsyntax); 
		$sth->execute or die "SQL Error:$DBI::errstr\n";
		while (my ($sampleid, $chrom, $counted) = $sth->fetchrow_array() ) {
			$SNPS{$sampleid}{$chrom} = $counted;
		}
		$allsyntax = $syntax;
		unless ($allsyntax =~ /where/){ $allsyntax .= "where "; }
		else { $allsyntax .= "and "; }
		$allsyntax .= "(variantclass = 'insertion' or variantclass = 'deletion') ".$endsyntax;
		$sth = $dbh->prepare($allsyntax);
		$sth->execute or die "SQL Error:$DBI::errstr\n";
		while (my ($sampleid, $chrom, $counted) = $sth->fetchrow_array() ) {
			$INDELS{$sampleid}{$chrom} = $counted;
		}
		$precount = 0;
		$indent = '';
		foreach my $ids (sort keys %VARIANTS){  
			if ($ids =~ /^[0-9a-zA-Z]/) {
				foreach my $no (sort {$a <=> $b} keys %{$CHROM{$ids} }) {
					if ($precount < 10) {
						@row = ();
						push @row, ($ids, $CHROM{$ids}{$no}, $VARIANTS{$ids}{$CHROM{$ids}{$no}});
						if (exists $SNPS{$ids}{$CHROM{$ids}{$no}}){
							push @row, $SNPS{$ids}{$CHROM{$ids}{$no}};
						}
						else {
							push @row, "0";
						}
						if (exists $INDELS{$ids}{$CHROM{$ids}{$no}}){
							push @row, $INDELS{$ids}{$CHROM{$ids}{$no}};
						}
						else {
							push @row, "0";
						}
					} else { $indent = "Only"; next;} #adding the ten count conditionality
					$precount++;
					$t->add(@row);
				}
			}
		}
	} elsif ($number == 0){
		pod2usage("ERROR:\tEmpty dataset, import data using tad-import.pl");
	} else {
		printerr "ERROR:\t Organism number was not valid \n"; next MAINMENU;
	}

	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n";
	
	my ($dchromosome, $dsamples);
	if ($chromosome) {$dchromosome = "--chromosome '$chromosome'";}
	if ($sample) {$dsamples = " --samples '$sample'";}
	printerr color('bright_black');
	printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "NOTICE:\t $indent $precount sample(s) displayed.\n";
	printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
	printerr "\ttad-export.pl --db2data --chrvar --species '$species' $dchromosome$dsamples\n";
	printerr "\ttad-export.pl --db2data --chrvar --species '$species' $dchromosome$dsamples --output output.txt\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr "--------------------------------------------------------------------------\n";
	printerr color('reset'); printerr "\n\n";
}

sub VARANNO {
	open(LOG, ">>", $_[2]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n";
	printerr colored("G.\tGENE ASSOCIATED VARIANTS ANNOTATION.", 'bright_red on_black'),"\n";
	$dbh = $_[0];
	$fastbit = $_[1];	
	my ($genes, %ORGANISM, %GENEVAR, @genes, $indent, $species);

	$count = 0;
	$sth = $dbh->prepare("select distinct a.organism from vw_sampleinfo a join VarSummary b on a.sampleid = b.sampleid where b.annversion is not null"); #get organism with annotation information
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	my $number = 0;
	while (my $row = $sth->fetchrow_array() ) {
		$number++;
		$ORGANISM{$number} = $row;
	}
	if ($number > 1) {
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nThe following organisms are available; select an organism : \n";
		foreach (sort {$a <=> $b} keys %ORGANISM) { print "  ", $_,"\.  $ORGANISM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\n ? : ";
		chomp ($verdict = int(<>)); print "\n";
	} else { $verdict = 1; } # else if there's only one organism
	if ($verdict >= 1 && $verdict <= $number ) {
		$species = $ORGANISM{$verdict};
		printerr "\nORGANISM : $species\n";
		$verdict = undef;
		print "\nSelect genes (multiple genes can be separated by comma) ? "; #ask for genes
	  chomp ($verdict = uc(<>)); 
		$verdict =~ s/\s+//g;
		unless ($verdict) { printerr "ERROR:\t Gene(s) not provided\n"; next MAINMENU; } # if genes aren't provided
		$genes = $verdict;
		printerr "\nGENE(S) selected : $genes\n";
		@genes = split(",", $verdict);
		foreach my $gene (@genes){
			
			#using fastbit
			my $syntax = "ibis -d $fastbit -q \"select chrom,position,refallele,altallele,variantclass,consequence,group_concat(genename),group_concat(dbsnpvariant), group_concat(sampleid) where genename like '%".$gene."%' and organism='$species'\" -o $_[3]";
			`$syntax 2>> $_[2]`;
			open(IN,'<',$_[3]); my @nosqlcontent = <IN>; close IN; `rm -rf $_[3]`;
			foreach (@nosqlcontent) {
				chomp;
				$count++;
				my @arraynosqlA = split (",",$_,3); foreach (@arraynosqlA[0..1]) { $_ =~ s/"//g;}
				my @arraynosqlB = split("\", \"", $arraynosqlA[2]); foreach (@arraynosqlB) { $_ =~ s/"//g ; $_ =~ s/NULL/-/g;}
				push my @row, @arraynosqlA[0..1], @arraynosqlB[0..3], join(",", uniq(sort(split(", ", $arraynosqlB[4])))) , join(",", uniq(sort(split(", ", $arraynosqlB[5])))), join (",", uniq(sort(split (", ", $arraynosqlB[6]))));
				$GENEVAR{$gene}{$arraynosqlA[0]}{$arraynosqlA[1]}{$arraynosqlB[3]} = [@row];
			}
			
			##using mysql
			# my $syntax = "call usp_vgene(\"".$species."\",\"".$gene."\")"; 
			# $sth = $dbh->prepare($syntax);
			# $sth->execute or die "SQL Error: $DBI::errstr\n";
			# while (my @row = $sth->fetchrow_array() ) {
			# 	$count++;
			# 	$GENEVAR{$gene}{$row[0]}{$row[1]} = [@row];
			# }
			
		}
	} elsif ($number == 0){
		pod2usage("ERROR:\tEmpty dataset, import data using tad-import.pl");
	} else {
		printerr "ERROR:\t Organism number was not valid \n"; next MAINMENU;
	}
  $t = Text::TabularDisplay->new(qw(Chrom Position Refallele Altallele Variantclass Consequence Genename Dbsnpvariant Sampleid)); #header
	$precount = 0;
	my ($odacount, $endcount) = (0,10);
	if ($#genes >= 1){ $endcount = 5*($#genes+1);}
	
	foreach my $aa (keys %GENEVAR){ #preset to 10 rows	
		unless ($precount >= $endcount) {
			if ($#genes >= 1) { if ($odacount == 5) {	$odacount = 0;} }
			foreach my $bb (sort {$a cmp $b || $a <=> $b} keys % {$GENEVAR{$aa} }){
				unless ($precount >= $endcount) {
					if ($#genes >= 1) { if ($odacount == 5) { last; } }		
					foreach my $cc (sort {$a <=> $b} keys % {$GENEVAR{$aa}{$bb} }) {
						unless ($precount >= $endcount) {
							if ($#genes >= 1) { if ($odacount == 5) { last; } }
							foreach my $dd (sort keys % {$GENEVAR{$aa}{$bb}{$cc} }) {
								unless ($precount >= $endcount) {
									if ($#genes >= 1) { if ($odacount == 5) { last; } }
									$precount++; $odacount++;
									$t->add($GENEVAR{$aa}{$bb}{$cc}{$dd});
								}
							}
						}
					}
				}
			}
		}
  }
	if ($precount >= $count) {
		$indent = "";
	} else {
		$indent = "Only";
	}

	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n"; #print display
	
	if ($count >0 ) {
		printerr color('bright_black'); #additional procedure
		printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr "NOTICE:\t $indent $precount sample(s) displayed.\n";
		printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
		printerr "\ttad-export.pl --db2data --varanno --species '$species' --gene '$genes' \n";
		printerr "\ttad-export.pl --db2data --varanno --species '$species' --gene '$genes' --output output.txt\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr color('reset'); printerr "\n\n";
	} else {
		printerr "NOTICE:\t No Results based on search criteria: $genes\n";
	}
}

sub CHRANNO {
	open(LOG, ">>", $_[2]) or die "\nERROR:\t cannot write LOG information to log file $_[1] $!\n";
	printerr colored("H.\tCHROMSOMAL REGION ASSOCIATED VARIANTS ANNOTATION.", 'bright_red on_black'),"\n";
	$dbh = $_[0];
	$fastbit = $_[1];
	my ($chromosome, %ORGANISM, %CHRVAR, %CHROM, @chromosomes, $species,$indent,$region);
	
	my $syntax = "ibis -d $fastbit -q \"select chrom,position,refallele,altallele,variantclass,consequence,group_concat(genename),group_concat(dbsnpvariant), group_concat(sampleid) where ";
	$count = 0;
	$sth = $dbh->prepare("select distinct a.organism from vw_sampleinfo a join VarSummary b on a.sampleid = b.sampleid where b.annversion is not null"); #get organism with annotation information
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	my $number = 0;
	while (my $row = $sth->fetchrow_array() ) {
		$number++;
		$ORGANISM{$number} = $row;
	}
	if ($number > 1) {
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nThe following organisms are available; select an organism : \n";
		foreach (sort {$a <=> $b} keys %ORGANISM) { print "  ", $_,"\.  $ORGANISM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\n ? : ";
		chomp ($verdict = int(<>)); print "\n";
	} else { $verdict = 1; } # else if there's only one organism
	if ($verdict >= 1 && $verdict <= $number ) {
		$species = $ORGANISM{$verdict};
		$syntax .= "organism='$species'";
		printerr "\nORGANISM : $species\n";
		$verdict = undef;
		$sth = $dbh->prepare("select distinct chrom from VarAnno where sampleid = (select sampleid from Sample a join Animal b on a.derivedfrom = b.animalid where b.organism = '$species' order by a.date desc limit 1) order by length(chrom), chrom");
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		$number = 0;
		while (my $row = $sth->fetchrow_array() ) {
			$number++;
			$CHROM{$number} = $row;
		}
		print color ('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		foreach (sort {$a <=> $b || $a cmp $b} keys %CHROM) { print "  ", $_," :  $CHROM{$_}\n";}
		print color('bold');
		print "--------------------------------------------------------------------------\n";
		print color('reset');
		print "\nSelect chromosome (multiple chromosomes can be separated by comma or 0 for all) ? ";
	  chomp ($verdict = <>); print "\n";
		$verdict =~ s/\s+//g;
		unless ($verdict) { $verdict = 0; }
		unless ($verdict =~ /^0/) {
			$syntax .= " and ";
			@chromosomes = split(",",$verdict);
			if ($#chromosomes > 0) {
				foreach (@chromosomes){
					$_ = int($_);
					if ($_ >= 1 && $_ <= $number) {
						$chromosome .= $CHROM{$_}.",";
					} else {
						printerr "ERROR:\tChromosome  number was not valid \n"; next MAINMENU;
					}
				} chop $chromosome;
				printerr "\nCHROMOSOME(S) selected : $chromosome\n";
				@chromosomes = split(",", $chromosome);
				foreach (@chromosomes) { $syntax .= "chrom = '$_' or "; } $syntax = substr($syntax, 0, -3);
			} else {
				$_ = int($chromosomes[0]);
				if ($_ >= 1 && $_ <= $number) {
					$chromosome .= $CHROM{$_};
				} else {
					printerr "ERROR:\tChromosome  number was not valid \n"; next MAINMENU;
				}
				#$chromosome = $CHROM{$chromosomes[0]};
				printerr "\nCHROMOSOME(S) selected : $chromosome\n";
				$syntax .= "chrom = '$chromosome' and ";
				print "\nSpecify region of interest (eg: 10000-500000) or 0 for the entire chromosome. ? "; #ask for region
				chomp ($verdict = uc(<>)); 
				$verdict =~ s/\s+//g;
				if ($verdict) {
					if ($verdict =~ /\-/) {
						my @region = split("-", $verdict);
						$syntax .= "position between $region[0] and $region[1] ";
						$region = "--region ".$region[0]."-".$region[1];
						printerr "\nREGION specified : between $region[0] and $region[1]\n";
					} else {
						my $start = $verdict-1500;
						my $stop = $verdict+1500;
						$syntax .= "position between ". $start." and ". $stop;
						$region = "--region ".$start."-".$stop;
						printerr "\nREGION specified : 3000bp region of $verdict\n";
					}
				}
			}
		} else {
			printerr "\nCHROMOSOME(S) selected : 'all chromosomes'\n";
		}
		
		$syntax .= "\" -o $_[3]"; 
		`$syntax 2>> $_[2]`;
		open(IN,'<',$_[3]); my @nosqlcontent = <IN>; close IN; `rm -rf $_[3]`;
		foreach (@nosqlcontent) {
			chomp;
			$count++;
			my @arraynosqlA = split (",",$_,3); foreach (@arraynosqlA[0..1]) { $_ =~ s/"//g;}
			my @arraynosqlB = split("\", \"", $arraynosqlA[2]); foreach (@arraynosqlB) { $_ =~ s/"//g ; $_ =~ s/NULL/-/g;}
			my @arraynosqlC = uniq(sort(split(", ", $arraynosqlB[4]))); if ($#arraynosqlC > 0 && $arraynosqlC[0] =~ /^-/){ shift @arraynosqlC; }
			push my @row, @arraynosqlA[0..1], @arraynosqlB[0..3], join(",", @arraynosqlC) , join(",", uniq(sort(split(", ", $arraynosqlB[5])))), join (",", uniq(sort(split (", ", $arraynosqlB[6]))));
			$CHRVAR{$arraynosqlA[0]}{$arraynosqlA[1]}{$arraynosqlB[3]} = [@row];
		}
	} elsif ($number == 0){
		pod2usage("ERROR:\tEmpty dataset, import data using tad-import.pl");
	} else {
		printerr "ERROR:\t Organism number was not valid \n"; next MAINMENU;
	}
  $t = Text::TabularDisplay->new(qw(Chrom Position Refallele Altallele Variantclass Consequence Genename Dbsnpvariant Sampleid)); #header
	$precount = 0;
	my ($odacount, $endcount) = (0,10);
	if ($#chromosomes >= 1){ $endcount = 5*($#chromosomes+1);}
	foreach my $aa (sort {$a cmp $b || $a <=> $b} keys %CHRVAR){ #preset to 10 rows	
		unless ($precount >= $endcount) {
			if ($#chromosomes >= 1) { if ($odacount == 5) {	$odacount = 0;} }
			foreach my $bb (sort {$a cmp $b || $a <=> $b} keys % {$CHRVAR{$aa} }){
				unless ($precount >= $endcount) {
					if ($#chromosomes >= 1) { if ($odacount == 5) { last; } }
					foreach my $cc (sort {$a cmp $b || $a <=> $b} keys % {$CHRVAR{$aa}{$bb} }){
						unless ($precount >= $endcount) {
							if ($#chromosomes >= 1) { if ($odacount == 5) { last; } }	
							$precount++; $odacount++;
							$t->add($CHRVAR{$aa}{$bb}{$cc});
						}
					}
				}
			}
		}
  }
	if ($precount >= $count) {
		$indent = "";
	} else {
		$indent = "Only";
	}

	printerr colored("$precount out of $count results displayed", 'underline'), "\n";
	printerr $t-> render, "\n\n"; #print display
	
	my ($dchromosome);
	if ($chromosome) {
		$dchromosome = "--chromosome '$chromosome'";
		if ($region) { $dchromosome .= " ".$region; }
	}
	if ($count >0 ) {
		printerr color('bright_black'); #additional procedure
		printerr "---------------------------ADDITIONAL PROCEDURE---------------------------\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr "NOTICE:\t $indent $precount sample(s) displayed.\n";
		printerr "PLEASE RUN EITHER THE FOLLOWING COMMANDS TO VIEW OR EXPORT THE COMPLETE RESULT.\n";
		printerr "\ttad-export.pl --db2data --varanno --species '$species' $dchromosome \n";
		printerr "\ttad-export.pl --db2data --varanno --species '$species' $dchromosome --output output.txt\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr "--------------------------------------------------------------------------\n";
		printerr color('reset'); printerr "\n\n";
	} else {
		printerr "NOTICE:\t No Results based on search criteria: $chromosome\n";
	}
}
1;
