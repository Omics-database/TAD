<?php				
	session_start();
	require_once('all_fns.php');
	theader();	
?>
    <div class="menu">TransAtlasDB Data Import</div>
    <body>
        <div class="dift">
            <p>Samples Metadata or RNASeq Data Analysis results upload and import to the database.</p>
            <ul>
                <li><p>Samples Metadata<br>
                N.B. Samples metadata file can either be the FAANG samples form or the tab-delimited file <a href="https://modupeore.github.io/TransAtlasDB/sample.html" target="_blank">provided</a>.
                    <form action="uploads.php" method="post" enctype="multipart/form-data">
                        Select metadata file:
                        <input type="file" name="fileToUpload" id="fileToUpload">
                        <input type="submit" value="Import to database" name="submit">
                    </form>
                </p></li>
                <li><p>Sample Analysis Results<br>
                N.B. Samples analysis results should be in a compressed (zip or tar) format.
                    <form action="uploads.php" method="post" enctype="multipart/form-data">
                        Select Data Analysis file:
                        <input type="file" name="fileToUpload" id="fileToUpload">
                        <input type="submit" value="Import to database" name="submit">
                    </form>
                </p></li>
            </ul>
		</div>
		<!-- Next Section -->
		<div class="menu">Summary of libraries currently in the database</div>
		<div class="xtra">
<?php	
	$table = "vw_metadata";
	$query = "SELECT * FROM $table";
	$all_rows = $db_conn->query($query);
	$total_rows = $all_rows->num_rows;

	if (!empty($_REQUEST['order'])) {
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

		$query = ("SELECT * FROM $table ");
		if ($is_term) {
		    $query .= "WHERE ";
		}
		foreach ($_SESSION['select'] as $term) {
		    if (trim($term) == "") {
		        continue;
		    }
		    $query .= $_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $_SESSION['sort'] . " " . $_SESSION['dir'];

		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;
		if ($_SESSION['num_recs'] != "all") {
		    $query .= " limit " . $_SESSION['num_recs'];
		}
		unset($_SESSION['txt_query']);
		} elseif (!empty($_SESSION['sort'])) {
		$is_term = false;
		foreach ($_SESSION['select'] as $term) {
		    if (trim($term) != "") {
		        $is_term = true;
		    }
		}
		$query = ("SELECT * FROM $table ");
		if ($is_term) {
		    $query .= "WHERE ";
		}
		foreach ($_SESSION['select'] as $term) {
		    if (trim($term) == "") {
		        continue;
		    }
		    $query .= $_SESSION['column'] . " LIKE '%" . trim($term) . "%' OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $_SESSION['sort'] . " " . $_SESSION['dir'];
		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;

		if ($_SESSION['num_recs'] != "all") {
		    $query .= " limit " . $_SESSION['num_recs'];
		}
	} else {
    // if this is the first time, then just order by line and display all rows //default
		$query = "SELECT * FROM $table ORDER BY sampleid desc limit 10";
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
			$all_rows = $db_conn->query($query);
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
		</select> <!if ascending or descending...>
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
		<span>records.</span>
		<input type="submit" name="order" value="Go"/></p>
</form>
<br>
<?php
echo '<form action="" method="post">';
echo "<span>" . $num_results . " out of " . $num_total_result . " search results displayed. (" . $total_rows . " total rows)</span>";
db_display($result);
?>
<?php
$result->free();
$db_conn->close();
?>
</div>
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
