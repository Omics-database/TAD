<?php				
	session_start();
	require_once('all_fns.php');
	tvariants(); 
?>
<?PHP
	//Database Attributes
	$table = "vw_sampleinfo";
	$Vartable = "VarResult";
?>

<div class="menu">TransAtlasDB Variant Distribution</div>
	<table width=80%><tr><td width="280pt">
	<div class="metactive"><a href="varsummary.php">Variants Distribution</a></div>
	<div class="metamenu"><a href="variants.php">Gene - Associated Variants</a></div>
	<div class="metamenu"><a href="varchroms.php">Variants - Chromosomal position </a></div>
	</td><td>
	<div class="dift"><p> View variants chromosomal distribution across samples.</p>

<?php
	@$species=$_GET['organism'];

	if(isset($species)){
		$query="SELECT sampleid FROM $table where organism='$species' and totalvariants is not null order by sampleid";
		$query2="SELECT distinct chrom FROM $Vartable where sampleid = (select distinct sampleid from $table where organism='$species' and totalvariants is not null order by sampleid limit 1) order by length(chrom), chrom"; 
	}else {
		$query ="SELECT sampleid FROM $table where organism is null and totalvariants is not null order by sampleid";
		$query2="SELECT distinct chrom FROM $Vartable where sampleid = (select distinct sampleid from $table where organism is null and totalvariants is not null order by sampleid limit 1) order by length(chrom), chrom";
	}

	if (!empty($_REQUEST['salute'])) {
		$_SESSION[$Vartable]['sample'] = $_POST['sample'];
		$_SESSION[$Vartable]['chromosome'] = $_POST['chromosome'];
		$_SESSION[$Vartable]['organism'] = $_POST['organism'];
	}
?>

  <div class="question">
  <form action="" method="post">
    <p class="pages"><span>Select Organism: </span>
    <select name="organism" onchange="reload(this.form)">
		<option value="" selected disabled >Select Organism</option>
		<?php
			foreach ($db_conn->query("select distinct organism from $table") as $row) {
				if($row["organism"]==@$species){ echo "<option selected value='$row[organism]'>$row[organism]</option><br>"; }
				else { echo '<option value="'.$row['organism'].'">'. $row['organism'].'</option>';}
			}
		?>
	</select></p>
	
	<table><tr><td><p class="pages"><span>Samples: </span>
	<select name="sample[]" id="sample" size=3 multiple="multiple">
		<option value="" selected disabled >Select Sample(s)</option>
		<?php
			foreach ($db_conn->query($query) as $row) {
				echo "<option value='$row[sampleid]'>$row[sampleid]</option>";
			}
		?>
	</select></td><td>
	
	<p class="pages"><span>Chromosomes: </span>
	<select name="chromosome[]" id="chromosome" size=3 multiple="multiple">
		<option value="" selected disabled >Select Chromosome(s)</option>
		<?php
			foreach ($db_conn->query($query2) as $row) {
				echo "<option value='$row[chrom]'>$row[chrom]</option>";
			}
		?>
		</select></p></td></tr></table>
<center><input type="submit" name="salute" value="View Results"></center>
</form>
</div>
  </td></tr></table>

<?php
	if (!empty($_POST['salute'])) {
		echo '<div class="menu">Results</div><div class="xtra">';
		$queryforoutput = "yes";
		$output = "OUTPUT/chrvar_".$explodedate.".txt";
		if (!empty($_POST['sample'])) { foreach ($_POST["sample"] as $sample){ $samples .= $sample. ","; } $samples = rtrim($samples,","); }
		if (!empty($_POST['chromosome'])) { foreach ($_POST["chromosome"] as $chromosome){ $chromosomes .= $chromosome. ","; } $chromosomes = rtrim($chromosomes,","); }
		
		if ((!empty($_POST['sample'])) && (!empty($_POST['organism'])) && (!empty($_POST['chromosome']))) {          
			$pquery = "perl $basepath/tad-export.pl -w -db2data -chrvar -species '$_POST[organism]' --chromosome '$chromosomes' --samples '$samples' -o $output";
		} elseif ((!empty($_POST['sample'])) && (!empty($_POST['organism']))) {          
			$pquery = "perl $basepath/tad-export.pl -w -db2data -chrvar -species '$_POST[organism]' --samples '$samples' -o $output";
		} elseif ((!empty($_POST['chromosome'])) && (!empty($_POST['organism']))) {          
			$pquery = "perl $basepath/tad-export.pl -w -db2data -chrvar -species '$_POST[organism]' --chromosome '$chromosomes' -o $output";
		} elseif (!empty($_POST['organism'])) {          
			$pquery = "perl $basepath/tad-export.pl -w -db2data -chrvar -species '$_POST[organism]' -o $output";
		}else {
			$queryforoutput = "no";
			echo "<center>Forgot something ?</center>";
		}
		//print $pquery;
		if ($queryforoutput == "yes") {
			shell_exec($pquery);
			if (file_exists($output)){
				echo '<form action="' . $phpscript . '" method="post">';
				echo '<p class="gened">Download the results below. ';
				$newbrowser = "results.php?file=$output&name=chromosomevariants.txt";
				echo '<input type="button" class="browser" value="Download Results" onclick="window.open(\''. $newbrowser .'\')"></p>';
				echo '</form>';
	
				// Get Tab delimted text from file
				$handle = fopen($output, "r");
				$contents = fread($handle, filesize($output)-1);
				fclose($handle);
				// Start building the HTML file
				print(tabs_to_table($contents));
			} else {
				echo '<center>No result based on search criteria.</center>';
			}
		}
	}
?>
  </div>
<?php
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
