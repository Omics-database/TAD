<?php
   include('config.php');
   session_start();
   
   $_SESSION['LAST_ACTIVITY'] = time() ; //update last activity time stamp
   if ((time() - $_SESSION['LAST_ACTIVITY']) > 100) { session_unset(); session_destroy(); }
   $user_check = $_SESSION['login_user'];
   
   $ses_sql = mysqli_query($db_conn,"select username from user where username = '$user_check' ");
   
   $row = mysqli_fetch_array($ses_sql,MYSQLI_ASSOC);
   
   $login_session = $row['username'];
   
   if(!isset($_SESSION['login_user'])){
      header("location:login.php");
   }
   
?>
