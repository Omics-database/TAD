#!/usr/bin/perl
%INDEX;
$/="%%";
open(IN,"<csfile.csv") or die "cant";
@content = <IN>; close IN;
@content = @content[2..$#content];
for (@content){s/%%//g;}
foreach (@content) {
  @array = split("\n", $_);
  @header = split('\?abc\?',$array[1]);
  foreach my $no (0..$#header){
    $columnpos{$array[0]}{$no} = "$array[0]%$header[$no]%$no";
  }
  foreach my $ne (2..$#array){
    @value = split('\?abc\?', $array[$ne]); 
    if (length $value[0] > 1){ 
      foreach $na (0..$#value){
        $INDEX{$columnpos{$array[0]}{$na}}{$ne-2} = $value[$na];
      }
    }
  }
}
#"$array[0]%$print "$no $value[0]\n";}
#    else { print "yes \t\t";} 
 # }
#print "$_ zzz\n\n\n";
#}

foreach $a (keys %INDEX){
  foreach $b (keys %{$INDEX{$a}}){
 #   foreach $c (keys %{$INDEX{$a}{$b}}){
    print "column = $a\tnumber = $b\tresult = $INDEX{$a}{$b}\n";
#     }
  }
}
