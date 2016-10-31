#!/usr/bin/perl

$/="%%";
open(IN,"<csfile.csv") or die "cant";
@content = <IN>; close IN;
shift @content;
foreach (@content) {
#while (<IN>){ 
@array = split("\n", $_);
@header = split(",",$array[1]);
print $array[0],"\t",$header[$#header],"\n";
#print "$_ zzz\n\n\n";
}
