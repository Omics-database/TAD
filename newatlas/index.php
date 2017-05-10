<?php
	//require_once("display_fns.php");
	include("tad_header.php");
	session_start();
?>
	<title>
		TransAtlasDB
	</title>
		<table class="topic" align="center"><tr><td>Home</td></tr></table>
		<div>
			<p>
				TransAtlasDB is an integrated database application connecting samples metadata, expression and variant details from RNA sequencing analysis.
			</p>
			<p>
				This is the web interface for TransAtlasDB database application.
			</p>
			<br>
			<p>
				The following options are available view the web interface.
			</p>
			<table class="home">
				<tr><th>Data Import</th><th>Data Export</th></tr>
				<tr><td>Samples Metadata</td><td>Average fpkm</td></tr>
				<tr><td>RNAseq data</td><td>Individual Gene Expression</td></tr>
				<tr><td></td><td>Chromosomal variant distribution</td></tr>
				<tr><td></td><td>Variant Annotation Information</td></tr>
			</table>
		</div>
	</div>
</body>
