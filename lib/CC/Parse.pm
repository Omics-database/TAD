#package CC::Parse;
use strict;
use Spreadsheet::Read;

sub content {
  my $workbook = ReadData("$_[0]") or die "Error: Could not open excel file $_[0]\n";
  my ($odacontent, $source_cell);
  foreach my $source_sheet_number (1..length($workbook)) {
    my @rows = Spreadsheet::Read::rows($workbook->[$source_sheet_number]);
    my @column = Spreadsheet::Read::row($workbook->[$source_sheet_number],1);

    unless ($#rows < 0) {
      $odacontent .= "%%SHEET:$workbook->[$source_sheet_number]{label}\n";

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
    my @header = split('\?abc\?',$array[1]);
    foreach my $no (0..$#header){
      $columnpos{$array[0]}{$no} = "$array[0]%$header[$no]%$no";
    }
    foreach my $ne (2..$#array){
      my @value = split('\?abc\?', $array[$ne]);
      if (length $value[0] > 1){
        foreach my $na (0..$#value){
          $INDEX{$columnpos{$array[0]}{$na}}{$ne-2} = $value[$na];
        }
      }
    }
  }
  return \%INDEX;
}
1;
