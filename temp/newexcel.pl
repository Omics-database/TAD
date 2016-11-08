#!/usr/bin/perl
use Spreadsheet::Read;
use Data::Printer;

my $workbook = ReadData("$ARGV[0]");
p $workbook;
