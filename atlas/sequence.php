<?php
  session_start();
  require_once('atlas_header.php'); //The header
  require_once('atlas_fns.php'); //All the routines
  d_metadata_header(); //Display header
  $phpscript = "sequence.php";
?>
  <div id="metamenu">
	<ul>
		<li ><a href="metadata.php">MetaData Information</a></li>
		<li ><a class="active" href="sequence.php">Sequencing Information</a></li>
	</ul>
</div>
  <div class="explain"><p>View bio-data of the RNA-Seq libraries sequence mapping information.</p></div>
<?php
  /* Tables required from the database */
  $statustable = "vw_libraryinfo";
  $table = "transcripts_summary";
?>
<?php
  $query = "SHOW KEYS FROM $table WHERE Key_name = 'PRIMARY'";
  $result = $db_conn->query($query);
  // create array of primary keys
  $primary_key = null;
  while ($row = $result->fetch_assoc()) {
    $primary_key = $row['Column_name'];
  }
  if (!$primary_key) {
    echo "<div><strong>NO PRIMARY KEY!\nFUNCTIONS WILL NOT WORK AS EXPECTED!</strong></div>";
  }
?>
<?php
  //create query for DB display
  if (!empty($_GET['libs'])) {
    // if the sort option was used
    $_SESSION['num_recs'] = "all";

    $terms = explode(",", $_GET['libs']);
    $is_term = false;
    foreach ($terms as $term) {
      if (trim($term) != "") {
        $is_term = true;
      }
    }
    $_SESSION['select'] = $terms;
    $_SESSION['column'] = "library_id";

    $query = "select $statustable.library_id,$statustable.line,$statustable.species, $statustable.tissue,
              $table.total_reads, $statustable.mapped_reads, $statustable.genes, $statustable.isoforms,
              $statustable.total_VARIANTS VARIANTS,$statustable.total_SNPs SNPs, $statustable.total_INDELs INDELs,
              frnak_metadata.sequences Sequences, $table.date Date from $table join $statustable on
							$table.library_id = $statustable.library_id join
							frnak_metadata on $table.library_id = frnak_metadata.library_id ";
    if ($is_term) {
        $query .= "WHERE ";
    }
    $query .= $statustable.".".$_SESSION['column'] . " in (" . $_GET['libs'] . ")";
    $query .= " ORDER BY " . $statustable.".library_id asc";

    $result = $db_conn->query($query);
    $num_total_result = $result->num_rows;
    if ($_SESSION['num_recs'] != "all") {
      $query .= " limit " . $_SESSION['num_recs'];
    }
  }
  elseif (!empty($_REQUEST['order'])) {
    // if the sort option was used
    unset($_SESSION['store']);
    $_SESSION['sort'] = $_POST['sort'];
    $_SESSION['dir'] = $_POST['dir'];
    $_SESSION['num_recs'] = $_POST['num_recs'];

    $terms = explode(",", $_POST['search']);
    $is_term = false;
    foreach ($terms as $term) {
      if (trim($term) != "") {
        $is_term = true;
      }
    }
    $_SESSION['select'] = $terms;
    $_SESSION['column'] = $_POST['column'];

    $query = "select $statustable.library_id,$statustable.line,$statustable.species, $statustable.tissue,
              $table.total_reads, $statustable.mapped_reads, $statustable.genes, $statustable.isoforms,
              $statustable.total_VARIANTS VARIANTS,$statustable.total_SNPs SNPs, $statustable.total_INDELs INDELs,
              frnak_metadata.sequences Sequences, $table.date Date from $table join $statustable on
							$table.library_id = $statustable.library_id join
							frnak_metadata on $table.library_id = frnak_metadata.library_id ";
    if ($is_term) {
        $query .= "WHERE ";
    }
    
    foreach ($_SESSION['select'] as $term) {
      if (trim($term) == "") {
        continue;
      }
      $query .= $statustable.".".$_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
    }
    $query = rtrim($query, " OR ");
    $query .= " ORDER BY ";
			if ($_SESSION['sort'] == "date" ){
					$query .= $table.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			} else {
				$query .= $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			}
			//$query .= " ORDER BY " . $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
    
    $result = $db_conn->query($query);
    $num_total_result = $result->num_rows;
    if ($_SESSION['num_recs'] != "all") {
      $query .= " limit " . $_SESSION['num_recs'];
    }
  }
  elseif (!empty($_SESSION['store']) && !empty($_REQUEST['downloadvalues'])) {
    $is_term = false;
    foreach ($_SESSION['select'] as $term) {
      if (trim($term) != "") {
        $is_term = true;
      }
    }
    $query = "select $statustable.library_id,$statustable.line,$statustable.species, $statustable.tissue,
              $table.total_reads, $statustable.mapped_reads, $statustable.genes, $statustable.isoforms,
              $statustable.total_VARIANTS VARIANTS,$statustable.total_SNPs SNPs, $statustable.total_INDELs INDELs,
              frnak_metadata.sequences Sequences, $table.date Date from $table join $statustable on
							$table.library_id = $statustable.library_id join
							frnak_metadata on $table.library_id = frnak_metadata.library_id ";
    if ($is_term) {
        $query .= "WHERE ";
    }
    if ($_SESSION['column'] != "library_id"){
      foreach ($_SESSION['select'] as $term) {
        if (trim($term) == "") {
          continue;
        }
        $query .= $statustable.".".$_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
      }
      $query = rtrim($query, " OR ");
      $query .= " ORDER BY ";
			if ($_SESSION['sort'] == "date" ){
					$query .= $table.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			} else {
				$query .= $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			}//$query .= " ORDER BY " . $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
    } else {
      foreach ($_SESSION['select'] as $term) {
        if (trim($term) == "") {
          continue;
        }
        $query .= $statustable.".".$_SESSION['column'] . " = " . trim($term) . " OR ";
      }
      $query = rtrim($query, " OR ");
      $query .= " ORDER BY ";
			if ($_SESSION['sort'] == "date" ){
					$query .= $table.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			} else {
				$query .= $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			}//$query .= " ORDER BY " . $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
    }
    
    $result = $db_conn->query($query);
    $num_total_result = $result->num_rows;

    if ($_SESSION['num_recs'] != "all") {
      $query .= " limit " . $_SESSION['num_recs'];
    }
  }
  elseif (!empty($_SESSION['sort']) && !empty($_REQUEST['downloadvalues'])) {
    $is_term = false;
    foreach ($_SESSION['select'] as $term) {
      if (trim($term) != "") {
        $is_term = true;
      }
    }
    $query = "select $statustable.library_id,$statustable.line,$statustable.species, $statustable.tissue,
              $table.total_reads, $statustable.mapped_reads, $statustable.genes, $statustable.isoforms,
              $statustable.total_VARIANTS VARIANTS,$statustable.total_SNPs SNPs, $statustable.total_INDELs INDELs,
              frnak_metadata.sequences Sequences, $table.date Date from $table join $statustable on
							$table.library_id = $statustable.library_id join
							frnak_metadata on $table.library_id = frnak_metadata.library_id ";
    if ($is_term) {
        $query .= "WHERE ";
    }
    foreach ($_SESSION['select'] as $term) {
        if (trim($term) == "") {
          continue;
        }
        $query .= $statustable.".".$_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
      }
      $query = rtrim($query, " OR ");
      $query .= " ORDER BY ";
			if ($_SESSION['sort'] == "date" ){
					$query .= $table.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			} else {
				$query .= $statustable.".".$_SESSION['sort'] . " " . $_SESSION['dir'];
			}
    
    
    $result = $db_conn->query($query);
    $num_total_result = $result->num_rows;

    if ($_SESSION['num_recs'] != "all") {
      $query .= " limit " . $_SESSION['num_recs'];
    }
  }
  $result = $db_conn->query($query);
  if ($db_conn->errno) {
    echo "<div>";
    echo "<span><strong>Error with query.</strong></span>$query<br>";
    echo "<span><strong>Error number: </strong>$db_conn->errno</span>";
    echo "<span><strong>Error string: </strong>$db_conn->error</span>";
    echo "</div>";
  }
  $num_results = $result->num_rows;
  if (empty($_SESSION['sort'])) {
    $num_total_result = $num_results;
  }
?>
<?php
  echo '<table width="100%"><tr><td width="90%"><form action="'.$phpscript.'" method="post">';
?>
    <div class="question">
    <p class="pages"><span>Search for: </span>
    <input type="text" name="search" size="35" placeholder="Enter variable(s) separated by commas (,)"
	<?php
		if(!empty($db_conn))
		{
			echo 'value="' . implode(",", $_SESSION["select"]) .'"'; 
		} 
	?>
    />
    <span> in </span>
    <select name="column">
      <option value="library_id">library_id</option>
      <?php
        if (empty($_SESSION['column'])) {
          $_SESSION['library_id'] = "library_id";
        }
        if ($_SESSION['column'] == "species") {
          echo '<option selected value="species">species</option>';
        } else {
          echo '<option value="species">species</option>';
        }
        if ($_SESSION['column'] == "line") {
          echo '<option selected value="line">line</option>';
        } else {
          echo '<option value="line">line</option>';
        }
        if ($_SESSION['column'] == "tissue") {
          echo '<option selected value="tissue">tissue</option>';
        } else {
          echo '<option value="tissue">tissue</option>';
        }
      ?> 
    </select></p><p class="pages">
    <span>Sort by:</span>
    <select name="sort">
      <option value="library_id">library_id</option>
      <?php
        if (empty($_SESSION['sort'])) {
          $_SESSION['library_id'] = "library_id";
        }
        if ($_SESSION['sort'] == "species") {
          echo '<option selected value="species">species</option>';
        } else {
          echo '<option value="species">species</option>';
        }
        if ($_SESSION['sort'] == "line") {
          echo '<option selected value="line">line</option>';
        } else {
          echo '<option value="line">line</option>';
        }
        if ($_SESSION['sort'] == "tissue") {
          echo '<option selected value="tissue">tissue</option>';
        } else {
          echo '<option value="tissue">tissue</option>';
        }
				if ($_SESSION['sort'] == "date") {
          echo '<option selected value="date">date</option>';
        } else {
          echo '<option value="date">date</option>';
        }
      ?> 
    </select> <!--if ascending or descending-->
    <select name="dir">
      <option value="asc">ascending</option>
      <?php
        if (empty($_SESSION['dir'])) {
          $_SESSION['asc'] = "asc";
        }
        if ($_SESSION['dir'] == "desc") {
          echo '<option selected value="desc">descending</option>';
        } else {
          echo '<option value="desc">descending</option>';
        }
      ?>
      </select>
    <span>and show</span>
    <select name="num_recs">
      <option value="10">10</option>
      <?php
        if (empty($_SESSION['num_recs'])) {
          $_SESSION['num_recs'] = "10";
        }
        if ($_SESSION['num_recs'] == "20") {
          echo '<option selected value="20">20</option>';
        } else {
          echo '<option value="20">20</option>';
        }
        if ($_SESSION['num_recs'] == "50") {
          echo '<option selected value="50">50</option>';
        } else {
          echo '<option value="50">50</option>';
        }
        if ($_SESSION['num_recs'] == "all") {
          echo '<option selected value="all">all</option>';
        } else {
          echo '<option value="all">all</option>';
        }
      ?> 
    </select>
    <span>records.  </span>  <input type="submit" name="order" value="Go"/></p></div>
</form></tr></table>
<hr>
<?php
  if(!empty($db_conn) && (!empty($_POST['order']) || !empty($_POST['meta_data']))) { //make sure if select options selected
    if ($num_total_result == 0){ //cross check if libraries selected are in the database
      echo '<center>No results were found with your search criteria.<br>
      There are no "'.implode(",", $_SESSION["select"]).'" in "'.$_SESSION['column'].'".<center>';
    }else { //provide download options
      echo '<div>';
      echo '<form action="' . $phpscript . '" method="post">';
      echo "<span>" . $num_results . " out of " . $num_total_result . " search results displayed. ";
      echo '<input type="submit" name="downloadvalues" value="Download Selected Values"/></span>
	    <input type="submit" name="downloadfpkm" value="Download FPKM  Values"/></span><br>';
      metavw_display($phpscript, $result, $primary_key);
      if(!empty($_POST['meta_data']) && isset($_POST['downloadvalues'])) { //if download sequencing information
        foreach($_POST['meta_data'] as $check) {
          $dataline .= $check.",";
        }
        $dataline = rtrim($dataline, ",");
        $listfile = "sequence_".$explodedate.".txt";
        $output1 = "$base_path/OUTPUT/$listfile";
        $pquery = "perl ".$base_path."/SQLscripts/outputmetadata.pl -1 ".$dataline." -2 ".$output1." -z";
        shell_exec($pquery); 
        print("<script>location.href='results.php?file=$output1&name=sequenceinfo.txt'</script>");
      }
      elseif(!empty($_POST['meta_data']) && isset($_POST['downloadfpkm'])) { //If download fpkm
        foreach($_POST['meta_data'] as $check) {
          $dataline .= $check.",";
        }
        $dataline = rtrim($dataline, ",");
	$output = "$base_path/OUTPUT/fpkm_".$explodedate;
	$output1 = "$base_path/OUTPUT/fpkm_".$explodedate.".txt";
        $pquery = "perl ".$base_path."/SQLscripts/outputgenequery.pl -1 ".$dataline." -2 ".$output;
        #echo $pquery;
        shell_exec($pquery); 
        print("<script>location.href='results.php?file=$output1&name=fpkm.txt'</script>");
      }
    }
  }
//Transfer from MetaData page
  elseif(!empty($db_conn) && (!empty($_GET['libs']))) { //make sure proper transfer from metadata page
    if ($num_total_result == 0){ //cross check if libraries selected are in the database
      echo '<center>No results were found with your search criteria.<br>
      There are no "'.implode(",", $_SESSION["select"]).'" in "'.$_SESSION['column'].'".<center>';
    }else { // provdie download options
      echo '<div>';
      echo '<form action="' . $phpscript . '" method="post">';
      echo "<span>" . $num_results . " out of " . $num_total_result . " search results displayed. ";
      echo '<input type="submit" name="downloadvalues" value="Download Selected Values"/></span>
            <input type="submit" name="downloadfpkm" value="Download FPKM  Values"/></span><br>';
      metavw_display($phpscript, $result, $primary_key);
      if(!empty($_POST['meta_data']) && isset($_POST['downloadvalues'])) { //if download sequencing information
        $_SESSION['meta_data'] = $_POST['meta_data'];
        foreach($_POST['meta_data'] as $check) {
          $dataline .= $check.",";
        }
        $dataline = rtrim($dataline, ",");
        $listfile = "sequence_".$explodedate.".txt";
        $output1 = "$base_path/OUTPUT/$listfile";
        $pquery = "perl ".$base_path."/SQLscripts/outputmetadata.pl -1 ".$dataline." -2 ".$output1." -z";
        shell_exec($pquery); 
        print("<script>location.href='results.php?file=$output1&name=sequenceinfo.txt'</script>");
      }
      elseif(!empty($_POST['meta_data']) && isset($_POST['downloadfpkm'])) { //If download fpkm
        foreach($_POST['meta_data'] as $check) {
          $dataline .= $check.",";
        }
        $dataline = rtrim($dataline, ",");
        $listfile = "fpkm_".$explodedate.".txt";
        $output1 = "$base_path/OUTPUT/$listfile";
        $pquery = "perl ".$base_path."/SQLscripts/outputgenequery.pl -1 ".$dataline." -2 ".$output1;
        #echo $pquery;
        shell_exec($pquery); 
        print("<script>location.href='results.php?file=$output1&name=fpkm.txt'</script>");
      }
    }
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
