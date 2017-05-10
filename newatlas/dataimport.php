<?php
	//require_once("display_fns.php");
	include("tad_header.php");
	session_start();
?>
		<title>
			TAD Import
		</title>
		<table class="topic" align="center"><tr><td>TransAtlasDB data import module</td></tr></table>
		<div>
			<p>
				TransAtlasDB import of samples metadata and RNA sequencing analysis results.
			</p>
			<br>
			<p>
				Import either of the following options, by uploading either files applicable. 
				<br>N.B. The Sample analysis results should be in compressed (zip or tar) format.
			</p>
			<ol>
				<li>
					<p>Samples Metadata</p>
				</li>
				<li>
					<p>Sample analysis results</p>
				</li>
			</ol>
		</div>
		<div>
			<p>
				Summary of libraries currently in the database.
			</p>
		</div>
	</div>
</body>
