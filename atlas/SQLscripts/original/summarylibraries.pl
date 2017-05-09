#!/usr/bin/perl
use strict;
use DBI;
use lib '/home/modupe/SCRIPTS/SUB';
use passw;
use routine;

# DATABASE VARIABLES
my ($dbh, $sth, $syntax);
our ($VERSION, $DATE, $AUTHOR) = DEFAULTS;
$dbh = mysql();

#HASH TABLES
my (%SNP, %GEN, %VAR, %IND);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N  W O R K F L O W - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#TABLE COLUMNS
$syntax = "select species Species, format(sum(genes),0) Genes, format(sum(total_VARIANTS ),0) Variants from vw_libraryinfo group by species";

$sth = $dbh->prepare($syntax);
$sth->execute or die "SQL Error: $DBI::errstr\n";
 
while (my ($species, $genes, $variants) = $sth->fetchrow_array() ) {
    $GEN{$species} = $genes;
    $VAR{$species} = $variants;
}
print "<table class=\"summary\">
        <tr>
          <th class=\"summary\">Species</th>
          <th class=\"summary\">Genes</th>
          <th class=\"summary\">Variants</th>
        </tr>\n";
foreach my $first (sort {$a cmp $b} keys %GEN){
  print "<tr><td class=\"summary\"><b>$first</b></td>
            <td class=\"summary\">$GEN{$first}</td>
            <td class=\"summary\">$VAR{$first}</td></tr>\n";
}
#Final Row
$syntax = "select format(sum(genes),0) Genes, format(sum(total_VARIANTS ),0) Variants from vw_libraryinfo";
$sth = $dbh->prepare($syntax);
$sth->execute or die "SQL Error: $DBI::errstr\n";
while (my ($genes, $variants) = $sth->fetchrow_array() ) {
 print "<tr><th class=\"summary\"><b>Total</b></td>
            <td class=\"summary\"><b>$genes</b></td>
            <td class=\"summary\"><b>$variants</b></td></tr>\n"; 
}
print "</table>\n";

# DISCONNECT FROM THE DATABASE
$sth->finish();
$dbh->disconnect();

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - -T H E  E N D - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit;
