#package My::Math;
use strict;
use warnings;
 
use Exporter qw(import);
 
our @EXPORT_OK = qw(add multiply);
 
sub add {
  my ($x, $y) = @_;
  return $x + $y;
}
 
sub multiply {
  my ($x, $y) = @_;
  return $x * $y;
}
 
sub DEFAULTS {
  my $default = "https://github.com/modupeore/TAD";
  return $default;
}
sub clean {
  my $id = $_[0];
  $id =~ s/^\s+|\s+$//g;
  return $id;
}
1;
