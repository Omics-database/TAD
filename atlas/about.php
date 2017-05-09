<?php
	session_start();
	require_once('atlas_header.php'); //The header
	require_once('atlas_fns.php'); //All the routines
        d_about_header(); //Display header
        $phpscript = "about.php";
?>
<table width=100%>
	<tr>
		<td align="left">
			<table width=70%>
				<tr>
					<th>Overview</th>
				</tr>
				<tr>
					<td><center>
						This website provides access to all the high-throughput transcriptome RNAseq libraries processed for gene expression analysis and variants information.
						The data is stored in an integrated MySQL and NoSQL (i.e. Fastbit) connecting expression analysis with corresponding metadata. In addition, gene-associated variants (such as SNPs and InDels) and their predicted gene effects obtained from our Variant Analysis Pipeline.
						Our aim is to provide an information rich and target platform for researchers to focus on specific genes or gene lists of interests and be able to retriee ecpression data based on defined parameters, as well as to easily access the variants associated with the genes specified and their predicted impact(s).
						<br><br>
					</center></td>
				</tr>
				<tr>
					<th>More details</th>
				</tr>
				<tr>
					<td>
						For more information: <a href="contact.php">contact us</a>
					</td>
				</tr>
			</table>
		</td>
		<td>
			<b>&nbsp;&nbsp;Summary of libraries processed</b><br>
			<?php $eee = shell_exec("perl ".$base_path."/SQLscripts/summarystats.pl "); echo $eee;?>
			<br>
			<b>&nbsp;&nbsp;Summary of database content</b><br>
			<?php $fff = shell_exec("perl ".$base_path."/SQLscripts/summarylibraries.pl "); echo $fff;?>
		</td>
	</tr>
</table>




