<?php
  session_start();
  require_once('atlas_header.php'); //Display heads
  require_once('atlas_fns.php'); //All the routines
  d_var_header();
?>
  <div class="explain"><p><center>View variants based on chromosomal location or specific gene of interest from the following genomes.<br>
        The results provdes the list of variants and gene-annotation information.</center></p><br></div>
<?php
  if (!empty($_REQUEST['variantsview'] == "chicken"))  {
    $_SESSION['genomename'] = "Chicken";
    $_SESSION['species'] = "gallus";
    $_SESSION['variantlist'] = "names/chickenvariant.php";
  }
  elseif (!empty($_REQUEST['variantsview'] == "mouse")) {
    $_SESSION['genomename'] = "Mouse";
    $_SESSION['species'] = "mus_musculus";
    $_SESSION['variantlist'] = "names/mousevariant.php";
  }
  elseif (!empty($_REQUEST['variantsview'] == "alligator")) {
    $_SESSION['genomename'] = "Alligator";
    $_SESSION['species'] = "alligator_mississippiensis";
    $_SESSION['variantlist'] = "names/allivariant.php";
  }
  if (!empty($_SESSION['species']) && !empty($_REQUEST['variantsview'])){
    print "<script>window.location.href='variants-genename.php'</script>";
  }
?>
<form action="variants.php" method="post"><center>
  <input type="image" class="vbtn" src="images/hen.png" alt="CHICKEN" style="width:200px;height:200px;padding:10pt;border:solid black;border-radius:20px;" name="variantsview" value="chicken" />&nbsp;&nbsp;
  <input type="image" class="vbtn" src="images/mouse.png" alt="MOUSE" style="width:200px;height:200px;padding:10pt;border:solid black;border-radius:20px;" name="variantsview"  value="mouse" />&nbsp;&nbsp;
  <input type="image" class="vbtn" src="images/alligator.png" alt="ALLIGATOR" style="width:200px;height:200px;padding:10pt;border:solid black;border-radius:20px;" name="variantsview" value="alligator"/>&nbsp;&nbsp;
</center></form>

