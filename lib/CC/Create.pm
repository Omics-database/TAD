#package CC::Create;
use strict;
use warnings;
use DBI;

sub DEFAULTS {
  my $default = "https://github.com/modupeore/TAD";
  return $default;
}

sub clean {
  $_[0] =~ s/^\s+|\s+$//g;
  return $_[0];
}

sub mysql {
  my $dsn = 'dbi:mysql:'.$_[0];
  my $dbh = DBI -> connect($dsn, $_[1], $_[2]) or die "Connection Error: $DBI::errstr\n";
  return $dbh;
}
sub fastbit {
  my $ffastbit = "$_[0]/$_[1]";
  return $ffastbit;
}

sub connection {
  our %DBS = ("MySQL", 1,"FastBit", 2,);
  our %interest = ("username", 1, "password", 2, "databasename", 3, "path", 4, "foldername", 5);
  my %ALL;
  my $get =dirname(abs_path($0))."/$_[0]";
  open (CONTENT, $get) or die "Error: Can't open \"$_[0]\" for reading\n"; 
  my @contents = <CONTENT>; close (CONTENT);
  my $nameofdb; 
  foreach (@contents){
    chomp;
    if(/\S/){
      $_= &clean($_);
      if (exists $DBS{$_}) {
        $nameofdb = $_;
      }
      else {
        my @try = split " ";
        if (exists $interest{$try[0]}){
          if ($try[1]) {
            $ALL{"$nameofdb-$try[0]"} = $try[1];
          }
          else { pod2usage("Error: \"$nameofdb-$try[0]\" option in $_[0] file is blank"); }
        }
        else {
          die "Error: variable $try[0] is not a valid argument consult template $_[1]";
        }
      }
    }
  } 
  return \%ALL;
}
1;
