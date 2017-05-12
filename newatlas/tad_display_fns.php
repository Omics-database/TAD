<?php
function db_display($result){
    $num_rows = $result->num_rows;
    echo '<form action="dataimport.php" method="post">';
    echo '<table class="metadata"><tr>';    
    $meta = $result->fetch_field_direct(0); echo '<th class="metadata" id="' . $meta->name . '">Sample Id</th>';
    $meta = $result->fetch_field_direct(1); echo '<th class="metadata" id="' . $meta->name . '">Animal Id</th>';
    $meta = $result->fetch_field_direct(2); echo '<th class="metadata" id="' . $meta->name . '">Species</th>';
    $meta = $result->fetch_field_direct(3); echo '<th class="metadata" id="' . $meta->name . '">Tissue</th>';
    $meta = $result->fetch_field_direct(4); echo '<th class="metadata" id="' . $meta->name . '">Person</th>';
    $meta = $result->fetch_field_direct(5); echo '<th class="metadata" id="' . $meta->name . '">Organization</th>';
    $meta = $result->fetch_field_direct(6); echo '<th class="metadata" id="' . $meta->name . '">Animal Description</th>';
    $meta = $result->fetch_field_direct(7); echo '<th class="metadata" id="' . $meta->name . '">Sample Description</th>';
    $meta = $result->fetch_field_direct(8); echo '<th class="metadata" id="' . $meta->name . '">Date</th>';
    
    echo '</tr>';
    for ($i = 0; $i < $num_rows; $i++) {
      if ($i % 2 == 0) {
          echo "<tr class=\"odd\">";
      } else {
          echo "<tr class=\"even\">";
      }
      $row = $result->fetch_assoc();
      $j = 0;
      while ($j < $result->field_count) {
        $meta = $result->fetch_field_direct($j);
        echo '<td headers="' . $meta->name . '" class="metadata"><center>' . $row[$meta->name] . '</center></td>';
        $j++;
      }
      echo "</tr>";
    }
    echo '</table></form>';
}
?>

<?php 
function meta_display($result) {
    $num_rows = $result->num_rows;
    echo '<br><table class="metadata"><tr>';
    echo '<th align="left" width=40pt bgcolor="white"><font size="2" color="red">Select All</font><input type="checkbox" id="selectall" onClick="selectAll(this)" /></th>';
    $meta = $result->fetch_field_direct(0); echo '<th class="metadata" id="' . $meta->name . '">Sample Id</th>';
    $meta = $result->fetch_field_direct(1); echo '<th class="metadata" id="' . $meta->name . '">Animal Id</th>';
    $meta = $result->fetch_field_direct(2); echo '<th class="metadata" id="' . $meta->name . '">Organism</th>';
    $meta = $result->fetch_field_direct(3); echo '<th class="metadata" id="' . $meta->name . '">Tissue</th>';
    $meta = $result->fetch_field_direct(4); echo '<th class="metadata" id="' . $meta->name . '">Sample Description</th>';
    $meta = $result->fetch_field_direct(5); echo '<th class="metadata" id="' . $meta->name . '">Date</th>';
    $meta = $result->fetch_field_direct(6); echo '<th class="metadata" id="' . $meta->name . '">Gene Status</th>';
    $meta = $result->fetch_field_direct(7); echo '<th class="metadata" id="' . $meta->name . '">Variant Status</th></tr>';

    for ($i = 0; $i < $num_rows; $i++) {
        if ($i % 2 == 0) {
            echo "<tr class=\"odd\">";
        } else {
            echo "<tr class=\"even\">";
        }
        $row = $result->fetch_assoc();
        echo '<td><input type="checkbox" name="meta_data[]" value="'.$row['sampleid'].'"></td>';
        $j = 0;
        while ($j < $result->field_count) {
            $meta = $result->fetch_field_direct($j);
            if ($row[$meta->name] == "done"){
                echo '<td headers="' . $meta->name . '" class="metadata"><center><img src="images/done.png" style="display:block;" width="10%" height="10%" ></center></td>';
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
