<?php				
	session_start();
	require_once('all_fns.php');
	tmetadata(); 
?>
<?php
	//Database Attributes
	$table = "vw_metadata";
	$statustable1 = "GeneStats";
	$statustable2 = "VarSummary";
	$query = "select $table.sampleid, $table.animalid, $table.organism, $table.tissue, $table.sampledescription, $table.date ,$statustable1.status as genestatus, $statustable2.status as variantstatus from $table left outer join $statustable1 on $table.sampleid = $statustable1.sampleid left outer join $statustable2 on $statustable2.sampleid = $table.sampleid";
?>
	<div class="menu">TransAtlasDB Metadata</div>
	<div class="dift"><p>View bio-data of the RNA-Seq libraries processed and status information.</p>

<?php
	//create query for DB display
	if (!empty($_GET['libs'])) {
    //if the sort option was used
		$_SESSION['num_recs'] = "all";

		$terms = explode(",", $_GET['libs']);
		$is_term = false;
		foreach ($terms as $term) {
			if (trim($term) != "") {
				$is_term = true;
			}	
		}
		$_SESSION['select'] = $terms;
		$_SESSION['column'] = "sampleid";
		if ($is_term) {
		    $query .= "WHERE ";
		}
		foreach ($_SESSION['select'] as $term) {
			if (trim($term) == "") {
				continue;
			}
			$query .= $table.".".$_SESSION['column'] . " =" . trim($term) . " OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $table.".".$_SESSION['column'] . " " . $_SESSION['dir'];

		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;
		if ($_SESSION['num_recs'] != "all") {
			$query .= " limit " . $_SESSION['num_recs'];
		}
	}
	elseif (!empty($_REQUEST['order'])) {
		// if the sort option was used
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
		$_SESSION['gstatus'] = $_POST['rnull'];
		$_SESSION['vstatus'] = $_POST['vnull'];

		if ($_SESSION['gstatus'] == "true"){
			$query .= " WHERE $statustable1.status = ". '"done" ';
			if ($is_term) {
				$query .= "AND ";
			}
		} elseif ($_SESSION['vstatus'] == "true"){
			$query .= " WHERE $statustable2.status = ". '"done" ';
			if ($is_term) {
				$query .= "AND ";
			}
		}else {
			if ($is_term) {
				$query .= "WHERE ";
			}
		}
		foreach ($_SESSION['select'] as $term) {
			if (trim($term) == "") {
				continue;
			}
			$query .= $table.".".$_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $table.".".$_SESSION['sort'] . " " . $_SESSION['dir'];

		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;
		if ($_SESSION['num_recs'] != "all") {
			$query .= " limit " . $_SESSION['num_recs'];
		}
	} elseif (!empty($_SESSION['sort'])) {
		$is_term = false;
		foreach ($_SESSION['select'] as $term) {
			if (trim($term) != "") {
				$is_term = true;
			}
		}
		if ($_SESSION['gstatus'] == "true"){
			$query .= " WHERE $statustable1.status = ". '"done" ';
			if ($is_term) {
				$query .= "AND ";
			}
		} elseif ($_SESSION['vstatus'] == "true"){
			$query .= " WHERE $statustable2.status = ". '"done" ';
			if ($is_term) {
				$query .= "AND ";
			}
		} else {
			if ($is_term) {
				$query .= "WHERE ";
			}
		}
		foreach ($_SESSION['select'] as $term) {
			if (trim($term) == "") {
				continue;
			}
			$query .= $table.".".$_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $table.".".$_SESSION['sort'] . " " . $_SESSION['dir'];

		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;
	
		if ($_SESSION['num_recs'] != "all") {
			$query .= " limit " . $_SESSION['num_recs'];
		}
	}
	$result = $db_conn->query($query);
	if ($db_conn->errno) {
		echo "<div>";
		echo "<span><strong>Error with query.</strong></span>";
		echo "<span><strong>Error number: </strong>$db_conn->errno</span>";
		echo "<span><strong>Error string: </strong>$db_conn->error</span>";
		echo "</div>";
	}
	$num_results = $result->num_rows;
	if (empty($_SESSION['sort'])) {
		$num_total_result = $num_results;
	}
?>
<!-- QUERY -->
<form action="" method="post">
    <p class="pages">
		<span>Search for: </span>
<?php
	if (!empty($_SESSION['select'])) {
		echo '<input type="text" size="35" name="search" value="' . implode(",", $_SESSION["select"]) . '"\"/>';
	} else {
		echo '<input type="text" size="35" name="search" placeholder="Enter variable(s) separated by commas (,)"/>';
	} 
?>
    <span> in </span>
    <select name="column">
        <?php
			$i = 0;
			$all_rows = $db_conn->query("select $table.sampleid, $table.animalid, $table.organism, $table.tissue, $table.sampledescription, $table.date from $table");
			while ($i < $all_rows->field_count) {
			    $meta = $all_rows->fetch_field_direct($i);
			    echo '<option value="'.$meta->name.'">'. $meta->name.'</option>';
			    $i++;
			}
		?>
</select></p>
    <p class="pages" >
		<span>Sort by:</span>
		<select name="sort">
		    <?php
				$i = 0;
				while ($i < $all_rows->field_count) {
					$meta = $all_rows->fetch_field_direct($i);
					echo '<option value="' . $meta->name . '">' . $meta->name . '</option>';
					$i++;
				}
		    ?>
		</select> <!--if ascending or descending-->
		<select name="dir">
			<option value="asc">ascending</option>
			<?php
				if (empty($_SESSION[$table]['dir'])) {
					$_SESSION[$table]['asc'] = "asc";
				}
				if ($_SESSION[$table]['dir'] == "desc") {
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
				if (empty($_SESSION[$table]['num_recs'])) {
					$_SESSION[$table]['num_recs'] = "10";
				}
				if ($_SESSION[$table]['num_recs'] == "20") {
					echo '<option selected value="20">20</option>';
				} else {
					echo '<option value="20">20</option>';
				}
				if ($_SESSION[$table]['num_recs'] == "50") {
					echo '<option selected value="50">50</option>';
				} else {
					echo '<option value="50">50</option>';
				}
				if ($_SESSION[$table]['num_recs'] == "all") {
					echo '<option selected value="all">all</option>';
				} else {
					echo '<option value="all">all</option>';
				}
			?> 
		</select>
		<span>records.</span></p><p class="pages">
    <span>View samples with gene expression information:</span><input type="checkbox" name="rnull" value="true"><br>
	<span>View samples with variant information:</span><input type="checkbox" name="vnull" value="true"> 
    <input type="submit" name="order" value="Go"/></p></div>
</form>
</div>

<?php
  if(!empty($db_conn) && (!empty($_POST['order']) || !empty($_GET['libs']) || !empty($_POST['meta_data']))) { //make sure an options is selected
	echo '<div class="menu">Results</div><div class="xtra">';
    if ($num_total_result == 0){ //Cross check if libraries selected are in the database
      echo '<center>No results were found with your search criteria.<br>
      There are no "'.implode(",", $_SESSION["select"]).'" in "'.$_SESSION['column'].'".<center>';
    }else { //Provide download options
      echo '<div>';
      echo '<form action="" method="post">';
      echo "<span>" . $num_results . " out of " . $num_total_result . " search results displayed. ";
      echo '<input type="submit" name="downloadvalues" value="Download Selected Values"/></span>
	    <input type="submit" name="downloadfpkm" value="Download FPKM  Values"/></span>
            <input type="submit" name="transfervalues" value="View Mapping Information"/></span><br>';
      meta_display($result);
      if(!empty($_POST['meta_data']) && isset($_POST['downloadvalues'])) { //If download Metadata
        foreach($_POST['meta_data'] as $check) {
          $dataline .= '"'.$check.'",';
        }
        $dataline = rtrim($dataline, ",");
        $output = "OUTPUT/metadata_".$explodedate.".txt";
        $pquery = "perl $basepath/tad-export.pl -w -query 'select $table.sampleid, $table.animalid, $table.organism, $table.tissue, $table.sampledescription, $table.date from $table where $table.sampleid in ($dataline)' -o $output";
		shell_exec($pquery);
        print("<script>location.href='results.php?file=$output&name=metadata.txt'</script>");
      }
      elseif(!empty($_POST['meta_data']) && isset($_POST['downloadfpkm'])) { //If download fpkm
        foreach($_POST['meta_data'] as $check) {
          $dataline .= $check.",";
		  $newdataline .= '"'.$check.'",';
        }
        $dataline = rtrim($dataline, ",");$newdataline = rtrim($newdataline, ",");
		$output = "OUTPUT/fpkm_".$explodedate.".txt";
		$query = "select b.organism from animal b join sample a on a.derivedfrom = b.animalid where a.sampleid in ($newdataline) limit 1";
		$result = mysqli_query($db_conn,$query);
		$row = mysqli_fetch_array($result,MYSQLI_ASSOC);
		$organism = $row['organism'];
        
		$pquery = "perl $basepath/tad-export.pl -w -genexp --db2data --species '$organism' --samples '$dataline' --output $output";
		shell_exec($pquery);
        print("<script>location.href='results.php?file=$output&name=fpkm.txt'</script>");
      }
      elseif(!empty($_POST['meta_data']) && isset($_POST['transfervalues'])) { //If transfer to sequencing information page
        foreach($_POST['meta_data'] as $check) {
          $dataline .= $check.",";
        }
        $dataline = rtrim($dataline, ",");
        $_SESSION['store'] = "yes";
        print("<script>location.href='sequence.php?libs=$dataline'</script>");
      }
      
    }
  }
?>
  </div>
<?php
  $result ->free();
  $db_conn->close();
?>

<!--<a class="back-to-top" style="display: inline;" href="#"><img src="images/backtotop.png" alt="Back To Top" width="45" height="45"></a>
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
