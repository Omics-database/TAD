<?php				
	session_start();
	require_once('all_fns.php');
	tvariants(); 
?>
<?PHP
	//Database Attributes
	$table = "vw_sampleinfo";
	$Varstats = "variants";
?>

<div class="menu">TransAtlasDB Gene - Variant Information</div>
	<table width=80%><tr><td width="280pt">
	<div class="metamenu"><a href="varsummary.php">Variants Distribution</a></div>
	<div class="metactive"><a href="variants.php">Gene - Associated Variants</a></div>
	<div class="metamenu"><a href="varchroms.php">Variants - Chromosomal position </a></div>
	</td><td>
	<div class="dift"><p> View variants based on a specific gene of interest.</p>

<?php
	@$species=$_GET['organism'];

	if(isset($species)){
		$query="SELECT DISTINCT tissue FROM $table where organism='$species' order by tissue"; 
	}else{ $query ="SELECT DISTINCT tissue FROM $table order by tissue"; }

	if (!empty($_REQUEST['salute'])) {
		$_SESSION[$Varstats]['organism'] = $_POST['organism'];
		$_SESSION[$Varstats]['search'] = $_POST['search'];
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

    <p class="pages"><span>Specify your gene name: </span>
	<?php
		if (!empty($_SESSION[$Varstats]['search'])) {
		  echo '<input type="text" name="search" id="genename" size="35" value="' .$_SESSION[$Varstats]['search']. '"/></p>';
		} else {
		  echo '<input type="text" name="search" id="genename" size="35" placeholder="Enter Gene Name(s)" /></p>';
		}
	?><br><br>
<center><input type="submit" name="salute" value="View Results"></center>
</form>
</div>
  </td></tr></table>

<?php
	if (!empty($_POST['salute'])) {
		echo '<div class="menu">Results</div><div class="xtra">';
		if ((!empty($_POST['organism'])) && (!empty($_POST['search']))) {          
			$output = "OUTPUT/variants_".$explodedate.".txt";
			$genenames = rtrim($_POST['search'],",");
			$pquery = "perl $basepath/tad-export.pl -w -db2data -varanno -species '$_POST[organism]' --gene '".strtoupper("$genenames")."' -o $output";
			//print $pquery;
			shell_exec($pquery);
			if (file_exists($output)){
				echo '<form action="' . $phpscript . '" method="post">';
				echo '<p class="gened">Download the results below. ';
				$newbrowser = "results.php?file=$output&name=genevariant.txt";
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
		} else {
			echo "<center>Forgot something ?</center>";
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
