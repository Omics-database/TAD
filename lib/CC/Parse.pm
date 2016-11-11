#package CC::Parse;
use strict;
use Spreadsheet::Read;

sub excelcontent {
  my $workbook = ReadData("$_[0]") or pod2usage("Error: Could not open excel file \"$_[0]\"");
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
  our (%INDEX, %columnpos);
  my @content = split('%%', $odacontent);
  @content = @content[2..$#content]; 
  for (@content){s/%%//g;}
  foreach (@content) {
    my @array = split("\n", $_);
    my @header = split('\?abc\?',lc($array[1]));
    foreach my $no (0..$#header){
      $columnpos{$array[0]}{$no} = "$array[0]%$header[$no]";
    }
    foreach my $ne (2..$#array){
      my @value = split('\?abc\?', $array[$ne]);
      if (length $value[0] > 1){
        foreach my $na (0..$#value){
          $INDEX{$ne}{$columnpos{$array[0]}{$na}} = $value[$na];
        }
      }
    }
  }
  return \%INDEX;
}

sub tabcontent {
  open (BOOK,"<",$_[0]) or pod2usuage ("Error: Could not open source file \"$_[0]\"");
  my @content = <BOOK>; close (BOOK); chomp @content;
  our (%INDEX, %columnpos);
  my @header = split("\t", $content[0]);
  foreach my $no (0..$#header){
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

sub FPKM { #subroutine for  importing the FPKM values
  open(FPKM, "<", $_[1]) or die "Can not open file $_[1]\n";
  my $dbh = $_[3];
  my $syntax = "insert into $_[0] (sampleid, trackingid, classcode, nearestrefid, geneid, geneshortname, tssid, chromnumber, chromstart, chromstop, length, coverage, fpkm, fpkmconflow, fpkmconfhigh, fpkmstatus ) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
  my $sth = $dbh->prepare($syntax);
  while (<FPKM>){
    chomp;
    my ($track, $class, $ref_id, $gene, $gene_name, $tss, $locus, $length, $coverage, $fpkm, $fpkm_low, $fpkm_high, $fpkm_stat ) = split /\t/;
    unless ($track eq "tracking_id"){ #check & specifying undefined variables to null
      if($class =~ /-/){$class = undef;} if ($ref_id =~ /-/){$ref_id = undef;}
      if ($length =~ /-/){$length = undef;} if($coverage =~ /-/){$coverage = undef;}
      my ($chrom_no, $chrom_start, $chrom_stop) = $locus =~ /^(.+)\:(.+)\-(.+)$/;
      $sth ->execute($_[2], $track, $class, $ref_id, $gene, $gene_name, $tss, $chrom_no, $chrom_start, $chrom_stop, $length, $coverage, $fpkm, $fpkm_low, $fpkm_high, $fpkm_stat );
    }
  } close FPKM;
  $sth->finish();
}
1;
