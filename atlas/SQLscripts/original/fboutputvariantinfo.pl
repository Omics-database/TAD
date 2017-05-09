#!/usr/bin/perl
use strict;
use Getopt::Long;
use Pod::Usage;
use lib '/home/modupe/SCRIPTS/SUB';
use routine;

#ARGUMENTS
my($gene,$begin,$species,$end,$chrom, $linez, $output,$help,$manual);
GetOptions(
			"1|g|in1|gene=s"	=>	\$gene,
                        "2|b|in2|begin=s"	=>	\$begin,
                        "3|e|in3|end=s"		=>	\$end,
                        "4|s|in4|species=s"	=>	\$species,
                        "5|c|in5|chrom=s"	=>	\$chrom,
                        "6|o|out|output=s"	=>	\$output,
			"7|line=s"	=>\$linez
);

my $AILHC = 'track type=vcfTabix name=\"AIL HC&HS\" description=\"AIL HC&HS\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/AIL%20HC\&HS.vcf.gz';

my $AIL = 'track type=vcfTabix name=\"AIL-Normal\" description=\"AIL-Normal\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/AIL-Normal.vcf.gz';

my $Broiler = 'track type=vcfTabix name=\"Broiler\" description=\"Broiler\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Broiler.vcf.gz';

my $CELC = 'track type=vcfTabix name=\"CELC\" description=\"CELC\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/CELC.vcf.gz';

my $FayoumiChick = 'track type=vcfTabix name=\"Fayoumi-chick HS\" description=\"Fayoumi-chick HS\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Fayoumi-chick%20HS.vcf.gz';

my $FayoumiHC = 'track type=vcfTabix name=\"Fayoumi HC&HS\" description=\"Fayoumi HC&HS\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Fayoumi%20HC\&HS.vcf.gz';

my $FayoumiNormal = 'track type=vcfTabix name=\"Fayoumi-Normal\" description=\"Fayoumi-Normal\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Fayoumi-Normal.vcf.gz';

my $Fayoumi = 'track type=vcfTabix name=\"Fayoumi\\" description=\"Fayoumi\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Fayoumi.vcf.gz';

my $FayoumiBroiler = 'track type=vcfTabix name=\"Fayoumi x Broiler\" description=\"Fayoumi x Broiler\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Fayoumi%20x%20Broiler.vcf.gz';

my $Illinois = 'track type=vcfTabix name=\"Illinois\" description=\"Illinois\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Illinois.vcf.gz';

my $LMH = 'track type=vcfTabix name=\"LMH\" description=\"LMH\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/LMH.vcf.gz';

my $Ross = 'track type=vcfTabix name=\"Ross\" description=\"Ross\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Ross.vcf.gz';

my $Ugandan = 'track type=vcfTabix name=\"Ugandan\" description=\"Ugandan\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/Ugandan.vcf.gz';

my $WLH = 'track type=vcfTabix name=\"WLH\" description=\"WLH\" bigDataUrl=http://raven.anr.udel.edu/~modupe/UCSC/WLH.vcf.gz';

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - G L O B A L  V A R I A B L E S- - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#DIRECTORY WHERE THE FILES ARE STORED
our ($chickenpath, $mousepath, $alligatorpath) = FBPATHS();

#PREFIX and SUFFIX for the browser
my $prefix = 'http://genome.ucsc.edu/cgi-bin/hgTracks?db=galGal4&position=';
my $suffix = '&hgct_customText=http://raven.anr.udel.edu/~modupe/atlas/gallus.bed';

##OUTPUT FILE (temporary and permanent)
my $tempoutput = substr($output,0,-4);
my $downloadoutput = substr($output,0,-4).".txt";

#QUERYING OPTIONS
my ($ibis, $syntax);
#HASH TABLES
my (%CHROM, %FPKM, %GENES, %number);

# OPENING OUTPUT FILE
open(OUT, '>', $output);
open(OUTDOWN, '>', $downloadoutput);
`rm -rf $ARGV[1]`; #remove the custom file
#print headers
print OUT "<table class=\"gened\">
      <tr>
        <th class=\"gened\">Chrom</th>
        <th class=\"gened\">Position</th>
        <th class=\"gened\">Ref</th>
        <th class=\"gened\">Alt</th>
        <th class=\"gened\">Class</th>
        <th class=\"gened\">Annotation</th>
        <th class=\"gened\">Gene Name</th>
        <th class=\"gened\">dbSNP</th>
        <th class=\"gened\">library_ids</th>
      </tr>\n";
print OUTDOWN "Line\tChrom\tPosition\tRef\tAlt\tClass\tAnnotation\tGene Name\tdbSNP\tlibrary_ids\n";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N  W O R K F L O W - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#TABLE COLUMNS
if ($species =~ /gallus/) {
  $ibis = "/home/modupe/.bin/bin/ibis -d $chickenpath -q \"";
  if ($chrom) {
    $syntax = "select line,chrom,position,ref,alt,class,consequence,
                genename,dbsnp,group_concat(library) where chrom = \'$chrom\' and position between $begin and $end";
  }
  elsif($gene) {
		my @genes = split(",",$gene);
		$syntax = "select line, chrom,position, ref, alt, class, consequence,
                genename, dbsnp,group_concat(library) where (";
		foreach (@genes){
			$syntax .= "genename = '$_' OR ";
		}
		$syntax = substr($syntax, 0, -3); $syntax .= ")";
  }
	if ($linez){
		$linez = uc($linez); #convert to uppercase
		my @lines = split(",",$linez);
		$syntax .= " AND (";
		foreach (@lines){
			$_ =~ s/%%/ /g;
			$syntax .= "line = '$_' OR ";
			if ($_ =~ /Ross/i){
				`echo $Ross >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Illinois/i){
				`echo $Illinois >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Ugandan/i){
				`echo $Ugandan >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Fayoumi/i){
				`echo $Fayoumi >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Fayoumi-Normal/i){
				`echo $FayoumiNormal >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /LMH/i){
				`echo $LMH >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Broiler/i){
				`echo $Broiler >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /WLH/i){
				`echo $WLH >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /AIL-Normal/i){
				`echo $AIL >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Fayoumi-chick HS/i){
				`echo $FayoumiChick >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Fayoumi HC&HS/i){
				`echo $FayoumiHC >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /Fayoumi x Broiler/i){
				`echo $FayoumiBroiler >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}
			elsif ($_ =~ /AIL HC&HS/i){
				`echo $AILHC >> $ARGV[1]`;
				`echo >> $ARGV[1]`;
			}	
		}
		$syntax = substr($syntax, 0, -3); $syntax .= ")";
		$suffix = '&hgct_customText=http://raven.anr.udel.edu/~modupe/atlas/'.$ARGV[0];
		
	}
	$syntax .= "\" -v -o ";
  print "$ibis$syntax$tempoutput\n\n";
  `$ibis$syntax$tempoutput`;
  
  open(IN,'<',$tempoutput);
  while (<IN>){
    chomp;
    my ($line, $chrom, $position, $ref, $alt, $class, $ann, $genename, $dbsnp, $library) = split(/\, /, $_, 10);
    #removing the quotation marks from the words
    $line = substr($line,1,-1);$chrom = substr($chrom,1,-1);
    $ref = substr($ref,1,-1); $alt = substr($alt,1,-1);
    $class = substr($class,1,-1); $ann = substr($ann,1,-1);
    $library = substr($library,1,-1); my $newlib = undef; my %solib;
    foreach (sort {$a <=> $b} split(",",$library)) { $solib{$_}=$_;}
    foreach (sort {$a <=> $b} keys %solib){ $newlib .= $_.", "};
    $newlib = substr($newlib,0,-2);
    $genename = substr($genename,1,-1); $dbsnp = substr($dbsnp,1,-1);
    if ($genename =~ /NULL/) { $genename = "-"; }
    if ($dbsnp =~ /NULL/) { $dbsnp = " "; }
    
    if (exists $number{$line}{$chrom}{$position}){
      $number{$line}{$chrom}{$position}= $number{$line}{$chrom}{$position}+1;
    }
    else {
      $number{$line}{$chrom}{$position} = 1;
    }
    #storing into a hash table.
    $GENES{$line}{$chrom}{$position}{$number{$line}{$chrom}{$position}} = "$ref|$alt|$class|$ann|$genename|$dbsnp|$newlib";
  }
  close (IN); 
  
  foreach my $a (sort keys %GENES){
    print OUT "<tr><th class=\"geneds\" colspan=100%>$a</th></tr>\n";
    foreach my $b (sort keys % {$GENES{$a} }){
      foreach my $c (sort keys % {$GENES{$a}{$b} }){
        foreach my $d (sort keys %{$GENES{$a}{$b}{$c}}){
          my @all = split('\|', $GENES{$a}{$b}{$c}{$d}, 7);
          print OUTDOWN "$a\t$b\t$c\t";
          print OUT "<tr><td class=\"gened\"><b>$b</b></td>",'<td class="gened"><b><a href="',$prefix;
	  print OUT $b,':',$c-1500,'-',$c+1500,$suffix,'" target="_blank">',"$c</b></td>";
        
          foreach my $ii (0..$#all-2){
            print OUTDOWN "$all[$ii]\t";
            print OUT "<td class=\"gened\">$all[$ii]</td>";
          }
	  if (length($all[$#all-1]) > 2) {
	    $all[$#all-1] =~ /rs(\d+)$/;
	    print OUT "<td class=\"gened\"><a href=\"https://www.ncbi.nlm.nih.gov/projects/SNP/snp_ref.cgi?rs=$1\" target=\"_blank\">$all[$#all-1]</a></td>";
	  } else {
	    print OUT "<td class=\"gened\">$all[$#all-1]</td>";
	  }
          print OUTDOWN "$all[$#all-1]\t$all[$#all]\n";
          my $finalcol = $all[$#all]; $finalcol =~ s/\s+//g;
          print OUT "<td class=\"gened\"><a href=\"metadata.php?libs=$finalcol\" target=\"_blank\">$all[$#all]</a></td></tr>\n";
        }
      }
    }
  }
  print OUT "</table>\n";
}
else {
  if ($species =~ /mus_musculus/) {$ibis = "ibis -d $mousepath -q \"";}
  elsif ($species =~ /alligator/) {$ibis = "ibis -d $alligatorpath -q \"";}
  if ($chrom) {
    $syntax = "select chrom,position,ref,alt,class,consequence,
                genename,dbsnp,group_concat(library) where chrom = \'$chrom\' and position between $begin and $end\" -v -o ";
  }
  elsif($gene) {
    $syntax = "select chrom,position,ref,alt,class,consequence,
                genename, dbsnp,group_concat(library) where genename = \'$gene\'\" -v -o ";
  }
  print "$ibis$syntax$tempoutput\n\n";
  `$ibis$syntax$tempoutput`;
  
  open(IN,'<',$tempoutput);
  while (<IN>){
    chomp;
    my ($chrom, $position, $ref, $alt, $class, $ann, $genename, $dbsnp, $library) = split(/\, /, $_, 9);
    #removing the quotation marks from the words
    $chrom = substr($chrom,1,-1);
    $ref = substr($ref,1,-1); $alt = substr($alt,1,-1);
    $class = substr($class,1,-1); $ann = substr($ann,1,-1);
    $library = substr($library,1,-1); my $newlib = undef; my %solib;
    foreach (sort {$a <=> $b} split(",",$library)) { $solib{$_}=$_;}
    foreach (sort {$a <=> $b} keys %solib){ $newlib .= $_.", "};
    $newlib = substr($newlib,0,-2);
    $genename = substr($genename,1,-1); $dbsnp = substr($dbsnp,1,-1);
    if ($genename =~ /NULL/) { $genename = "-"; }
    if ($dbsnp =~ /NULL/) { $dbsnp = " "; }
    
    #storing into a hash table.
    if (exists $GENES{$chrom}{$position}{"1"}){
      $number{$chrom}{$position} = $number{$chrom}{$position}++;
      $GENES{$chrom}{$position}{$number{$chrom}{$position}} = "$ref|$alt|$class|$ann|$genename|$dbsnp|$newlib";
    }
    else {
      $number{$chrom}{$position} = 1;
      $GENES{$chrom}{$position}{$number{$chrom}{$position}} = "$ref|$alt|$class|$ann|$genename|$dbsnp|$newlib";
    }
  }
  close (IN); 

  foreach my $a (keys %GENES){
    foreach my $b (sort keys % {$GENES{$a} }){
      foreach my $c (sort keys % {$GENES{$a}{$b} }){
        my @all = split('\|', $GENES{$a}{$b}{$c}, 7);
        print OUT "<tr><td class=\"gened\"><b>$a</b></td><td class=\"gened\"><b>$b</b></td>";
        print "<tr><td class=\"gened\"><b>$a</b></td><td class=\"gened\"><b>$b</b></td>";
        print OUTDOWN "$a\t$b\t";
        foreach my $ii (0..$#all-1){
          print OUTDOWN "$all[$ii]\t";
          print OUT "<td class=\"gened\">$all[$ii]</td>";
        }
        print OUTDOWN "$all[$#all]\n";
        print OUT "<td class=\"gened\">$all[$#all]</td></tr>\n";
      }
    }
  }
  print OUT "</table>\n";
}

close (OUT); close (OUTDOWN);
exit;


