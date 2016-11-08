#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use CC::Create;
use CC::Parse;
use DBD::mysql;

my %excel_content = %{content($ARGV[0])};

foreach $a (keys %excel_content){
  foreach $b (keys %{$excel_content{$a}}){
    print "column = $a\tnumber = $b\tresult = $excel_content{$a}{$b}\n";
  }
}

