<?php
//Very important!!!
session_start();
include("config.php");
include("session.php");
require_once('atlas_fns.php');
$date = shell_exec("date +%Y-%m-%d-%T");
$explodedate = substr($date,0,-1);
?>
<?php //Metadata Page function
function meta_display($action, $result, $primary_key) {
  $num_rows = $result->num_rows;
  echo '<br><table class="metadata"><tr>';
  echo '<th align="left" width=40pt bgcolor="white"><font size="2" color="red">Select All</font><input type="checkbox" id="selectall" onClick="selectAll(this)" /></th>';
  $meta = $result->fetch_field_direct(0); echo '<th class="metadata" id="' . $meta->name . '">' . library_id . '</th>';
  $meta = $result->fetch_field_direct(1); echo '<th class="metadata" id="' . $meta->name . '">' . bird_id . '</th>';
  $meta = $result->fetch_field_direct(2); echo '<th class="metadata" id="' . $meta->name . '">' . species . '</th>';
  $meta = $result->fetch_field_direct(3); echo '<th class="metadata" id="' . $meta->name . '">' . line . '</th>';
  $meta = $result->fetch_field_direct(4); echo '<th class="metadata" id="' . $meta->name . '">' . tissue . '</th>';
  $meta = $result->fetch_field_direct(5); echo '<th class="metadata" id="' . $meta->name . '">' . method . '</th>';
  $meta = $result->fetch_field_direct(6); echo '<th class="metadata" id="' . $meta->name . '">' . index . '</th>';
  $meta = $result->fetch_field_direct(7); echo '<th class="metadata" id="' . $meta->name . '">' . chip_result . '</th>';
  $meta = $result->fetch_field_direct(8); echo '<th class="metadata" id="' . $meta->name . '">' . scientist . '</th>';
  $meta = $result->fetch_field_direct(9); echo '<th class="metadata" id="' . $meta->name . '">' . date . '</th>';
  $meta = $result->fetch_field_direct(10); echo '<th class="metadata" id="' . $meta->name . '">' . notes . '</th>';
  $meta = $result->fetch_field_direct(11); echo '<th class="metadata" id="' . $meta->name . '">' . status . '</th></tr>';

  for ($i = 0; $i < $num_rows; $i++) {
    if ($i % 2 == 0) {
      echo "<tr class=\"odd\">";
    } else {
      echo "<tr class=\"even\">";
    }
    $row = $result->fetch_assoc();
    echo '<td><input type="checkbox" name="meta_data[]" value="'.$row[$primary_key].'"></td>';
    $j = 0;
    while ($j < $result->field_count) {
      $meta = $result->fetch_field_direct($j);
      if ($row[$meta->name] == "done"){
        echo '<td headers="' . $meta->name . '" class="metadata"><center><img src="images/done.png" width="20" height="20"></center></td>';
      } else {
        echo '<td headers="' . $meta->name . '" class="metadata"><center>' . $row[$meta->name] . '</center></td>';
      }
      $j++;
    }
    echo "</tr>";
  }
  echo "</table></form>";
}
?>

<?php //Sequence Page function
function metavw_display($action, $result, $primary_key) {
  $num_rows = $result->num_rows;
  echo '<br><table class="metadata"><tr>';
  echo '<th align="left" width=40pt bgcolor="white"><font size="2" color="red">Select All</font><input type="checkbox" id="selectall" onClick="selectAll(this)" /></th>';
  $meta = $result->fetch_field_direct(0); echo '<th class="metadata" id="' . $meta->name . '">Library id</th>';
  $meta = $result->fetch_field_direct(1); echo '<th class="metadata" id="' . $meta->name . '">Line</th>';
  $meta = $result->fetch_field_direct(2); echo '<th class="metadata" id="' . $meta->name . '">Species</th>';
  $meta = $result->fetch_field_direct(3); echo '<th class="metadata" id="' . $meta->name . '">Tissue</th>';
  $meta = $result->fetch_field_direct(4); echo '<th class="metadata" id="' . $meta->name . '">Total reads</th>';
  $meta = $result->fetch_field_direct(5); echo '<th class="metadata" id="' . $meta->name . '">Mapped reads</th>';
  $meta = $result->fetch_field_direct(6); echo '<th class="metadata" id="' . $meta->name . '">Genes</th>';
  $meta = $result->fetch_field_direct(7); echo '<th class="metadata" id="' . $meta->name . '">Isoforms</th>';
  $meta = $result->fetch_field_direct(8); echo '<th class="metadata" id="' . $meta->name . '">Variants</th>';
  $meta = $result->fetch_field_direct(9); echo '<th class="metadata" id="' . $meta->name . '">SNPs</th>';
  $meta = $result->fetch_field_direct(10); echo '<th class="metadata" id="' . $meta->name . '">INDELs</th>';
  $meta = $result->fetch_field_direct(11); echo '<th class="metadata" id="' . $meta->name . '">Sequences</th>';
	$meta = $result->fetch_field_direct(12); echo '<th class="metadata" id="' . $meta->name . '">Date</th></tr>';

  for ($i = 0; $i < $num_rows; $i++) {
    if ($i % 2 == 0) {
      echo "<tr class=\"odd\">";
    } else {
      echo "<tr class=\"even\">";
    }
    $row = $result->fetch_assoc();
    echo '<td><input type="checkbox" name="meta_data[]" value="'.$row[$primary_key].'"></td>';
    $j = 0;
    while ($j < $result->field_count) {
      $meta = $result->fetch_field_direct($j);
      echo '<td headers="' . $meta->name . '" class="metadata"><center>' . $row[$meta->name] . '</center></td>';
      $j++;
    }
    echo "</tr>";
  }
  echo "</table></form>";
}
?>

<?php //Accept input
function db_accept($phpscript, $table, $db_conn) {
    if (!empty($_REQUEST['accept'])) {
        echo '<form action="'.$phpscript.'" method="post">';
  ?>
	  <table width=100%>
	    <tr>
		<td align="right" class="lines">
		  <input type="submit" class="bigbird" name="reset" value="reject"/>
		  <input type="submit" class="bigbird" name="verified" value="accept"/>
		</td>
		<td>
		  <table class="lines" border="1" width=100%>
		    <tr class="even">
			<th class="lines"><strong><font size=2px>bird_id</font></strong></th>
			<th class="lines"><strong><font size=2px>species</font></strong></th>
			<th class="lines"><strong><font size=2px>line</font></strong></th>
			<th class="lines"><strong><font size=2px>tissue</font></strong></th>
			<th class="lines"><strong><font size=2px>method</font></strong></th>
			<th class="lines"><strong><font size=2px>index</font></strong></th>
			<th class="lines"><strong><font size=2px>chip_result</font></strong></th>
			<th class="lines"><strong><font size=2px>scientist</font></strong></th>
			<th class="lines"><strong><font size=2px>notes</font></strong></th>
		    </tr>
		    <tr class="odd">
		  <?PHP
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="bird_id" value="'.$_POST["bird_id"].'"/>'.$_POST["bird_id"].'</td>';	// bird_id
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="species" value="'.$_POST["species"].'"/>'.$_POST["species"].'</td>';	// species
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="line" value="'.$_POST["line"].'"/>'.$_POST["line"].'</td>';	// line
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="tissue" value="'.$_POST["tissue"].'"/>'.$_POST["tissue"].'</td>';	// tissue
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="method" value="'.$_POST["method"].'"/>'.$_POST["method"].'</td>';	// method
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="index_" value="'.$_POST['index_'].'"/>'.$_POST['index_'].'</td>';	// index
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="chip_result" value="'.$_POST['chip_result'].'"/>'.$_POST['chip_result'].'</td>';	// bird_id
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="scientist" value="'.$_POST['scientist'].'"/>'.$_POST['scientist'].'</td>';	// bird_id
		    echo '<td class="lines"><input type="hidden" class="bigbird" name="notes" value="'.$_POST['notes'].'"/>'.$_POST['notes'].'</td>';	// bird_id
		    echo '</tr></table></td></tr></table></form>';
    }
}
?>
		    
<?php //Insert values
function db_insert($table, $db_conn) {
    if (!empty($_REQUEST['verified'])) {
        $query = "SELECT * FROM $table";
        $result = $db_conn->query($query);
        $query = "INSERT INTO $table VALUES (";
        $i = 0;
        while ($i < $result->field_count) {
            $meta = $result->fetch_field_direct($i);
            if ($meta->flags & 512 || $meta->flags & 1024) {
                // if auto_increment or timestamp, insert as null
                $query = $query . "NULL" . ",";
            } elseif ($meta -> flags & 2) {
                $db_result = $db_conn->query("select max(library_id) max from bird_libraries");
		    if ($db_result->num_rows > 0) {while($row = $db_result->fetch_assoc()) {$maxnumber = $row["max"];}}
		    $maxnumber = $maxnumber+1;
                $query = $query . "'".$maxnumber."',";
		} elseif (($meta->type == 253 || $meta->type == 254 || $meta->type == 10
              || $meta->type == 11) && !empty($_POST[$meta->name])) {
                // if it's a text field or date, add single quotes
                $query = $query . "'" . $_POST[$meta->name] . "'" . ",";
            } elseif ($meta->type == 12){
		    $query = $query. "'". date('Y-m-d H:i:s')."',";
		}
		elseif (empty($_POST[$meta->name])) {
                $query = $query . "NULL" . ",";
            } else {
                $query = $query . $_POST[$meta->name] . ",";
            }
            $i++;
        }
        $query = rtrim($query, ",");
        $query = $query . ")";

        $result = $db_conn->query($query);
        echo '<div id="insert-status"';
        if (!$result) {
            echo "<span><strong>Insert unsuccessful.</strong></span>";
            echo "<span><strong>Query: </strong>$query</span>";
            echo "<span><strong>Errormessage: </strong>" . $db_conn->error . "</span>";
        } else {
            echo "<span><strong>Insert successful.</strong></span><br>";
		echo '<span><strong>Library ID is '.$maxnumber.'.</strong></span><br>';
		echo "<span>" . $db_conn->affected_rows . " row inserted into $table </span><br>";
        }
        echo '</div>';
    }
}
?>
<?php //Display values
function db_display($action, $result, $primary_key) {
    $num_rows = $result->num_rows;
    echo '<form action="' . $action . '" method="post">';
    echo '<table class="metadata"><tr>';
    $meta = $result->fetch_field_direct(0); echo '<th class="metadata" id="' . $meta->name . '">' . library_id . '</th>';
    $meta = $result->fetch_field_direct(1); echo '<th class="metadata" id="' . $meta->name . '">' . bird_id . '</th>';
    $meta = $result->fetch_field_direct(2); echo '<th class="metadata" id="' . $meta->name . '">' . species . '</th>';
    $meta = $result->fetch_field_direct(3); echo '<th class="metadata" id="' . $meta->name . '">' . line . '</th>';
    $meta = $result->fetch_field_direct(4); echo '<th class="metadata" id="' . $meta->name . '">' . tissue . '</th>';
    $meta = $result->fetch_field_direct(5); echo '<th class="metadata" id="' . $meta->name . '">' . method . '</th>';
    $meta = $result->fetch_field_direct(6); echo '<th class="metadata" id="' . $meta->name . '">' . index . '</th>';
    $meta = $result->fetch_field_direct(7); echo '<th class="metadata" id="' . $meta->name . '">' . chip_result . '</th>';
    $meta = $result->fetch_field_direct(8); echo '<th class="metadata" id="' . $meta->name . '">' . scientist . '</th>';
    $meta = $result->fetch_field_direct(9); echo '<th class="metadata" id="' . $meta->name . '">' . date . '</th>';
    $meta = $result->fetch_field_direct(10); echo '<th class="metadata" width=20% id="' . $meta->name . '">' . notes . '</th>';
    echo '</tr>';
    for ($i = 0; $i < $num_rows; $i++) {
      if ($i % 2 == 0) {
          echo "<tr class=\"odd\">";
      } else {
          echo "<tr class=\"even\">";
      }
      $row = $result->fetch_assoc();
      $pk_values_string = "";
      foreach ($primary_key as $pk) {
          $pk_values_string = "$pk_values_string,$row[$pk]";
      }
      $pk_values_string = ltrim($pk_values_string, ",");
      $j = 0;
      while ($j < $result->field_count) {
        $meta = $result->fetch_field_direct($j);
        if (in_array($meta->name, $primary_key)) {
            echo '<td headers="' . $meta->name . '" class="metadata"><center>' . $row[$meta->name] . '</center></td>';
        } else {
            echo '<td headers="' . $meta->name . '" class="metadata"><center>' . $row[$meta->name] . '</center></td>';
        }
        $j++;
      }
      echo "</tr>";
    }
    echo '</table></form>';
}
?>
<?php //Reset entry
  function db_reset() {
    if (!empty($_REQUEST['reset'])) {
      header('Location: http://raven.anr.udel.edu/~modupe/atlas/bigbird.php');
    }
  }
?>
