<?php
  session_start();
  require_once('atlas_header.php'); //Display heads
  require_once('atlas_fns.php'); //All the routines
  d_geneexp_header(); //Display header
  $phpscript = "geneexp.php";
?>
<?php
  
  if (!empty($_REQUEST['salute']) && (!empty($_POST['tissue'])) &&
      (!empty($_POST['species'])) && (!empty($_POST['search']))) {
    $col1 = $_POST['col1'];
		$col2 = $_POST['col2'];
		$col3 = $_POST['col3'];
		$_POST['tissue'] = $_POST['tissue'];
    $_POST['species'] = $_POST['species'];
    $genes = explode(",",$_POST['search']);
		foreach ($genes as $gene){
			$genenames .= $gene.",";
		}
		$_POST['gselect'] = $_POST['search'];
  }
?>
<?php
  echo '<div class="question">';
  echo '<form id="querys" class="top-border" action="'.$phpscript.'" method="post">';
?>               
    <p class="pages"><span>Species: </span>
    <select name="species" id="species" required>
      <option value="" disabled >Select A Species</option>
      <option value="gallus" selected <?php if ($_POST['species']=='gallus') echo 'selected="selected"'; ?> >gallus</option>
	<option value="mus_musculus" <?php if ($_POST['species']=='mus_musculus') echo 'selected="selected"'; ?> >mus_musculus</option>
	<option value="alligator_mississippiensis" <?php if ($_POST['species']=='alligator_mississippiensis') echo 'selected="selected"'; ?> >alligator_mississippiensis</option>
    </select>
    </p>
    <p class="pages"><span>Specify your gene name: </span>
<?php
  if (!empty($_POST['gselect'])) {
    echo '<input type="text" name="search" id="genename" size="35" value="' . $_POST["gselect"] . '"/></p>';
  } else {
    echo '<input type="text" name="search" id="genename" size="35" placeholder="Enter Gene Name(s)" /></p>';
  }
?> 
    <div id="gallus">
      <p class="pages"><span>Tissue(s) of interest: </span>
      <select name="tissue[]" id="tissue" size=5 multiple="multiple">
        <option value="" selected disabled >Select Tissue(s)</option>
        <option value="liver">liver</option>
        <option value="embryonic_brain">embryonic brain</option>
        <option value="spleen">spleen</option>
        <option value="thymus">thymus</option>
        <option value="bursa">bursa</option>
        <option value="kidney">kidney</option>
        <option value="ileum">ileum</option>
        <option value="jejunum">jejunum</option>
        <option value="duodenum">duodenum</option>
        <option value="ovary">ovary</option>
        <option value="heart">heart</option>
        <option value="lung">lung</option>
        <option value="'breast muscle'">breast muscle</option>
        <option value="LMH">LMH</option>
        <option value="brain">brain</option>
        <option value="WLH">WLH</option>
        <option value="pineal">pineal</option>
        <option value="retina">retina</option>
        <option value="Hypothalamus">Hypothalamus</option>
        <option value="Pituitary">Pituitary</option>
        <option value="'Primordial Germ Cell'">Primordial Germ Cell</option>
        <option value="'Abdominal Adipose'">Abdominal Adipose</option>
        <option value="'Cardiac Adipose'">Cardiac Adipose</option>
      </select></p>
			<p class=pages><span>Order columns : </span>
			<select name="col1" id="test" required>
				<option value="" selected disabled >Column 1</option>
				<option value="tissue" selected >tissue</option>
				<option value="line">line</option>
				<option value="genename">gene name</option>
	    </select>
			<select name="col2" id="test" required>
				<option value="" selected disabled >Column 2</option>
				<option value="tissue" >tissue</option>
				<option value="line" selected >line</option>
				<option value="genename" >gene name</option>
	    </select>
			<select name="col3" id="test" required>
				<option value="" selected disabled >Column 3</option>
				<option value="tissue">tissue</option>
				<option value="line" >line</option>
				<option value="genename" selected>gene name</option>
			</select>
			</p>
    </div>
    <div id="mus_musculus">
      <p class="pages"><span>Tissue of interest: </span>
      <select name="tissue[]" id="tissue" size=2 multiple="multiple">
        <option value="" selected disabled >Select A Tissue</option>
        <option value="lung">lung</option>
      </select></p>
    </div>
    <div id="alligator_mississippiensis">
      <p class="pages"><span>Tissue(s) of interest: </span>
        <select name="tissue[]" id="tissue" size=5 multiple="multiple">
        <option value="" selected disabled >Select A Tissue</option>
        <option value="Adipose">Adipose</option>
        <option value="Belly_skin">Belly skin</option>
        <option value="Blood">Blood</option>
        <option value="cerebrum">cerebrum</option>
        <option value="chin_gland">chin_gland</option>
        <option value="eye">eye</option>
        <option value="heart">heart</option>
        <option value="kidney">kidney</option>
        <option value="liver">liver</option>
        <option value="midbrain">midbrain</option>
        <option value="olfactory_bulb">olfactory_bulb</option>
        <option value="ovary">ovary</option>
        <option value="spinal_cord">spinal_cord</option>
        <option value="spleen">spleen</option>
        <option value="stomach">stomach</option>
        <option value="testes">testes</option>
        <option value="thalmus">thalmus</option>
        <option value="throat_scent_gland">throat_scent_gland</option>
        <option value="tongue">tongue</option>
        <option value="tooth">tooth</option>
        <option value="white_matter">white_matter</option>
      </select></p>
		</div><br>
<center><input type="submit" name="salute" value="View Results" onClick="this.value='Sending… Please Wait'; style.backgroundColor = '#75684a'; this.form.submit();"></center>
</form>
</div>
<hr>

<?php
  if (!empty($_POST['salute']) && (!empty($_POST['tissue'])) &&
      (!empty($_POST['species'])) && (!empty($_POST['search']))) {          
    if(($col1 == $col2) || ($col2 == $col3) || ($col3 == $col1)){
			echo "<center>Error in Column orientation</center>";
		} else {
			$output = "$base_path/OUTPUT/GeneExp_".$explodedate;
			$output1 = "$base_path/OUTPUT/GeneExp_".$explodedate.".txt";
			foreach ($_POST["tissue"] as $tissue){
			$tissues .= $tissue. ",";
			}
			$tissues = rtrim($tissues,",");
			$genenames = rtrim($genenames,", ");
			$pquery = "perl ".$base_path."/SQLscripts/outputgeneslist.pl -1 '".$genenames."' -2 ".$tissues." -3 ".$_POST['species']." -o ".$output." -col1 ".$_POST['col1']." -col2 ".$_POST['col2']." -col3 ".$_POST['col3']."";
			//print $pquery;
			$rquery = shell_exec($pquery); 
			if (count(explode ("\n", $rquery)) > 11){
				echo '<div class="gened">';
				echo '<form action="' . $phpscript . '" method="post">';
				echo '<p class="gened">Download the results below. ';
				$newbrowser = "results.php?file=$output1&name=genes-stats.txt";
				echo '<input type="button" class="browser" value="Download Results" onclick="window.open(\''. $newbrowser .'\')"><br>';

				echo '</form></div>';
			
			
				echo '<div class="cexpand">'.$rquery.'</div><br>';
		  } else {
				echo '<div class="cexpand">No result based on search criteria</div><br>';
			}
    }
  } elseif (!empty($_POST['salute'])) {
		echo "<center>Forgot something ?</center>";
	}
?>
  </div>
<?php
  $db_conn->close();
?>
  </div> <!--in header-->		
<a class="back-to-top" style="display: inline;" href="#"><img src="images/backtotop.png" alt="Back To Top" width="45" height="45"></a>
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
    </script>
</body>
</html>
