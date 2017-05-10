<?php
	//require_once("display_fns.php");
	include("tad_header.php");
	session_start();
?>
		<title>
			TAD Export
		</title>
		<table class="topic" align="center"><tr><td>TransAtlasDB data export module</td></tr></table>
		<div>
			<p>
				TransAtlasDB export of data required.
			</p>
			<br>
			<p>
				Data export options are grouped in these four major categories.
			</p>
			<ol>
				<li>
					<p><a href="avgfpkm.php" >Average expression (fpkm) values of specified genes</a></p>
				</li>
				<li>
					<p><a href="genexp.php" >Expression (fpkm) values of genes across selected samples</a></p>
				</li>
                                <li>
                                        <p><a href="chrvar.php" >Chromosomal variant distribution across selected samples</a></p>
                                </li>
                                <li>
                                        <p><a href="varanno.php" >Variant Effect Information</a></p>
                                </li>
			</ol>
		</div>
	</div>
</body>
