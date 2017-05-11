<?php
	define('DB_SERVER', "localhost");
	define('DB_USERNAME', "root");
	define('DB_PASSWORD', "rainbow");
	define('DB_DATABASE', "transatlasdb");
	$db_conn = mysqli_connect('localhost',"root",'rainbow','transatlasdb'); //DB_SERVER,DB_USERNAME,DB_PASSWORD,DB_DATABASE);

	if (mysqli_connect_errno()){
		die("Database connection failed: " . mysqli_connect_error() . " (" . mysqli_connect_errno() . ")" );
	}
?>
