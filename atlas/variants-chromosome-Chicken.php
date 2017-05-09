<?php
  session_start();
  require_once('atlas_header.php'); //Display heads
  require_once('atlas_fns.php'); //All the routines
  d_var_header();
?>
  <div id="metamenu">
	<ul>
		<li><a href="variants-genename.php">Gene Name</a></li>
		<?php
            $phpscript = "variants-chromosome-".$_SESSION['genomename'].".php";
            echo "<li><a class='active' href=$path>Chromosomal Location</a></li>";
            ?>
	</ul>
</div>
  <div class="explain"><p><center>View variants based on a chromosomal location.</center></p></div>
<?php
  if (!empty($_REQUEST['reveal'])) {
    // if the sort option was used
    $_SESSION['chromposend'] = $_POST['chromposend'];
    $_SESSION['chrompos'] = $_POST['chrompos'];
    $_SESSION['chromposbegin'] = $_POST['chromposbegin'];
		$_SESSION['lines'] = $_POST['lines'];
  }
  echo "<p class='pages'><span>Genome selected : ".$_SESSION['genomename']."</span>";
?>
  <input type="image" class="vbtn" src="images/return.png" align="texttop" alt="return" style="width:22px;height:22px;border-radius:30px;" value="variant" onclick="window.location.href='variants.php'"></span>
<?PHP
  echo '<div class="question">';
  echo '<form id="query" class="top-border" action="'.$phpscript.'" method="post">';
?>
  <div>
    <p class="pages"><span>Select Lines <font size=2pt>(optional)</font>: </span>
		<select name="lines[]" id="lines" size=4 multiple="multiple">
		<option value="" selected disabled >Select Lines(s)</option>
        <option value="Ross">Ross</option>
        <option value="Illinois">Illinois</option>
        <option value="Ugandan">Ugandan</option>
				<option value="Fayoumi">Fayoumi</option>
				<option value="Fayoumi-Normal">Fayoumi-Normal</option>
				<option value="Fayoumi-embryo%%HS">Fayoumi-embryo HS</option>
				<option value="Fayoumi-chick%%HS">Fayoumi-chick HS</option>
				<option value="Fayoumi%%HC&HS">Fayoumi HC&HS</option>
				<option value="Fayoumi%%x%%Broiler">Fayoumi x Broiler</option>
				<option value="Broiler">Broiler</option>
				<option value="WLH">WLH</option>
				<option value="LMH">LMH</option>
				<option value="AIL-Normal">AIL-Normal</option>
				<option value="AIL%%HC&HS">AIL HC&HS</option>
    </select>
		</p><br>
			<p class="pages"><span>Specify chromosomal location : </span> </p>
          <p class="pages"><span>Chromosome: </span>
            <select name="chrompos" id="chrompos">
            <option value="" selected disabled >Select A Chromosome</option>
            <option value="chr1"<?php if ($_SESSION['chrompos']=='chr1') echo 'selected="selected"'; ?> >chr1</option>
            <option value="chr2"<?php if ($_SESSION['chrompos']=='chr2') echo 'selected="selected"'; ?> >chr2</option>
            <option value="chr3"<?php if ($_SESSION['chrompos']=='chr3') echo 'selected="selected"'; ?> >chr3</option>
            <option value="chr4"<?php if ($_SESSION['chrompos']=='chr4') echo 'selected="selected"'; ?> >chr4</option>
            <option value="chr5"<?php if ($_SESSION['chrompos']=='chr5') echo 'selected="selected"'; ?> >chr5</option>
            <option value="chr6"<?php if ($_SESSION['chrompos']=='chr6') echo 'selected="selected"'; ?> >chr6</option>
            <option value="chr7"<?php if ($_SESSION['chrompos']=='chr7') echo 'selected="selected"'; ?> >chr7</option>
            <option value="chr8"<?php if ($_SESSION['chrompos']=='chr8') echo 'selected="selected"'; ?> >chr8</option>
            <option value="chr9"<?php if ($_SESSION['chrompos']=='chr9') echo 'selected="selected"'; ?> >chr9</option>
            <option value="chr10"<?php if ($_SESSION['chrompos']=='chr10') echo 'selected="selected"'; ?> >chr10</option>
            <option value="chr11"<?php if ($_SESSION['chrompos']=='chr11') echo 'selected="selected"'; ?> >chr11</option>
            <option value="chr12"<?php if ($_SESSION['chrompos']=='chr12') echo 'selected="selected"'; ?> >chr12</option>
            <option value="chr13"<?php if ($_SESSION['chrompos']=='chr13') echo 'selected="selected"'; ?> >chr13</option>
            <option value="chr14"<?php if ($_SESSION['chrompos']=='chr14') echo 'selected="selected"'; ?> >chr14</option>
            <option value="chr15"<?php if ($_SESSION['chrompos']=='chr15') echo 'selected="selected"'; ?> >chr15</option>
            <option value="chr16"<?php if ($_SESSION['chrompos']=='chr16') echo 'selected="selected"'; ?> >chr16</option>
            <option value="chr17"<?php if ($_SESSION['chrompos']=='chr17') echo 'selected="selected"'; ?> >chr17</option>
            <option value="chr18"<?php if ($_SESSION['chrompos']=='chr18') echo 'selected="selected"'; ?> >chr18</option>
            <option value="chr19"<?php if ($_SESSION['chrompos']=='chr19') echo 'selected="selected"'; ?> >chr19</option>
            <option value="chr20"<?php if ($_SESSION['chrompos']=='chr20') echo 'selected="selected"'; ?> >chr20</option>
            <option value="chr21"<?php if ($_SESSION['chrompos']=='chr21') echo 'selected="selected"'; ?> >chr21</option>
            <option value="chr22"<?php if ($_SESSION['chrompos']=='chr22') echo 'selected="selected"'; ?> >chr22</option>
            <option value="chr23"<?php if ($_SESSION['chrompos']=='chr23') echo 'selected="selected"'; ?> >chr23</option>
            <option value="chr24"<?php if ($_SESSION['chrompos']=='chr24') echo 'selected="selected"'; ?> >chr24</option>
            <option value="chr25"<?php if ($_SESSION['chrompos']=='chr25') echo 'selected="selected"'; ?> >chr25</option>
            <option value="chr26"<?php if ($_SESSION['chrompos']=='chr26') echo 'selected="selected"'; ?> >chr26</option>
            <option value="chr27"<?php if ($_SESSION['chrompos']=='chr27') echo 'selected="selected"'; ?> >chr27</option>
            <option value="chr28"<?php if ($_SESSION['chrompos']=='chr28') echo 'selected="selected"'; ?> >chr28</option>
            <option value="chrLGE22C19W28_E50C23"<?php if ($_SESSION['chrompos']=='chrLGE22C19W28_E50C23') echo 'selected="selected"'; ?> >chrLGE22C19W28_E50C23</option>
            <option value="chrLGE64"<?php if ($_SESSION['chrompos']=='chrLGE64') echo 'selected="selected"'; ?> >chrLGE64</option>
            <option value="chrMT"<?php if ($_SESSION['chrompos']=='chrMT') echo 'selected="selected"'; ?> >chrMT</option>
            <option value="chrW"<?php if ($_SESSION['chrompos']=='chrW') echo 'selected="selected"'; ?> >chrW</option>
            <option value="chrZ"<?php if ($_SESSION['chrompos']=='chrZ') echo 'selected="selected"'; ?> >chrZ</option>
            </select>
          <span>Starting position: </span>
            <?php
              if (!empty($_SESSION['chromposbegin'])) {
                echo '<input class = "vartext" type="text" name="chromposbegin" value="' . $_SESSION["chromposbegin"] . '"/>';
              } else {
                echo '<input class = "vartext" type="text" name="chromposbegin" placeholder="Enter starting position" />';
              }
            ?>
          <span>Ending position: </span>
            <?php
              if (!empty($_SESSION['chromposend'])) {
                echo '<input class = "vartext" type="text" name="chromposend" value="' . $_SESSION["chromposend"] . '"/>';
              } else {
                echo '<input class = "vartext" type="text" name="chromposend" placeholder="Enter ending position" />';
              }
            ?>
          </p>
      <br>
    <center><input type="submit" name="reveal" value="View Results" onClick="this.value='Sending… Please Wait'; style.backgroundColor = '#75684a'; this.form.submit();"></center>
  </div>
</form>
</div>
<hr>
<?PHP
  if ((isset($_POST['reveal']) || isset($_POST['downloadvalues'])) && !empty($_SESSION['chrompos']) && !empty($_SESSION['chromposbegin']) && !empty($_SESSION['chromposend'])) {
    $output1 = "$base_path/OUTPUT/Voutput_".$explodedate.".par"; $output2 = "$base_path/OUTPUT/Voutput_".$explodedate.".txt";
    $pquery = 'perl '.$base_path.'/SQLscripts/fboutputvariantinfo.pl -c '.$_SESSION['chrompos'].' -b '.$_SESSION['chromposbegin'].' -e '.$_SESSION['chromposend'].' -s '.$_SESSION['species'].' -o '.$output1.'';
    
		if ($_SESSION['lines']){
			foreach ($_SESSION["lines"] as $lines){
				$linez .= $lines. ",";
			}
			$linez = rtrim($linez,",");
			$pquery .= " -line ".$linez;
			$newbed = "OUTPUT/custom-".$explodedate.".bed";
		} else { $newbed = 'gallus.bed';}
		$pquery .= " $newbed $base_path/$newbed";
		
		$prefix = 'http://genome.ucsc.edu/cgi-bin/hgTracks?db=galGal4&position=';
    $suffix = '&hgct_customText=http://raven.anr.udel.edu/~modupe/atlas/'.$newbed;
		//print $pquery; 
		shell_exec($pquery);
    $rquery = file_get_contents($output1);
    $dloadquery = file_get_contents($output2); shell_exec ("rm -f ".$output2);
    if (count(explode ("\n", $rquery)) <= 14){
      echo '<center>No results were found with your search criteria.<center>';
    } else {
      if ($_SESSION['chromposbegin'] <= 1500) { $posstart = 1;}
      else { $posstart = $_SESSION['chromposbegin']-1500;}
      $posend = $_SESSION['chromposend']+1500;
      $genename = $_SESSION['chrompos'].':'.$posstart.'-'.$posend;
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
        $filer = "file=$output2&name=variants.txt";
        print("<script>location.href='results.php?file=$output2&name=variants.txt'</script>");

      }
      echo '</form></div>';
    }
    shell_exec ("rm -f ".$output1); 
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



