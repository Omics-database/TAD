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
  }
  echo "<p class='pages'><span>Genome selected : ".$_SESSION['genomename']."</span>";
?>
  <input type="image" class="vbtn" src="images/return.png" align="texttop" alt="return" style="width:22px;height:22px;border-radius:30px;" value="variant" onclick="window.location.href='variants.php'"></span>
<?PHP
  echo '<div class="question">';
  echo '<form id="query" class="top-border" action="'.$phpscript.'" method="post">';
?>
  <div>
    <p class="pages"><span>Specify chromosomal location : </span> </p>
          <p class="pages"><span>Chromosome: </span>
            <select name="chrompos" id="chrompos">
            <option value="" selected disabled >Select A Chromosome</option>
            <option value="NC_000067.6"<?php if ($_POST['chrompos']=='NC_000067.6') echo 'selected="selected"'; ?> >NC_000067.6</option>
            <option value="NC_000068.7"<?php if ($_POST['chrompos']=='NC_000068.7') echo 'selected="selected"'; ?> >NC_000068.7</option>
            <option value="NC_000069.6"<?php if ($_POST['chrompos']=='NC_000069.6') echo 'selected="selected"'; ?> >NC_000069.6</option>
            <option value="NC_000070.6"<?php if ($_POST['chrompos']=='NC_000070.6') echo 'selected="selected"'; ?> >NC_000070.6</option>
            <option value="NC_000071.6"<?php if ($_POST['chrompos']=='NC_000071.6') echo 'selected="selected"'; ?> >NC_000071.6</option>
            <option value="NC_000072.6"<?php if ($_POST['chrompos']=='NC_000072.6') echo 'selected="selected"'; ?> >NC_000072.6</option>
            <option value="NC_000073.6"<?php if ($_POST['chrompos']=='NC_000073.6') echo 'selected="selected"'; ?> >NC_000073.6</option>
            <option value="NC_000074.6"<?php if ($_POST['chrompos']=='NC_000074.6') echo 'selected="selected"'; ?> >NC_000074.6</option>
            <option value="NC_000075.6"<?php if ($_POST['chrompos']=='NC_000075.6') echo 'selected="selected"'; ?> >NC_000075.6</option>
            <option value="NC_000076.6"<?php if ($_POST['chrompos']=='NC_000076.6') echo 'selected="selected"'; ?> >NC_000076.6</option>
            <option value="NC_000077.6"<?php if ($_POST['chrompos']=='NC_000077.6') echo 'selected="selected"'; ?> >NC_000077.6</option>
            <option value="NC_000078.6"<?php if ($_POST['chrompos']=='NC_000078.6') echo 'selected="selected"'; ?> >NC_000078.6</option>
            <option value="NC_000079.6"<?php if ($_POST['chrompos']=='NC_000079.6') echo 'selected="selected"'; ?> >NC_000079.6</option>
            <option value="NC_000080.6"<?php if ($_POST['chrompos']=='NC_000080.6') echo 'selected="selected"'; ?> >NC_000080.6</option>
            <option value="NC_000081.6"<?php if ($_POST['chrompos']=='NC_000081.6') echo 'selected="selected"'; ?> >NC_000081.6</option>
            <option value="NC_000082.6"<?php if ($_POST['chrompos']=='NC_000082.6') echo 'selected="selected"'; ?> >NC_000082.6</option>
            <option value="NC_000083.6"<?php if ($_POST['chrompos']=='NC_000083.6') echo 'selected="selected"'; ?> >NC_000083.6</option>
            <option value="NC_000084.6"<?php if ($_POST['chrompos']=='NC_000084.6') echo 'selected="selected"'; ?> >NC_000084.6</option>
            <option value="NC_000085.6"<?php if ($_POST['chrompos']=='NC_000085.6') echo 'selected="selected"'; ?> >NC_000085.6</option>
            <option value="NC_000086.7"<?php if ($_POST['chrompos']=='NC_000086.7') echo 'selected="selected"'; ?> >NC_000086.7</option>
            <option value="NC_000087.7"<?php if ($_POST['chrompos']=='NC_000087.7') echo 'selected="selected"'; ?> >NC_000087.7</option>
            <option value="NC_005089.1"<?php if ($_POST['chrompos']=='NC_005089.1') echo 'selected="selected"'; ?> >NC_005089.1</option>
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
    shell_exec($pquery);
    $rquery = file_get_contents($output1);
    $dloadquery = file_get_contents($output2); shell_exec ("rm -f ".$output2);
    if (count(explode ("\n", $rquery)) <= 13){
      echo '<center>No results were found with your search criteria.<center>';
    } else {
      echo '<div class="gened">';
      echo '<form action="' . $phpscript . '" method="post">';
      echo '<p class="gened">Below are the variants found. ';
      echo '<input type="submit" name="downloadvalues" value="Download Results"/>';
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


