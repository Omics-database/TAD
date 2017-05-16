<?php
function db_display($result){
    $num_rows = $result->num_rows;
    echo '<form action="" method="post">';
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
                echo '<td headers="' . $meta->name . '" class="metadata"><center><img src="images/done.png" style="display:block;" width="20pt" height="20pt" ></center></td>';
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


<?php 
function metavw_display($result) {
    $num_rows = $result->num_rows;
    echo '<br><table class="metadata"><tr style="font-size:1.8vh;">';
    echo '<th align="left" width=40pt bgcolor="white"></th><th class="metadata" colspan=5>Analysis Summary</th><th class="metadata" colspan=3 style="color:#306269;">Mapping Metadata</th><th class="metadata" colspan=2 style="color:#306937;">Expression Metadata</th><th class="metadata" colspan=3 style="color:#693062;">Variant Metadata</th></tr><tr>';
    echo '<th align="left" width=40pt bgcolor="white"><font size="2" color="red">Select All</font><input type="checkbox" id="selectall" onClick="selectAll(this)" /></th>';
    $meta = $result->fetch_field_direct(0); echo '<th class="metadata" id="' . $meta->name . '">Sample Id</th>';
    $meta = $result->fetch_field_direct(1); echo '<th class="metadata" id="' . $meta->name . '">Total Fastq reads</th>';
    $meta = $result->fetch_field_direct(2); echo '<th class="metadata" id="' . $meta->name . '">Alignment Rate</th>';
    $meta = $result->fetch_field_direct(3); echo '<th class="metadata" id="' . $meta->name . '">Genes</th>';
    $meta = $result->fetch_field_direct(4); echo '<th class="metadata" id="' . $meta->name . '">Variants</th>';
    $meta = $result->fetch_field_direct(5); echo '<th class="metadata" style="color:#306269;" id="' . $meta->name . '">Mapping Tool</th>';
    $meta = $result->fetch_field_direct(6); echo '<th class="metadata" style="color:#306269;" id="' . $meta->name . '">Annotation file format</th>';
    $meta = $result->fetch_field_direct(7); echo '<th class="metadata" style="color:#306269;" id="' . $meta->name . '">Date</th>';
    $meta = $result->fetch_field_direct(8); echo '<th class="metadata" style="color:#306937;" id="' . $meta->name . '">Differential Expression Tool</th>';
    $meta = $result->fetch_field_direct(9); echo '<th class="metadata" style="color:#306937;" id="' . $meta->name . '">Date</th>';
    $meta = $result->fetch_field_direct(10); echo '<th class="metadata" style="color:#693062;" id="' . $meta->name . '">Variant Tool</th>';
    $meta = $result->fetch_field_direct(11); echo '<th class="metadata" style="color:#693062;" id="' . $meta->name . '">Variant Annotation Tool</th>';
    $meta = $result->fetch_field_direct(12); echo '<th class="metadata" style="color:#693062;" id="' . $meta->name . '">Date</th>';
    

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
<?php
function tabs_to_table($input) {
    //define replacement constants
    define('TAB_REPLACEMENT', "</center></td><td class='metadata'><center>");
    define('NEWLINE_BEGIN', "<tr%s><td class='metadata'><center>");
    define('NEWLINE_END', "</center></td></tr>");
    define('TABLE_BEGIN', "<table class='metadata'><tr><th class='metadata'>");
    define('TABLE_END', "</center></td></tr></table>");
    define('TAB_HEADER', "</th><th class='metadata'>");
    define('HEADER_END', "</th></tr>");

    //split the rows
    $rows = preg_split  ('/\n/'  , $input); $header = array_slice($rows,0,1); $rest = array_splice($rows,1);
    foreach ($header as $index => $row) {
        $row = preg_replace ('/\t/', TAB_HEADER , $row);
        $output = $row . HEADER_END;
    }      
    foreach ($rest as $index => $row) {
        $row = preg_replace  ('/\t/'  , TAB_REPLACEMENT  , $row);
        $output .= sprintf(NEWLINE_BEGIN, ($index%2?"":' class="odd"')) . $row . NEWLINE_END;
    }
    $input = TABLE_BEGIN. $output . "</table>";
    //build table
    //$input = TABLE_BEGIN . $output . TABLE_END;
    return ($input);
}
?>