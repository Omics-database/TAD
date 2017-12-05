<?php				
	session_start();
	require_once('.private/all_fns.php');
	tsqlquery(); 
?>
<?PHP
	//Database Attributes
	$terms = explode(",", $_POST['search']);
		$is_term = false;
		foreach ($terms as $term) {
			if (trim($term) != "") {
				$is_term = true;
			}
		}
		$_SESSION[$table]['select'] = $terms;
?>
	<div class="menu">TransAtlasDB Database Query</div>
	<table width=100%><tr><td width=280pt>
		<div class="metactive"><a href="database.php">Relational Database</a></div>
		<div class="metamenu"><a href="database.php?quest=nosql">Non-relational Database</a></div>
	</td><td valign="top">
		<div class="dift"><p>Perform SQL DML.</p>
	<!-- QUERY -->
	<form action="" method="post">
    <p class="pages">
<?php
	if (!empty($_SESSION[$table]['select'])) {
		echo '<input type="text" size="35" name="search" value="' . implode(",", $_SESSION[$table]["select"]) . '"\"/>';
	} else {
		echo '<input type="text" size="35" name="search" placeholder="Enter variable(s) separated by commas (,)"/>';
	} 
?>
	</p>
		<p class="pages">
    <input type="submit" name="order" value="Go"/></p></div>
</form>
</div>
</td></tr></table>
	
<?php
  if ( !empty($_POST['order']) ) { //make sure an options is selected
	echo '<div class="menu">Results</div><div class="xtra">';
		$result = $db_conn->query($query);
		$result2 = "null";
		echo '<div class="dift"><p>Summary of Samples.</p>';
		about_display($result, $result2);
	?>
<?php
  $result ->free();
  $db_conn->close();
?>

</body>
</html>
