<?php
require_once('atlas_fns.php');
session_start();
?>
<?php //General Header
function d_header() {
  echo "
    <!DOCTYPE html><head>
      <link rel=\"STYLESHEET\" type=\"text/css\" href=\"stylefile.css\">
      <link rel=\"icon\" type=\"image/ico\" href=\"images/atlas_ico.png\"/>
      <header> <h1>Welcome ".$_SESSION['firstname']." </h1> </header>
      <div class=\"allofit\">
      <table width=100%>
        <tr>
          <td width=30px></td>
          <td width=100px align=\"center\">
            <a href=\"index.php\"><img src=\"images/atlas_main.png\" alt=\"Transcriptome Atlas\" ></a>
          </td>
          <td valign=\"center\" align=\"right\">
            <input type=\"button\" class=\"goback\" value=\"Return To Menu\" onclick=\"window.location.href='index.php'\"><br>
            <input type=\"button\" class=\"goback\" value=\"LogOut\" onclick=\"window.location.href='logout.php'\">
          </td>
          <td width=50px></td>
        </tr>
      </table>
      <script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-89812500-1', 'auto');
  ga('send', 'pageview');

</script>
    </head>
    <body>
      <div class=\"container\">
  ";
}
?>
<?php //About Page
function d_about_header() {
  d_header();
  echo "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\" />";
  echo "<title>About Us</title>";
  echo '<script type="text/javascript" src="/code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'></style>";
  echo '<table class="titlebutton"><tr><td>About <img src="images/instruct.png" width="45" height="45">
  </td></tr></table>';
}
?>
<?php //BigBird page
function d_bigbird_header() {
  d_header();
  echo "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\" />";
  echo "<title>BigBird</title>";
  echo '<script type="text/javascript" src="/code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'></style>";
  //atlas_authenticate();
  echo '<table class="titlebutton"><tr><td>Sample Information  <img src="images/import.png" width="45" height="45">
  </td></tr></table>';
}
?>
<?php //Metadata Pages
function d_metadata_header() {
  d_header();
  echo "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\" />";
  echo "<title>Metadata</title>";
  echo '<script type="text/javascript" src="/code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'></style>";
  ?>
  <script type="text/javascript">
    function selectAll(source) {
      checkboxes = document.getElementsByName('meta_data[]');
      for(var i in checkboxes)
        checkboxes[i].checked = source.checked;
    }
  </script></style>
  <?PHP
  //atlas_authenticate();
  echo '<table class="titlebutton"><tr><td>Meta-Data Information  <img src="images/metadata.gif" width="45" height="45">
  </td></tr></table>';
}
?>
<?php //Libraries Fpkm Page
function d_libfpkm_header() {
  d_header();
  echo "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\" />";
  echo "<title>Gene List</title>";
  echo '<script type="text/javascript" src="//code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'></style>";
  ?>
  <script type="text/javascript">
    function doit() {
      alert("Click OK to submit and wait for file to download");	
      document.geneall.submit();
    }
  </script>
  <?PHP
  //atlas_authenticate();
  echo '<table class="titlebutton"><tr><td>Gene Lists  <img src="images/libraries.png" width="45" height="45">
  </td></tr></table>
  <div class="explain"><p>Provide a list of library IDs to compare the FPKM values
        of all the genes.<br>This provides a
        tab-delimited <em>".txt"</em> file to easily compare the genes FPKM values
        across different samples.</p></div>';
}
?>
<?php //Genes Expression Page
function d_geneexp_header() {
  d_header();
  echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
  echo "<title>Gene Expression</title>";
  echo '<script type="text/javascript" src="//code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'>";
  echo '</style>';
  ?>
  <link href="jquery/jquery-ui-1.11.4.custom/jquery-ui.min.css" rel="stylesheet" type="text/css" />
  <script src="jquery/jquery-1.11.3.min.js"></script>
  <script src="jquery/jquery-ui-1.11.4.custom/jquery-ui.min.js"></script>
  <script type='text/javascript'>
    $(window).load(function(){
      $(document).ready(function () {
        toggleFields(); 
        $("#species").change(function () {
          toggleFields();
        });
      });
      function toggleFields() {
        if ($("#species").val() === "gallus") {
          $("#gallus").show();
          $(function() {
            var availableTags = <?php include("names/chickengene.php"); ?>;
            
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
        }
        else
          $("#gallus").hide();
        if($("#species").val() === "mus_musculus") {
          $("#mus_musculus").show();
          $(function() {
            var availableTags = <?php include("names/mousegene.php"); ?>;
            $("#genename").autocomplete({
              source: availableTags,
              autoFocus:true
            });
          });
        }
        else
          $("#mus_musculus").hide();
        if($("#species").val() === "alligator_mississippiensis") {
          $("#alligator_mississippiensis").show();
          $(function() {
            var availableTags = <?php include("names/alligatorgene.php"); ?>;
            $("#genename").autocomplete({
              source: availableTags,
              autoFocus:true
            });
          });
        }
        else
          $("#alligator_mississippiensis").hide();  
      }
    });
  </script>
  <script type='text/javascript'>
    $(window).load(function(){
    $('.myButton').click(function(){
        if ( this.value === 'collapse' ) {
            open = false;
            this.value = 'expand';
            $(this).next("div.cexpand").hide("slow");
        }
        else {
            open = true;
            this.value = 'collapse';
            $(this).siblings("[value='collapse']").click();
            $(this).next("div.cexpand").show("slow");
        }
    });
    });
  </script>
  <?PHP
  //atlas_authenticate();
  echo '<table class="titlebutton"><tr><td>Gene Expression Values  <img src="images/genes.png" width="45" height="45">
  </td></tr></table>
  <div class="explain"><p>View the expression (FPKM) values of the genes of interest<br>
      Provide a gene name and the species and the tissue.</p></div>';
}
?>
<?php //Variants Pages
function d_var_header() {
  d_header();
  echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
  echo "<title>Variant analysis</title>";
  echo '<script type="text/javascript" src="//code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'>";
  echo '</style>';
  ?>
  <link href="jquery/jquery-ui-1.11.4.custom/jquery-ui.min.css" rel="stylesheet" type="text/css" />
  <script src="jquery/jquery-1.11.3.min.js"></script>
  <script src="jquery/jquery-ui-1.11.4.custom/jquery-ui.min.js"></script>
  <?PHP
  //atlas_authenticate();
  echo '<div id="headmenu">
    <ul>
	  <li><a class="active" href="variants.php">Variants Information</a></li>
        <li><a href="kaksratios.php">KaKs Ratios</a></li>
    </ul>
  </div>';
  echo '<table class="titlebutton"><tr><td>Variants Information  <img src="images/variant.png" width="45" height="45">
  </td></tr></table>';
}
?>
  
<?php //KaKs Ratios Page
function d_kaks_header() {
  d_header();
  echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
  echo "<title>KAKS ratios</title>";
  echo '<script type="text/javascript" src="//code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'>";
  echo '</style>';
  ?>
  <link href="jquery/jquery-ui-1.11.4.custom/jquery-ui.min.css" rel="stylesheet" type="text/css" />
  <script src="jquery/jquery-1.11.3.min.js"></script>
  <script src="jquery/jquery-ui-1.11.4.custom/jquery-ui.min.js"></script>
  <script>
   $(function() {
      var availableTags = <?php include("names/chickengene.php"); ?>;
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
  <?PHP
  //atlas_authenticate();
  echo '<div id="headmenu">
    <ul>
	  <li><a href="variants.php">Variants Information</a></li>
        <li><a class="active" href="kaksratios.php">KaKs Ratios</a></li>
    </ul>
  </div>';
  echo '<table class="titlebutton"><tr><td>KaKs Ratios </td></tr></table>';
}
?>
