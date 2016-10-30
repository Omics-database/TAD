#!/usr/bin/perl

#use strict;
use Spreadsheet::ParseExcel;

my $sourcename = shift @ARGV or die "invocation: $0 <source file>\n";
my $source_excel = new Spreadsheet::ParseExcel;
my $source_book = $source_excel->Parse($sourcename) or die "Could not open source Excel file $sourcename: $!";
my $storage_book;
my $check = 0;
foreach my $source_sheet_number (0 .. $source_book->{SheetCount}-1)
{
 my $source_sheet = $source_book->{Worksheet}[$source_sheet_number];

 my ( $row_first, $row_last ) = $source_sheet->row_range();
 my ( $col_first, $col_last ) = $source_sheet->col_range();

 my $name = $source_sheet->{Name};

 print "--------- SHEET:", $name, "\n";
 foreach my $col_index ($source_sheet->{MinCol} .. $source_sheet->{MaxCol})
 {
   $source_cell = $source_sheet->{Cells}[$source_sheet->{MinCol}][$col_index];
   $newres = $source_cell->{Value};
   $columnpos{$newres}{$col_index} = $col_index;
   $INDEX{$name}{$newres}{1} = 0;
   print "$name, $newres, $col_index,\n";
 }

foreach my $row_index (1 .. $source_sheet->{MaxRow}) {
  $dsheet = $source_sheet->{Cells}[$row_index][1];
  $dcell = $dsheet->{Value};
 # print "a",$dcell,"no\t";
  foreach my $col_index ($source_sheet->{MinCol} .. $source_sheet->{MaxCol}) {
   # $dsheet = $source_sheet->{Cells}[$row_index][1];
   # $dcell = $dsheet->{Value};
    #if (length($dcell) > 1) { 
#print "a",$dcell,"no\t";
      my $source_cell = $source_sheet->{Cells}[$row_index][$col_index];
      if ($source_cell) { #newsource) #length($newsource)>1) {
        $newsource = $source_cell->Value; 
  #      print $newsource,"\t";
      }
    } 
   # print "\n";
  #} 
}
}
print "done!\n";
