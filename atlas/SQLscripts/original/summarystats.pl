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
my (%PRO, %KEY);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - M A I N  W O R K F L O W - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#TABLE COLUMNS
$syntax = "select a.species Species, format(count(a.species),0) Recorded, format(count(b.species),0) Processed
            from bird_libraries a left outer join vw_libraryinfo b on a.library_id = b.library_id
            group by a.species";

$sth = $dbh->prepare($syntax);
$sth->execute or die "SQL Error: $DBI::errstr\n";
 
while (my ($species, $recorded, $processed) = $sth->fetchrow_array() ) {
    $KEY{$species} = $recorded;
    $PRO{$species} = $processed;
}
print "<table class=\"summary\">
        <tr>
          <th class=\"summary\">Species</th>
          <th class=\"summary\">Recorded</th>
          <th class=\"summary\">Processed</th>
        </tr>\n";
foreach my $first (sort {$a cmp $b} keys %KEY){
  print "<tr><td class=\"summary\"><b>$first</b></td>
            <td class=\"summary\">$KEY{$first}</td>
            <td class=\"summary\">$PRO{$first}</td></tr>\n";
}
#Final Row
$syntax = "select format(count(a.species),0) Recorded, format(count(b.species),0) Processed from bird_libraries a left outer join vw_libraryinfo b
            on a.library_id = b.library_id";
$sth = $dbh->prepare($syntax);
$sth->execute or die "SQL Error: $DBI::errstr\n";
while (my ($recorded, $processed) = $sth->fetchrow_array() ) {
 print "<tr><th class=\"summary\"><b>Total</b></td>
            <td class=\"summary\"><b>$recorded</b></td>
            <td class=\"summary\"><b>$processed</b></td></tr>\n"; 
}
print "</table>\n";

# DISCONNECT FROM THE DATABASE
$sth->finish();
$dbh->disconnect();

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - -T H E  E N D - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit;
