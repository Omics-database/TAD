<?php
  include("config.php");
  require_once('atlas_header.php'); //The header
  require_once('atlas_fns.php'); //All the routines
  d_header(); //Display header
  echo "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\" />";
  echo "<title>Contact</title>";
  echo '<script type="text/javascript" src="//code.jquery.com/jquery-1.8.3.js"></script>';
  echo "<style type= 'text/css'></style>";
  echo '<table class="titlebutton"><tr><td>Contact  <img src="images/contact.png" width="45" height="45">
  </td></tr></table>
  <div class="explain"><p>If you have questions or comments about
  our application that we provide, we would be pleased to hear from you!</p></div>';
?>
<?php
  echo '<div class="contact">';
  echo '<form id="querys" class="top-border" action="contact.php" method="post">';
?>
    <table width="100%">
      <tr>
        <td align="right" valign="top" width="160">
          <label for="yourname"> Your Name : </label>
        </td>
        <td>
          <input type="text" class="contact" name="yourname"/>
        </td>
      </tr>
      <tr>
        <td align="right" valign="top">
          <label for="email"> Your Email (optional) :</label>
        </td>
        <td>
          <input type="text" class="contact" name="email"/>
        </td>
      </tr>
      <tr>
        <td align="right" valign="top">
          <label for="subject"> Subject : </label>
        </td>
        <td>
          <input type="text" class="contact" name="subject"/>
        </td>
      </tr>
      <tr>
        <td align="right" valign="top">
          <label for="comments"> Feedback / Question : </label>
        </td>
        <td>
          <textarea  name="comments" maxlength="1000" cols="50" rows="4"></textarea>
        </td>
      </tr>
      <tr>
        <td colspan=100%>
          <center>
            <input type="submit" name="contact" class="contact" value="Send Feedback/Questions">
          </center>
        </td>
      </tr>
    </table>   
</form>
</div>

  
<?php
if(isset($_POST['contact'])){
  echo "<center>";
  if((!empty($_POST['yourname']))&&(!empty($_POST['subject']))&&(!empty($_POST['comments']))){
    $name = $_POST['yourname'];
    $subject= $_POST["subject"];
    $message = $_POST['comments'];
    $email = $_POST['email'];
    $subject = '[transcriptAtlas] '.$subject.'--'.$_POST['yourname'];
    if (!empty($email)){
      $headers = 'From:'.$email."\r\n".'Reply-To:'.$email."\r\n".'X-Mailer: PHP/' . phpversion();
      @mail($email_to, $subject, $message, $headers);
    }
    else{
        @mail($email_to, $subject, $message);
    }
    echo "<p><b>Thanks for contacting us. We will be in touch with you very soon.</b></p>";
  }
  else{
    echo "<p><b>Your forgot to input your name or subject or mesage!</b></p>";
  }
}
echo "</center><br><br></div>";
?>
</body>
</html>
