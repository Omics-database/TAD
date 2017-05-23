<?php				
	session_start();
	require_once('all_fns.php');
	theader();
	
	$table = "vw_metadata";
	$stat = "Sample";

?>
<?php
	if (isset($_POST['accept'])) {
		$samplename = $_POST['samplename'];
		$sampledesc = $_POST['sampledesc'];
		$animalid = $_POST['animalid'];
		$species= $_POST['organism'];
		$part = $_POST['part'];
		$firstname= $_POST['firstname'];
		$middle = $_POST['middle'];
		$lastname = $_POST['last'];
		$organization = $_POST['organization'];
	}
?>
    <div class="menu">TransAtlasDB Data Import</div>
	<table width=80%><tr><td valign="top" width=280pt>
	<br><br>
	<div class="metamenu"><a href="import.php">Upload Files</a></div>
	<div class="metactive"><a href="manual.php">Manual Entry</a></div>
	<div class="metamenu"><a href="delete.php">Remove Data</a></div>
	</td><td>
	<div class="dift"><p>Samples Metadata Manual entry into the database.</p>
		<table><tr><td>
			<form action="" method="post">	
				<table class="border" border="0">
					<tr>
						<th class="border"><strong>Sample Name</strong> <font color=red>*</font></th>
						<td class="borders"><input type="text" class="forms" name="samplename"<?php if(!empty($db_conn)){echo 'value="'.$samplename.'"';}?></td>	<!--sample name-->
					</tr><tr>
						<th class="border"><strong>Sample description</strong></th>
						<td class="borders"><input type="text" class="forms" name="sampledesc"<?php if(!empty($db_conn)){echo 'value="'.$sampledesc.'"';}?></td>	<!--sample desc -->
					</tr><tr>
						<th class="border"><strong>Animal ID</strong> <font color=red>*</font></th>
						<td class="borders"><input type="text" class="forms" name="animalid"<?php if(!empty($db_conn)){echo 'value="'.$animalid.'"';}?>/></td>	<!--animalid-->
					</tr><tr>
						<th class="border"><strong>Organism</strong> <font color=red>*</font></th>
						<td class="borders"><input type="text" class="forms" name="organism"<?php if(!empty($db_conn)){echo 'value="'.$species.'"';}?>/></td>	<!--organism-->
					</tr><tr>
						<th class="border"><strong>Organism Part</strong> <font color=red>*</font></th>
						<td class="borders"><input type="text" class="forms" name="part"<?php if(!empty($db_conn)){echo 'value="'.$part.'"';}?>/></td>	<!--part-->
					</tr><tr>
						<th class="border"><strong>First Name</strong></th>
						<td class="borders"><input type="text" class="forms" name="firstname"<?php if(!empty($db_conn)){echo 'value="'.$firstname.'"';}?>/></td>	<!--first name-->
					</tr><tr>
						<th class="border"><strong>Middle Initial</strong></th>
						<td class="borders"><input type="text" class="forms" name="middle"<?php if(!empty($db_conn)){echo 'value="'.$middle.'"';}?>/></td>	<!--middle-->
					</tr><tr>
						<th class="border"><strong>Last Name</strong></th>
						<td class="borders"><input type="text" class="forms" name="lastname"<?php if(!empty($db_conn)){echo 'value="'.$lastname.'"';}?>/></td>	<!--last-->
					</tr><tr>
						<th class="border"><strong>Organization</strong></th>
						<td class="borders"><input type="text" class="forms" name="organization"<?php if(!empty($db_conn)){echo 'value="'.$organization.'"';}?>/></td>	<!--org-->
					</tr>
					<tr><td class="border" colspan="7"><center><input type="submit" name="accept" value="insert"/></center></td></tr>
				</table>
			</form>
		</td><td><div style="padding: 0 10pt; margin: 0 50pt;background-color: #f1f0f1;">
<?php
	if ((!empty($_POST['samplename'])) && (!empty($_POST['organism'])) && (!empty($_POST['animalid'])) && (!empty($_POST['part']))) {
		db_accept($stat, $db_conn);
		db_insert($stat, $db_conn);
	}
?>
		</div></td></tr></table>

	</div>
	</td></tr></table>
		<!-- Next Section -->
		<div class="menu">Summary of libraries currently in the database</div>
		<div class="xtra">
<?php	
	$query = "SELECT * FROM $table";
	$all_rows = $db_conn->query($query);
	$total_rows = $all_rows->num_rows;

	if (!empty($_REQUEST['order'])) {
    // if the sort option was used
		$_SESSION[$stat]['sort'] = $_POST['sort'];
		$_SESSION[$stat]['dir'] = $_POST['dir'];
		$_SESSION[$stat]['num_recs'] = $_POST['num_recs'];

		$terms = explode(",", $_POST['search']);
		$is_term = false;
		foreach ($terms as $term) {
		    if (trim($term) != "") {
		        $is_term = true;
		    }
		}
		$_SESSION[$stat]['select'] = $terms;
		$_SESSION[$stat]['column'] = $_POST['column'];

		$query = ("SELECT * FROM $table ");
		if ($is_term) {
		    $query .= "WHERE ";
		}
		foreach ($_SESSION[$stat]['select'] as $term) {
		    if (trim($term) == "") {
		        continue;
		    }
		    $query .= $_SESSION[$stat]['column'] . " LIKE '%" . trim($term) . "%' OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $_SESSION[$stat]['sort'] . " " . $_SESSION[$stat]['dir'];

		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;
		if ($_SESSION[$stat]['num_recs'] != "all") {
		    $query .= " limit " . $_SESSION[$stat]['num_recs'];
		}
		unset($_SESSION[$stat]['txt_query']);
		} elseif (!empty($_SESSION[$stat]['sort'])) {
		$is_term = false;
		foreach ($_SESSION[$stat]['select'] as $term) {
		    if (trim($term) != "") {
		        $is_term = true;
		    }
		}
		$query = ("SELECT * FROM $table ");
		if ($is_term) {
		    $query .= "WHERE ";
		}
		foreach ($_SESSION[$stat]['select'] as $term) {
		    if (trim($term) == "") {
		        continue;
		    }
		    $query .= $_SESSION[$stat]['column'] . " LIKE '%" . trim($term) . "%' OR ";
		}
		$query = rtrim($query, " OR ");
		$query .= " ORDER BY " . $_SESSION[$stat]['sort'] . " " . $_SESSION[$stat]['dir'];
		$result = $db_conn->query($query);
		$num_total_result = $result->num_rows;

		if ($_SESSION[$stat]['num_recs'] != "all") {
		    $query .= " limit " . $_SESSION[$stat]['num_recs'];
		}
	} else {
    // if this is the first time, then just order by line and display all rows //default
		$query = "SELECT * FROM $table ORDER BY date desc limit 10";
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
	if (empty($_SESSION[$stat]['sort'])) {
	    $num_total_result = $num_results;
	}
?>
<!-- QUERY -->
<form action="" method="post">
    <p class="pages">
		<span>Search for: </span>
<?php
	if (!empty($_SESSION[$stat]['select'])) {
		echo '<input type="text" size="35" name="search" value="' . implode(",", $_SESSION[$stat]["select"]) . '"\"/>';
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
				if (empty($_SESSION[$stat]['dir'])) {
					$_SESSION[$stat]['asc'] = "asc";
				}
				if ($_SESSION[$stat]['dir'] == "desc") {
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
				if (empty($_SESSION[$stat]['num_recs'])) {
					$_SESSION[$stat]['num_recs'] = "10";
				}
				if ($_SESSION[$stat]['num_recs'] == "20") {
					echo '<option selected value="20">20</option>';
				} else {
					echo '<option value="20">20</option>';
				}
				if ($_SESSION[$stat]['num_recs'] == "50") {
					echo '<option selected value="50">50</option>';
				} else {
					echo '<option value="50">50</option>';
				}
				if ($_SESSION[$stat]['num_recs'] == "all") {
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
