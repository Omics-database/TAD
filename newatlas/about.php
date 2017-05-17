<?php				
	session_start();
	require_once('all_fns.php');
	tmetadata(); 
?>
<?PHP
	//Database Attributes
	$table = "vw_metadata";
	$statustable1 = "GeneStats";
	$statustable2 = "VarSummary";
	$query = "select $table.sampleid, $table.animalid, $table.organism, $table.tissue, $table.sampledescription, $table.date ,$statustable1.status as genestatus, $statustable2.status as variantstatus from $table left outer join $statustable1 on $table.sampleid = $statustable1.sampleid left outer join $statustable2 on $statustable2.sampleid = $table.sampleid ";
?>
	<div class="menu">TransAtlasDB Summary</div>
	<table width=80% ><tr><td valign="top" width=280pt>
	<div class="metamenu"><a href="about.php?quest=organism">Organisms</a></div>
	<div class="metamenu"><a href="about.php?quest=samples">Samples</a></div>
	<div class="metamenu"><a href="about.php?quest=samplesprocessed">Samples Processed</a></div>
	<div class="metamenu"><a href="about.php?quest=database">Database content</a></div>
	</td><td valign="top">
		

<?php
	//create query for DB display
	if ($_GET['quest'] == 'organism') {
		$result = $db_conn->query("select Organism, count(*) as Count from Animal group by organism");
		$result2 = $db_conn->query("select count(*) from Animal"); #FINAL ROW
		echo '<div class="dift"><p>Summary of Organisms.</p>';
		about_display($result, $result2);
	} elseif ($_GET['quest'] == 'samples') {
		$result = $db_conn->query("select Organism, Tissue, count(*) Count from Animal a join Sample b on a.animalid = b.derivedfrom group by organism, tissue");
		$result2 = "null";
		echo '<div class="dift"><p>Summary of Samples.</p>';
		about_display($result, $result2);
	} elseif ($_GET['quest'] == 'samplesprocessed') {
		$result = $db_conn->query("select a.organism Organism, format(count(b.sampleid),0) Recorded, format(count(c.sampleid),0) Processed , format(count(d.sampleid),0) Genes, format(count(e.sampleid),0) Variants from Animal a join Sample b on a.animalid = b.derivedfrom left outer join vw_sampleinfo c on b.sampleid = c.sampleid left outer join GeneStats d on c.sampleid = d.sampleid left outer join VarSummary e on c.sampleid = e.sampleid group by a.organism");
		$result2 = $db_conn->query("select format(count(b.sampleid),0), format(count(c.sampleid),0), format(count(d.sampleid),0), format(count(e.sampleid),0) from Animal a join Sample b on a.animalid = b.derivedfrom left outer join vw_sampleinfo c on b.sampleid = c.sampleid left outer join GeneStats d on c.sampleid = d.sampleid left outer join VarSummary e on c.sampleid = e.sampleid"); #FINAL ROW
		echo '<div class="dift"><p>Summary of Samples processed.</p>';
		about_display($result, $result2);
	} elseif ($_GET['quest'] == 'database') {
		$result = $db_conn->query("select organism Species, format(sum(genes),0) Genes, format(sum(totalvariants),0) Variants from vw_sampleinfo group by species");
		$result2 = $db_conn->query("select format(sum(genes),0) Genes, format(sum(totalvariants ),0) Variants from vw_sampleinfo"); #FINAL ROW
		echo '<div class="dift"><p>Summary of Database Content.</p>';
		about_display($result, $result2);
	} else {
		$result = $db_conn->query("select Organism, count(*) as Count from Animal group by organism");
		$result2 = $db_conn->query("select count(*) from Animal"); #FINAL ROW
		echo '<div class="dift"><p>Summary of Organisms.</p>';
		about_display($result, $result2);
	}

	if ($db_conn->errno) {
		echo "<div>";
		echo "<span><strong>Error with query.</strong></span>";
		echo "<span><strong>Error number: </strong>$db_conn->errno</span>";
		echo "<span><strong>Error string: </strong>$db_conn->error</span>";
		echo "</div>";
	}
?>
<!-- QUERY -->

</div>
</td></tr>
</table>
  </div>
<?php
  //$result ->free();
  $db_conn->close();
?>

<!-- <a class="back-to-top" style="display: inline;" href="#"><img src="images/backtotop.png" alt="Back To Top" width="45" height="45"></a>
<script src=”//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js”></script>
    <script>
      jQuery(document).ready(function() {
        var offset = 250;
        var duration = 300;
        jQuery(window).scroll(function() {
          if (jQuery(this).scrollTop() > offset) {
            jQuery(‘.back-to-top’).fadeIn(duration);
          } else {
            jQuery(‘.back-to-top’).fadeOut(duration);
          }
        });
 
        jQuery(‘.back-to-top’).click(function(event) {
          event.preventDefault();
          jQuery(‘html, body’).animate({scrollTop: 0}, duration);
          return false;
        }) 
      });
    </script>-->
</body>
</html>
