<?php
  session_start();
  require_once('atlas_header.php'); //Display heads
  require_once('atlas_fns.php'); //All the routines
  d_var_header();
  $json = file_get_contents('names/gtfgenename.json');
  $yummy = json_decode($json,true);
	if (!empty($_POST['lines'])){	$_SESSION['lines'] = $_POST['lines'];}
?>
  <script>
   $(function() {
      var availableTags = <?php include($_SESSION['variantlist']); ?>;
			function split( val ) {
				return val.split( /,\s*/ );
			}
			function extractLast( term ) {
				return split( term ).pop();
			}   
			$( "#genename" )
			// don't navigate away from the field on tab when selecting an item
			.on( "keydown", function( event ) {
				if ( event.keyCode === $.ui.keyCode.TAB &&
						$( this ).autocomplete( "instance" ).menu.active ) {
					event.preventDefault();
				}
			})
			.autocomplete({
				minLength: 0,
				source: function( request, response ) {
					// delegate back to autocomplete, but extract the last term
					response( $.ui.autocomplete.filter(
						availableTags, extractLast( request.term ) ) );
				},
				focus: function() {
					// prevent value inserted on focus
					return false;
				},
				select: function( event, ui ) {
					var terms = split( this.value );
					// remove the current input
					terms.pop();
					// add the selected item
					terms.push( ui.item.value );
					// add placeholder to get the comma-and-space at the end
					terms.push( "" );
					this.value = terms.join( ", " );
					return false;
				}
			});
    } );
  </script>
  <div id="metamenu">
	<ul>
		<li><a class="active" href="variants-genename.php">Gene Name</a></li>
		<?php
            $path = "variants-chromosome-".$_SESSION['genomename'].".php";
            echo "<li><a href=$path>Chromosomal Location</a></li>";
            ?>
	</ul>
</div>
  <div class="explain"><p><center>View variants based on a specific gene of interest.</center></p></div>
<?php
  if (!empty($_REQUEST['reveal'])) {
    // if the sort option was used
    $_SESSION['sname'] = $_POST['sname'];
  }
  $phpscript = "variants-genename.php";
  echo "<p class='pages'><span>Genome selected : ".$_SESSION['genomename']."</span>";
?>
  <input type="image" class="vbtn" src="images/return.png" align="texttop" alt="return" style="width:22px;height:22px;border-radius:30px;" value="variant" onclick="window.location.href='variants.php'"></span>
<?PHP
  echo '<div class="question">';
  echo '<form id="query" class="top-border" action="'.$phpscript.'" method="post">';
?>
  <div>
    <p class="pages"><span>Input the  Gene Name: </span>
      <?PHP
          if (!empty($_SESSION['sname'])) {
            echo '<input type="text" name="sname" id="genename" value="' . $_SESSION["sname"] . '"/>';
          } else {
            echo '<input type="text" name="sname" id="genename" placeholder="Enter Gene Name(s)" />';
          }
      ?>
    </p>
<?PHP
		if ($_SESSION['genomename'] == "Chicken"){
			echo '<p class="pages"><span>Select Lines <font size=2pt>(optional)</font>: </span>';
			echo '<select name="lines[]" id="lines" size=4 multiple="multiple">';
			echo '<option value="" selected disabled >Select Lines(s)</option>
        <option value="Ross">Ross</option>
        <option value="Illinois">Illinois</option>
        <option value="Ugandan">Ugandan</option>
				<option value="Fayoumi">Fayoumi</option>
				<option value="Fayoumi-Normal">Fayoumi-Normal</option>
				<option value="Fayoumi-chick%%HS">Fayoumi-chick HS</option>
				<option value="Fayoumi%%HC\&HS">Fayoumi HC&HS</option>
				option value="Fayoumi%%x%%Broiler">Fayoumi x Broiler</option>
				<option value="Broiler">Broiler</option>
				<option value="WLH">WLH</option>
				<option value="LMH">LMH</option>
				<option value="AIL-Normal">AIL-Normal</option>
				<option value="AIL%%HC\&HS">AIL HC&HS</option>';
      echo '</select>';
			echo '</p>';
		}
      ?>
    <br>
    <center><input type="submit" name="reveal" value="View Results" onClick="this.value='Sending… Please Wait'; style.backgroundColor = '#75684a'; this.form.submit();"></center>
  </div>
</form>
</div>
<hr>
<?PHP
  if ((isset($_POST['reveal']) || isset($_POST['downloadvalues'])) && !empty($_SESSION['sname'])) {
		$genenames = explode(", ",$_SESSION['sname']);
		foreach ($genenames as $sdef){
			$genens .= $sdef. ",";
		}
		$firstgene = array_values($genenames)[0];
		foreach ($yummy[$firstgene] as $sabc) { //getting chromosomal location for the gene
      $chrom = $sabc['chr'];
      if ($sabc['start'] <= 1500){$posstart = 1;}
      else { $posstart = $sabc['start']-1500;}
      $posend = $sabc['stop']+1500;
    }
		$genens = rtrim($genens,",");
		$output1 = "$base_path/OUTPUT/Voutput_".$explodedate.".par"; $output2 = "$base_path/OUTPUT/Voutput_".$explodedate.".txt";
    $pquery = 'perl '.$base_path.'/SQLscripts/fboutputvariantinfo.pl -g '.$genens.' -s '.$_SESSION['species'].' -o '.$output1;
		if ($_SESSION['lines']){
			foreach ($_SESSION["lines"] as $lines){
				$linez .= $lines. ",";
			}
			$linez = rtrim($linez,",");
			$pquery .= " -line ".$linez;
			$newbed = "OUTPUT/custom-".$explodedate.".bed";
			$pquery .= " $newbed $base_path/$newbed";
		} else { $newbed = 'gallus.bed';}
		//print $pquery;
    shell_exec($pquery);
    $prefix = 'http://genome.ucsc.edu/cgi-bin/hgTracks?db=galGal4&position=';
    $suffix = '&hgct_customText=http://raven.anr.udel.edu/~modupe/atlas/'.$newbed;
    $rquery = file_get_contents($output1); 
    $dloadquery = file_get_contents($output2); shell_exec ("rm -f ".$output2);
    if (count(explode ("\n", $rquery)) <= 14){
      echo '<center>No results were found with your search criteria.<br>N.B: Search is case-sensitive<center>';
    }
    else {
      $genename = $chrom.':'.$posstart.'-'.$posend;
      $browser = "$prefix$genename$suffix";
      echo '<div class="gened">';
      echo '<form action="' . $phpscript . '" method="post">';
      echo '<p class="gened">Below are the variants found. ';
      echo '<input type="submit" name="downloadvalues" value="Download Results"/>';
      echo '&nbsp;&nbsp;';
      echo '<input type="button" class="browser" value="Visualize Results" onclick="window.open(\''. $browser .'\')"><br>';
      echo $rquery;
      if(isset($_POST['downloadvalues'])){
        file_put_contents($output2, $dloadquery);
        print("<script>location.href='results.php?file=$output2&name=variants.txt'</script>");

      }

      echo '</form></div>';
      //shell_exec ("rm -f ".$output1);
    }
  }
?>
  </div>
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


