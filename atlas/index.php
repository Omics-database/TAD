<?php
	require_once("atlas_fns.php");
	session_start();
?>
<!DOCTYPE html>
	<head>
		<link rel="STYLESHEET" type="text/css" href="stylefile.css">
		<link rel="STYLESHEET" type="text/css" href="mainPage.css">
		<link rel="icon" type="image/ico" href="images/icon.png"/>
		<title>
			TransAtlasDB
		</title>
        </head>
	<body>
		<div class="allofit">
			<table>
				<tr>
					<td width=30px></td>
					<td align="center">
						<a href="index.php"><img src="images/atlas_main.png" alt="Transcriptome Atlas" ></a>
					</td>
				</tr>
			</table>
			<center>
				<div class="container">
					<table width=80%>
						<tr><td colspan="2" class="menu_header"><center><b>
							TranscriptAtlas is an integrated database connecting expression data from fRNAkenseq, curated metadata and variants using our Variants Analysis Pipeline.</b></center>

						</td></tr>
					</table>
					<div id="popup">
						<table>
							<tr>
								<!--samples-->
								<td class="menu_button">
									<a href="bigbird.php" class="TAbutton">Data Import
									<span class="right"><b>Import Samples:</b>
									<ul style="margin: 0; padding-right:20px; list-style: none;"><li>Insert samples into the database. Redirect to BigBird.</li></ul>
									</span></a>
								</td>
							</tr>
							<tr>
								<!--libraries-->
								<td class="menu_button">
									<a href="libfpkm.php" class="TAbutton"><br>Genes Average Expression levels
									<span class="right"><b>Libraries Expression Analysis:</b>
									<ul style="margin: 0; padding-left:20px; list-style: none;"><li>Provides the list of genes and their expression values of all the libraries specified.</li></ul>
									</span></a>
								</td>
								<!--geneexp-->
								<td class="menu_button">
									<a href="geneexp.php" class="TAbutton">Libraries - Genes Expression levels
									<span><b>Gene Expression Results:</b>
									<ul style="margin: 0; padding-right:20px; list-style: none;"><li>Gives basic statistics on genes expression FPKM values based on tissues of interest and distinct lines.</li></ul>
									</span></a>
								</td>
							</tr>
							<tr>
								<!--variant-->
								<td class="menu_button">
									<a href="variants.php" class="TAbutton">Variants and their gene effects
									<span class="right"><b>Variants Annotation:</b>
									<ul style="margin: 0; padding-left:20px; list-style: none;"><li>Gives lists of variants and annotation information based on chromosomal location or gene specified.</li></ul>
									</span></a>
								</td>
							</tr>
						</table>
					</div>
				</div>
			</center>
			<p align="right" ><font size="1">- Created by Modupe Adetunji at the University of Delaware - </font></p>
		</div>
	</body>
</html>




