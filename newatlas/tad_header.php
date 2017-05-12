<?php
function theader() {
echo '
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>TransAtlasDB</title>

        <!-- Fonts -->
        <link href="https://fonts.googleapis.com/css?family=Raleway:100,600" rel="stylesheet" type="text/css">
        
        <!-- Styles -->
        <link rel="STYLESHEET" type="text/css" href="stylesheet.css">
        
        <div class="title sub-md">
            <a href="index.php">TransAtlasDB</a>
        </div>
        <center>
            <div class="links">
                <a href="about.php">About</a>
                <a href="dataimport.php">Data Import</a>
                <a href="metadata.php">MetaData</a>
                <a href="genes.php">Genes Expression</a>
                <a href="variants.php">Variants</a>
                <a href="https://modupeore.github.com/TransAtlasDB" target="_blank">GitHub</a>
            </div>
        </center>
    </head>
';
}
?>

<?php
function tmetadata() {
    theader();
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
<?PHP
    echo "</script></style>";
}
?>