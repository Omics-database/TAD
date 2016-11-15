#!/usr/bin/env perl
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Spec;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use DBI;
use CC::Create;
use CC::Parse;

our $VERSION = '$ Version: 1 $';
our $DATE = '$ Date: 2016-10-28 14:40:00 (Fri, 28 Oct 2016) $';
our $AUTHOR= '$ Author:Modupe Adetunji <amodupe@udel.edu> $';

#--------------------------------------------------------------------------------

our ($verbose, $efile, $help, $man);
our ($metadata, $tab, $excel, $datadb, $gene, $variant, $all, $vep, $annovar); #command options
our ($file2consider,$connect); #connection and file details
my ($sth,$dbh,$schema); #connect to database;

my ($name, $description, $derivedfrom, $organism, $tissue, $collection, $scientist, $organization); #metadata table
our (%specimen, %filecontent, %description, %organism);

#data2db options
our ($found);
our (@allgeninfo);
my ($str, $ann, $ref, $seq,$allstart, $allend) = (0,0,0,0,0,0); #for log file
my ($refgenome, $stranded, $sequences, $annotation, $annotationfile); #for annotation file

#genes import
our ($acceptedbam, $alignfile, $genesfile,$isoformsfile, $deletionsfile, $insertionsfile, $junctionsfile, $prepfile, $logfile, $variantfile, $vepfile, $annofile);
our ($total, $mapped, $unmapped, $deletions, $insertions, $junctions, $genes, $isoforms,$prep);
#varaint import
our ( %VCFhash, %DBSNP, %extra, %VEPhash, %ANNOhash );
our ($varianttool, $verd, $variantclass);
our ($itsnp,$itindel,$itvariants) = (0,0,0);
#date
my $date = `date +%Y-%m-%d`;

#--------------------------------------------------------------------------------

sub printerr; #declare error routine
our $default = DEFAULTS(); #default error contact
processArguments(); #Process input

my %all_details = %{connection($connect, $default)}; #get connection details

#PROCESSING METADATA
if ($metadata){
  $dbh = mysql($all_details{"MySQL-databasename"}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
  if ($tab) { #unix tab delimited file
    printerr "JOB:\t Importing Sample Information from tab-delimited file => $file2consider\n"; #status
    %filecontent = %{ tabcontent($file2consider) }; #get content from tab-delimited file
    foreach my $row (sort keys %filecontent){

      if (exists $filecontent{$row}{'sample name'}) { #sample name
	$name = $filecontent{$row}{'sample name'};
      } else {
	pod2usage("\nFAILED:\t Error in tab-delimited file \"$file2consider\".\n\tCheck => ROW: $row, COLUMN: \"Sample Name\"");
      } #end if for getting sample information 
      $sth = $dbh->prepare("select sampleid from Sample where sampleid = '$name'"); $sth->execute(); $found = $sth->fetch();
      unless ($found) { # if sample is not in the database
	$scientist = $filecontent{$row}{'scientist'};  #scientist
	$organization = $filecontent{$row}{'organization name'}; #organization name
		
	if (exists $filecontent{$row}{'organism'}) { #organism
 	  $organism = $filecontent{$row}{'organism'};
	} else {
	  die "\nFAILED:\t Error in tab-delimited file \"$file2consider\".\n\tCheck => ROW: $row, COLUMN: \"Organism\"\n";
	} #end if for animal info
	$description = $filecontent{$row}{'sample description'}; #description
	if (exists $filecontent{$row}{'derived from'}) { #animal
	  $derivedfrom = uc($filecontent{$row}{'derived from'});
	} else {
	  die "\nFAILED:\t Error in tab-delimited file \"$file2consider\".\n\tCheck => ROW: $row, COLUMN: \"Derived From\"\n";
	} #end if for animal id
	unless (exists $filecontent{$row}{'organism part'}) { #tissue
	  $tissue = $filecontent{$row}{'organism part'};
	} else {
	  $tissue = $filecontent{$row}{'sample description'};
	} #end if for tissue
	if (exists $filecontent{$row}{'specimen collection date'}){
	  $collection =$filecontent{$row}{'specimen collection date'};
	my @date = split('-', $collection);
	if ($#date == 0) {$collection = $date[0]."0101";}
	elsif ($#date == 1) { $collection = $date[0].$date[1]."01";}
	elsif ($#date == 2) { $collection = $date[0].$date[1].$date[2];}
	else {$collection = undef;}
	} else {
	  $collection = undef;
	} #end id for specimen collection date
	printerr "NOTICE:\t Importing $name to Sample table\n"; #import to database
	$sth = $dbh->prepare("insert into Sample (sampleid, sampleinfo, derivedfrom, organism, tissue, collectiondate, scientist, organizationname) values (?,?,?,?,?,?,?,?)");
	$sth->execute($name, $description,$derivedfrom,$organism, $tissue, $collection, $scientist, $organization) or die "\nERROR:\t Complication in Sample table, contact $AUTHOR\n";
	$sth-> finish; #end of query
      } else {
        $verbose and printerr "Duplicate (Already exists):\t$name\n"; #import to database
      } #end unless in the database
    } #end foreach filecontent
  } #end if (tab-delimited)
  else { #import faang excel sheet
    printerr "JOB:\t Importing Sample Information from excel file => $file2consider\n"; #status    
    %filecontent = %{ excelcontent($file2consider) }; #get excel content
    #get name information
    if (exists $filecontent{2}{'person%person first name'}){
      $scientist = "$filecontent{2}{'person%person first name'} $filecontent{2}{'person%person initials'} $filecontent{2}{'person%person last name'}";
    } else {$scientist = undef;} #end if for scientist
    if (exists $filecontent{2}{'organization%organization name'}){
      $organization = $filecontent{2}{'organization%organization name'};
    } else {$organization = undef;} #end if for organization name
    #get specimen information
    foreach my $row (sort keys %filecontent){
      foreach my $column (keys %{$filecontent{$row}}){
	if ($column =~ /^specimen.*/){
  	  $specimen{$row}{$column} = $filecontent{$row}{$column};
	} #end if for getting sample information
      } #end foreach
    } #end foreach
		
    #get animal information
    foreach my $row (sort keys %filecontent){
      foreach my $column (keys %{$filecontent{$row}}){
        if ($column =~ /^animal%sample name/){
	  $description{uc($filecontent{$row}{'animal%sample name'})}= $filecontent{$row}{'animal%sample description'};
	  if (exists $filecontent{$row}{'animal%organism'}) {
	    $organism{uc($filecontent{$row}{'animal%sample name'})}= $filecontent{$row}{'animal%organism'};
	  } else {
	    die "\nFAILED:\t Error in Excel file \"$file2consider\".\n\t Check => SHEET: animal, ROW: $row, COLUMN: \"Organism\"\n";
	  } #end if for animal information
	} #end if for animal id
      } #end foreach
    } #end foreach
		
    #attributes of interest
    foreach my $row  (sort keys %specimen){
      if (exists $filecontent{$row}{'specimen%sample name'}) {
	$name = $filecontent{$row}{'specimen%sample name'};
      } else {
	die "\nFAILED:\t Error in Excel file \"$file2consider\".\n\t Check => SHEET: specimen, ROW: $row, COLUMN: \"Sample Name\"\n";
      } #end if to get sampleid
      $sth = $dbh->prepare("select sampleid from Sample where sampleid = '$name'"); $sth->execute(); $found = $sth->fetch();
      unless ($found) { # if sample is not in the database
	if (exists $filecontent{$row}{'specimen%derived from'}) {
  	  $derivedfrom = uc($filecontent{$row}{'specimen%derived from'});
	} else {
	  die "\nFAILED:\t Error in Excel file \"$file2consider\".\n\t Check => SHEET: specimen, ROW: $row, COLUMN: \"Derived From\"\n";
	} #end if for animal id
	unless (exists $filecontent{$row}{'specimen%organism part'}) {
	  $tissue = $filecontent{$row}{'specimen%organism part'};
	} else {
	  $tissue = $filecontent{$row}{'specimen%sample description'};
	} #end if for tissue 
	if (exists $filecontent{$row}{'specimen%specimen collection date'}){
	  $collection =$filecontent{$row}{'specimen%specimen collection date'};
	  my @date = split('-', $collection);
	  if ($#date == 0) {$collection = $date[0]."0101";}
	  elsif ($#date == 1) { $collection = $date[0].$date[1]."01";}
	  elsif ($#date == 2) { $collection = $date[0].$date[1].$date[2];}
	  else {$collection = undef;}
	} else {
	  $collection = undef;
	} #end if for specimen collection date
	$sth = $dbh->prepare("insert into Sample (sampleid, sampleinfo, derivedfrom, organism, tissue, collectiondate, scientist, organizationname) values (?,?,?,?,?,?,?,?)");
	unless (exists $organism{$derivedfrom}) {
	  die "\nFAILED:\t Error in Excel file \"$file2consider\".\n\t Animal \"$derivedfrom\" information is not provided in SHEET: animal\n";
	} #check to make sure animal information from specimen sheet is provided
	printerr "NOTICE:\t Importing $name to Sample table\n"; #import to database
	$sth->execute($name, $description{$derivedfrom},$derivedfrom,$organism{$derivedfrom}, $tissue, $collection, $scientist, $organization) or die "\nERROR:\t Complication in Sample table, contact $AUTHOR\n";
	      $sth-> finish; #end of query
      } else {
        $verbose and printerr "Duplicate (Already exists):\t$name\n"; #import to database
      } #end unless in the database
    } #end foreach specimen; attribute of interest
  } #end if excel
} #end if metadata

#PROCESSING DATA IMPORT
if ($datadb) {
  printerr "JOB:\t Importing Transcriptome analysis Information => $file2consider\n"; #status
  if ($variant){
    printerr "TASK:\t Importing ONLY Variant Information => $file2consider\n"; #status
  } elsif ($all) {
    printerr "TASK:\t Importing BOTH Gene Expression profiling and Variant Information => $file2consider\n"; #status
  } else {
    printerr "TASK:\t Importing ONLY Gene Expression Profiling information => $file2consider\n"; #status
  }
  $dbh = mysql($all_details{"MySQL-databasename"}, $all_details{'MySQL-username'}, $all_details{'MySQL-password'}); #connect to mysql
  my $dataid = (split("\/", $file2consider))[-1]; 
  `find $file2consider` or pod2usage ("ERROR: Can not locate \"$file2consider\"");
  opendir (DIR, $file2consider) or pod2usage ("Error: $file2consider is not a folder, please specify your sample location"); close (DIR);
  my @foldercontent = split("\n", `find $file2consider`); #get details of the folder
  $acceptedbam = (grep /accepted_hits.bam/, @foldercontent)[0];
  $alignfile = (grep /align_summary.txt/, @foldercontent)[0];
  $genesfile = (grep /genes.fpkm/, @foldercontent)[0];
  $isoformsfile = (grep /isoforms.fpkm/, @foldercontent)[0];
  $deletionsfile = (grep /deletions.bed/, @foldercontent)[0];
  $insertionsfile = (grep /insertions.bed/, @foldercontent)[0];
  $junctionsfile = (grep /junctions.bed/, @foldercontent)[0];
  $prepfile = (grep /prep_reads.info/,@foldercontent)[0];
  $logfile = (grep /logs\/run.log/, @foldercontent)[0];
  $variantfile = (grep /.vcf$/, @foldercontent)[0]; 
  $vepfile = (grep /.vep.txt$/, @foldercontent)[0];
  $annofile = (grep /anno.txt$/, @foldercontent)[0];
 
  $sth = $dbh->prepare("select sampleid from Sample where sampleid = '$dataid'"); $sth->execute(); $found = $sth->fetch();
  if ($found) { # if sample is not in the database    
    $sth = $dbh->prepare("select sampleid from MapStats where sampleid = '$dataid'"); $sth->execute(); $found = $sth->fetch();
    unless ($found) { 
      LOGFILE(); #parse logfile details
      #open alignment summary file
      if ($alignfile) {
        open(ALIGN,"<", $alignfile) or die "\nFAILED:\t Can not open Alignment summary file '$alignfile'\n";
        while (<ALIGN>){
          chomp;
          if (/Input/){my $line = $_; $line =~ /Input.*:\s+(\d+)$/;$total = $1;}
          if (/Mapped/){my $line = $_; $line =~ /Mapped.*:\s+(\d+).*$/;$mapped = $1;}
        } close ALIGN;
        $unmapped = $total-$mapped;
        $prep = `cat $prepfile`;
      } else {die "\nFAILED:\t Can not find Alignment summary file '$alignfile'\n";}
      #INSERT INTO DATABASE:
      #MapStats table
      printerr "NOTICE:\t Importing $dataid to MapStats table ..."; 
      $sth = $dbh->prepare("insert into MapStats (sampleid, totalreads, mappedreads, unmappedreads, infoprepreads, date ) values (?,?,?,?,?,?)");
      $sth ->execute($dataid, $total, $mapped, $unmapped, $prep, $date) or die "\nERROR:\t Complication in MapStats table, contact $AUTHOR\n";
      printerr " Done\n";
      #metadata table
      printerr "NOTICE:\t Importing $dataid to Metadata table ...";
      $sth = $dbh->prepare("insert into Metadata (sampleid, refgenome, annfile, stranded, sequencename ) values (?,?,?,?,?)");
      $sth ->execute($dataid, $refgenome, $annotationfile, $stranded,$sequences) or die "\nERROR:\t Complication in Metadata table, contact $AUTHOR\n";
      printerr " Done\n";
      
      #toggle options
      unless ($variant) {
        GENE_INFO($dataid);
        #FPKM tables
        printerr "NOTICE:\t Importing $dataid - Genes to GenesFpkm table ...";
        FPKM('GenesFpkm', $genesfile, $dataid); #GENES
        printerr " Done\n";
        printerr "NOTICE:\t Importing $dataid - Isoforms to IsoformsFpkm table ...";
        FPKM('IsoformsFpkm', $isoformsfile, $dataid); #ISOFORMS
        printerr " Done\n";
        $sth = $dbh->prepare("update GeneStats set status = 'done' where sampleid = '$dataid'");
        $sth ->execute() or die "\nERROR:\t Complication in GeneStats table, contact $AUTHOR\n";
        if ($all){
          printerr "NOTICE:\t Importing $dataid - Variants to VarResult table ...";
          DBVARIANT($variantfile, $dataid);
          printerr " Done\n";
          #variant annotation specifications
          if ($vep) {
            printerr "TASK:\t Importing Variant annotation from VEP => $file2consider\n"; #status
  	    printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
            VEPVARIANT($vepfile, $dataid); printerr " Done\n";
          }
          if ($annovar) {
            printerr "TASK:\t Importing Variant annotation from ANNOVAR => $file2consider\n"; #status
  	    printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
            ANNOVARIANT($annofile, $dataid); printerr " Done\n";
          }
        }
      }
      else { #variant option selected
        printerr "NOTICE:\t Importing $dataid - Variants to VarResult table ...";
        DBVARIANT($variantfile, $dataid);
        printerr " Done\n";
        #variant annotation specifications
        if ($vep) {
	  printerr "TASK:\t Importing Variant annotation from VEP => $file2consider\n"; #status
          printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
          VEPVARIANT($vepfile, $dataid); printerr " Done\n";
        }
        if ($annovar) {
          printerr "TASK:\t Importing Variant annotation from ANNOVAR => $file2consider\n"; #status
  	  printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
          ANNOVARIANT($annofile, $dataid); printerr " Done\n";
        }
      }
    } else { #end unless found in MapStats table
      $verbose and printerr "NOTICE:\t $dataid already in MapStats table... Moving on ...\n";
      $sth = $dbh->prepare("select sampleid from Metadata where sampleid = '$dataid'"); $sth->execute(); $found = $sth->fetch();
      unless ($found) {
        printerr "NOTICE:\t Importing $dataid to MapStats table ...";
        $sth = $dbh->prepare("insert into Metadata (sampleid,refgenome, annfile, stranded, sequencename ) values (?,?,?,?,?)");
        $sth ->execute($dataid, $refgenome, $annotationfile, $stranded,$sequences) or die "\nERROR:\t Complication in Metadata table\n";
        printerr " Done\n";
      } #end else found in MapStats table
      #toggle options
      unless ($variant) {
        GENE_INFO($dataid);
        my $genecount = 0; $genecount = $dbh->selectrow_array("select genes from GeneStats where sampleid = '$dataid'");
        unless ($genes == $genecount) { # processing for GenesFpkm
          $verbose and printerr "NOTICE:\t Removed incomplete records for $dataid in GenesFpkm table\n";
          $sth = $dbh->prepare("delete from GenesFpkm where sampleid = '$dataid'"); $sth->execute();
          printerr "NOTICE:\t Importing $dataid - Genes to GenesFpkm table ...";
          FPKM('GenesFpkm', $genesfile, $dataid); #GENES
          printerr " Done\n";
        } else {
          $verbose and printerr "NOTICE:\t $dataid already in GenesFpkm table... Moving on ...\n";
        } #end gene unless
        my $isoformscount = 0; $isoformscount = $dbh->selectrow_array("select isoforms from GeneStats where sampleid = '$dataid'");
        unless ($isoforms == $isoformscount) { # processing for IsoformsFpkm
          $verbose and printerr "NOTICE:\t Removed incomplete records for $dataid in IsoformsFpkm table\n";
          $sth = $dbh->prepare("delete from IsoformsFpkm where sampleid = '$dataid'"); $sth->execute();
          printerr "NOTICE:\t Importing $dataid - Isoforms to IsoformsFpkm table ...";
          FPKM('IsoformsFpkm', $isoformsfile, $dataid); #ISOFORMS
          printerr " Done\n";
        } else {
          $verbose and printerr "NOTICE:\t $dataid already in Isoforms table... Moving on ...\n";
        }# end isoforms unless
        $sth = $dbh->prepare("update GeneStats set status = 'done' where sampleid = '$dataid'");
        $sth ->execute() or die "\nERROR:\t Complication in GeneStats table, contact $AUTHOR\n";
        if ($all){
          my $variantstatus = $dbh->selectrow_array("select status from VarSummary where sampleid = '$dataid'");
          unless ($variantstatus){ #checking if completed in VarSummary table
            $verbose and printerr "NOTICE:\t Removed incomplete records for $dataid in all Variants tables\n";
            $sth = $dbh->prepare("delete from VarAnno where sampleid = '$dataid'"); $sth->execute();
            $sth = $dbh->prepare("delete from VarResult where sampleid = '$dataid'"); $sth->execute();
            $sth = $dbh->prepare("delete from VarSummary where sampleid = '$dataid'"); $sth->execute();
            printerr "NOTICE:\t Importing $dataid - Variants to VarResult table ...";
            DBVARIANT($variantfile, $dataid);
            printerr " Done\n";
            #variant annotation specifications
            if ($vep) {
	      printerr "TASK:\t Importing Variant annotation from VEP => $file2consider\n"; #status
              printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
              VEPVARIANT($vepfile, $dataid); printerr " Done\n";
            }
            if ($annovar) {
	      printerr "TASK:\t Importing Variant annotation from ANNOVAR => $file2consider\n"; #status
              printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
              ANNOVARIANT($annofile, $dataid); printerr " Done\n";
            }
          } else {
            if ($vep || $annovar) {
              my $variantstatus = $dbh->selectrow_array("select annversion from VarSummary where sampleid = '$dataid'");
              unless ($variantstatus){
                $verbose and printerr "NOTICE:\t Removed incomplete records for $dataid in all Variant Annotation tables\n";
                $sth = $dbh->prepare("delete from VarAnno where sampleid = '$dataid'"); $sth->execute();
                if ($vep) {
 		  printerr "TASK:\t Importing Variant annotation from VEP => $file2consider\n"; #status
                  printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
                  VEPVARIANT($vepfile, $dataid); printerr " Done\n";
                }
                if ($annovar) {
                  printerr "TASK:\t Importing Variant annotation from ANNOVAR => $file2consider\n"; #status
  		  printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
                  ANNOVARIANT($annofile, $dataid); printerr " Done\n";
                }
              } else { #end unless annversion is previously specified
                $verbose and printerr "NOTICE:\t $dataid already in VarResult table... Moving on ...\n";
                $verbose and printerr "NOTICE:\t $dataid already in VarAnno table... Moving on ...\n";
              }
            } else {
              $verbose and printerr "NOTICE:\t $dataid already in VarResult table... Moving on ...\n";
            } #end if annversion is previously specified
          } #end unless it's already in variants table
        } #end if "all" option
      } #end unless default option is specified 
      else { #variant option selected
        my $variantstatus = $dbh->selectrow_array("select status from VarSummary where sampleid = '$dataid'");
        unless ($variantstatus){ #checking if completed in VarSummary table
          $verbose and printerr "NOTICE:\t Removed incomplete records for $dataid in all Variants tables\n";
          $sth = $dbh->prepare("delete from VarAnno where sampleid = '$dataid'"); $sth->execute();
          $sth = $dbh->prepare("delete from VarResult where sampleid = '$dataid'"); $sth->execute();
          $sth = $dbh->prepare("delete from VarSummary where sampleid = '$dataid'"); $sth->execute();
          printerr "NOTICE:\t Importing $dataid - Variants to VarResult table ...";
          DBVARIANT($variantfile, $dataid);
          printerr " Done\n";
          #variant annotation specifications
          if ($vep) {
            printerr "TASK:\t Importing Variant annotation from VEP => $file2consider\n"; #status
            printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
            VEPVARIANT($vepfile, $dataid); printerr " Done\n";
          }
          if ($annovar) {
            printerr "TASK:\t Importing Variant annotation from ANNOVAR => $file2consider\n"; #status
            printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
            ANNOVARIANT($annofile, $dataid); printerr " Done\n";
          }
        } else { #if completed in VarSummary table
          if ($vep || $annovar) { #checking if vep or annovar was specified
            my $variantstatus = $dbh->selectrow_array("select annversion from VarSummary where sampleid = '$dataid'");
            unless ($variantstatus){ #if annversion is not specified
              $verbose and printerr "NOTICE:\t Removed incomplete records for $dataid in all Variant Annotation tables\n";
              $sth = $dbh->prepare("delete from VarAnno where sampleid = '$dataid'"); $sth->execute();
              if ($vep) {
                printerr "TASK:\t Importing Variant annotation from VEP => $file2consider\n"; #status
                printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
                VEPVARIANT($vepfile, $dataid); printerr " Done\n";
              }
              if ($annovar) {
                printerr "TASK:\t Importing Variant annotation from ANNOVAR => $file2consider\n"; #status
                printerr "NOTICE:\t Importing $dataid - Variant Annotation to VarAnno table ...";
                ANNOVARIANT($annofile, $dataid); printerr " Done\n";
              }
            } else { #end unless annversion is previously specified
              $verbose and printerr "NOTICE:\t $dataid already in VarResult table... Moving on ...\n";
              $verbose and printerr "NOTICE:\t $dataid already in VarAnno table... Moving on ...\n";
            }
          } else {
            $verbose and printerr "NOTICE:\t $dataid already in VarResult table... Moving on ...\n";
          }
        } # end else already in VarSummary table;
      } #end if "variant" option
    } #unless & else exists in Mapstats
  } else {
      pod2usage("FAILED: \"$dataid\" sample information is not in the database. Make sure the metadata has be previously imported using '-metadata'");
  } #end if data in sample table
}
#output: the end
printerr "-----------------------------------------------------------------\n";
  if ($metadata){
  printerr ("SUCCESS: Import of Sample Information in \"$file2consider\"\n");
  print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n";
} #end if complete RNASeq metadata
if ($datadb){
  printerr ("SUCCESS: Import of RNA Seq analysis information in \"$file2consider\"\n");
  print LOG "TransAtlasDB Completed:\t", scalar(localtime),"\n";
} #end if completed RNASeq data2db
printerr ("NOTICE:\t Summary in log file $efile\n");
printerr "-----------------------------------------------------------------\n";
close (LOG);
#--------------------------------------------------------------------------------

sub processArguments {
  GetOptions('verbose|v'=>\$verbose, 'help|h'=>\$help, 'man|m'=>\$man, 'metadata'=>\$metadata,
	'data2db'=>\$datadb, 'gene'=>\$gene, 'variant'=>\$variant, 'all'=>\$all, 'vep'=>\$vep,
	'annovar'=>\$annovar, 't|tab'=>\$tab, 'x|excel'=>\$excel ) or pod2usage ();

  $help and pod2usage (-verbose=>1, -exitval=>1, -output=>\*STDOUT);
  $man and pod2usage (-verbose=>2, -exitval=>1, -output=>\*STDOUT);  
  
  pod2usage(-msg=>"ERROR:\t Invalid syntax specified, choose -metadata or -data2db.") unless ( $metadata || $datadb);
  pod2usage(-msg=>"ERROR:\t Invalid syntax specified for @ARGV.") if (($metadata && $datadb)||($vep && $annovar) || ($gene && $vep) || ($gene && $annovar) || ($gene && $variant));
   
  @ARGV==1 or pod2usage("Syntax error");
  $file2consider = $ARGV[0];

  $verbose ||=0;
  my $get = dirname(abs_path $0); #get source path
  $connect = $get.'/.connect.txt';
  #setup log file
  my $errfile = open_unique("db.tad_status.log"); 
  open(LOG, ">>", @$errfile[1]) or die "\nERROR:\t cannot write LOG information to log file @$errfile[1] $!\n";
  print LOG "TransAtlasDB Version:\t",$VERSION,"\n";
  print LOG "TransAtlasDB Information:\tFor questions, comments, documentation, bug reports and program update, please visit $default \n";
  print LOG "TransAtlasDB Command:\t $0 @ARGV\n";
  print LOG "TransAtlasDB Started:\t", scalar(localtime),"\n";
  $efile = @$errfile[1];
}


sub printerr {
  print STDERR @_;
  print LOG @_;
}

sub LOGFILE {
  if ($logfile){
    @allgeninfo = split('\s',`head -n 1 $logfile`);
    #also getting metadata info
    if ($allgeninfo[1] =~ /.*library-type$/ && $allgeninfo[3] =~ /.*no-coverage-search$/){$str = 2; $ann = 5; $ref = 10; $seq = 11; $allstart = 4; $allend = 7;}
    elsif ($allgeninfo[1] =~ /.*library-type$/ && $allgeninfo[3] =~ /.*G$/ ){$str = 2; $ann = 4; $ref = 9; $seq = 10; $allstart = 3; $allend = 6;}
    elsif($allgeninfo[3] =~ /\-o$/){$str=99; $ann=99; $ref = 5; $seq = 6; $allstart = 3; $allend = 6;}
    $refgenome = (split('\/', $allgeninfo[$ref]))[-1]; #reference genome name
  }
  else {
    ($str, $ann, $ref, $seq,$allstart, $allend) = (99,99,99,99,99,99); #defining calling variables
  }
  unless ($ann == 99){
    $annotation = $allgeninfo[$ann];
    $annotationfile = uc ( (split('\.',((split("\/", $allgeninfo[$ann]))[-1])))[-1] ); #(annotation file)
  }
  else { $annotation = undef; $annotationfile = undef; }
  if ($str == 99){ $stranded = undef; } else { $stranded = $allgeninfo[$str]; } # (stranded or not)	
  if ($seq == 99) { $sequences = undef;} else {
    my $otherseq = $seq++;
    unless(length($allgeninfo[$otherseq])<1){ #sequences 
      $sequences = ( ( split('\/', $allgeninfo[$seq]) ) [-1]).",". ( ( split('\/', $allgeninfo[$otherseq]) ) [-1]);
    } else {
      $sequences = ( ( split('\/', $allgeninfo[$seq]) ) [-1]);
   }
 } #end if seq
}
sub GENE_INFO {
  $deletions = `cat $deletionsfile | wc -l`; $deletions--;
  $insertions = `cat $insertionsfile | wc -l`; $insertions--;
  $junctions = `cat $junctionsfile | wc -l`; $junctions--;
  $genes = `cat $genesfile | wc -l`; $genes--;
  $isoforms = `cat $isoformsfile | wc -l`; $isoforms--;
  
  #INSERT INTO DATABASE: #GeneStats table
  $sth = $dbh->prepare("select sampleid from GeneStats where sampleid = '$_[0]'"); $sth->execute(); $found = $sth->fetch();
  unless ($found) { 
    printerr "NOTICE:\t Importing $_[0] to GeneStats table\n";
    $sth = $dbh->prepare("insert into GeneStats (sampleid,deletions, insertions, junctions, isoforms, genes,date) values (?,?,?,?,?,?,?)");
    $sth ->execute($_[0], $deletions, $insertions, $junctions, $isoforms, $genes, $date) or die "\nERROR:\t Complication in GeneStats table, contact $AUTHOR\n";; 
  } else {
    $verbose and printerr "NOTICE:\t $_[0] already in GeneStats table... Moving on ...\n";
  }
}
sub FPKM { #subroutine for  importing the FPKM values
  open(FPKM, "<", $_[1]) or die "\nERROR:\t Can not open file $_[1]\n";
  my $syntax = "insert into $_[0] (sampleid, trackingid, classcode, nearestrefid, geneid, geneshortname, tssid, chromnumber, chromstart, chromstop, length, coverage, fpkm, fpkmconflow, fpkmconfhigh, fpkmstatus ) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
  my $sth = $dbh->prepare($syntax);
  while (<FPKM>){
    chomp;
    my ($track, $class, $ref_id, $gene, $gene_name, $tss, $locus, $length, $coverage, $fpkm, $fpkm_low, $fpkm_high, $fpkm_stat ) = split /\t/;
    unless ($track eq "tracking_id"){ #check & specifying undefined variables to null
      if($class =~ /-/){$class = undef;} if ($ref_id =~ /-/){$ref_id = undef;}
      if ($length =~ /-/){$length = undef;} if($coverage =~ /-/){$coverage = undef;}
      my ($chrom_no, $chrom_start, $chrom_stop) = $locus =~ /^(.+)\:(.+)\-(.+)$/;
      $sth ->execute($_[2], $track, $class, $ref_id, $gene, $gene_name, $tss, $chrom_no, $chrom_start, $chrom_stop, $length, $coverage, $fpkm, $fpkm_low, $fpkm_high, $fpkm_stat ) or die "\nERROR:\t Complication in $_[0] table, contact $AUTHOR\n";
    }
  } close FPKM;
  $sth->finish();
}

sub DBVARIANT {
  open(VARVCF,$_[0]) or die ("\nERROR:\t Can not open variant file $_[0]\n");
  $varianttool = "samtools";
  while (<VARVCF>) {
    chomp;
    if (/^\#/) { if (/^\#\#GATK/) { $varianttool = "GATK"; } }
    else {
      my @chrdetails = split "\t";
      my @morechrsplit = split(';', $chrdetails[7]);
      if (((split(':', $chrdetails[9]))[0]) eq '0/1'){$verd = "heterozygous";}
      elsif (((split(':', $chrdetails[9]))[0]) eq '1/1'){$verd = "homozygous";}
      elsif (((split(':', $chrdetails[9]))[0]) eq '1/2'){$verd = "heterozygous alternate";}
      $VCFhash{$chrdetails[0]}{$chrdetails[1]} = "$chrdetails[3]|$chrdetails[4]|$chrdetails[5]|$verd";
    }
  } close VARVCF;
  $sth = $dbh->prepare("insert into VarSummary ( sampleid, varianttool, date) values (?,?,?)");
  $sth ->execute($_[1], $varianttool, $date) or die "\nERROR:\t Complication in VarSummary table, contact $AUTHOR\n";;

  #VARIANT_RESULTS
  foreach my $abc (sort keys %VCFhash) {
    foreach my $def (sort {$a <=> $b} keys %{ $VCFhash{$abc} }) {
      my @vcf = split('\|', $VCFhash{$abc}{$def});
      if ($vcf[3] =~ /,/){
        my $first = split(",",$vcf[1]);
        if (length $vcf[0] == length $first){ $itvariants++; $itsnp++; $variantclass = "SNV"; }
        elsif (length $vcf[0] < length $first) { $itvariants++; $itindel++; $variantclass = "insertion"; }
        else { $itvariants++; $itindel++; $variantclass = "deletion"; }
      }
      elsif (length $vcf[0] == length $vcf[1]){ $itvariants++; $itsnp++; $variantclass = "SNV"; }
      elsif (length $vcf[0] < length $vcf[1]) { $itvariants++; $itindel++; $variantclass = "insertion"; }
      else { $itvariants++; $itindel++; $variantclass = "deletion"; }
    
      #to variant_result
      $sth = $dbh->prepare("insert into VarResult ( sampleid, chrom, position, refallele, altallele, quality, variantclass, zygosity ) values (?,?,?,?,?,?,?,?)");
      $sth ->execute($_[1], $abc, $def, $vcf[0], $vcf[1], $vcf[2], $variantclass, $vcf[3]) or die "\nERROR:\t Complication in VarResult table, contact $AUTHOR\n";
    }
  }
  #update variantsummary with counts
  $sth = $dbh->prepare("update VarSummary set totalvariants = $itvariants, totalsnps = $itsnp, totalindels = $itindel where sampleid= '$_[1]'");
  $sth ->execute();
  $sth = $dbh->prepare("update VarSummary set status = 'done' where sampleid= '$_[1]'");
  $sth ->execute();
  $sth->finish();
}
sub VEPVARIANT {
  my ($chrom, $position);
  open(VEP,$_[0]) or die ("\nERROR:\t Can not open vep file $_[0]\n");
  while (<VEP>) {
    chomp;
    unless (/^\#/) {
      unless (/within_non_coding_gene/i) {
        my @veparray = split "\t"; #14 columns
        my @extraarray = split(";", $veparray[13]);
        foreach (@extraarray) { my @earray = split "\="; $extra{$earray[0]}=$earray[1]; }
        my @indentation = split("_", $veparray[0]);
        if ($#indentation > 2) { $chrom = $indentation[0]."_".$indentation[1]; $position = $indentation[2]; }
        else { $chrom = $indentation[0]; $position = $indentation[1]; }
        $chrom = "chr".$chrom;
        unless ($extra{'VARIANT_CLASS'} =~ "SNV" or $extra{'VARIANT_CLASS'} =~ "substitution"){ $position--; }
        my $geneid = $veparray[3];
        my $transcriptid = $veparray[4];
        my $featuretype = $veparray[5];
        my $consequence = $veparray[6]; if ($consequence =~ /NON_(.*)$/){ $consequence = "NON".$1; } elsif ($consequence =~ /STOP_(.*)$/) {$consequence = "STOP".$1; }
        my $pposition = $veparray[9];
        my $aminoacid = $veparray[10];
        my $codons = $veparray[11];
        my $dbsnp = $veparray[12];
        my $locate = "$_[1],$chrom,$position,$consequence,$geneid,$pposition";
        if ( exists $VEPhash{$locate} ) {
          unless ( $VEPhash{$locate} eq $locate ){ die "\nERROR:\t Duplicate annotation in VEP file, contact $AUTHOR\n"; }
        } else {
          $VEPhash{$locate} = $locate;
          $sth = $dbh->prepare("insert into VarAnno ( sampleid, chrom, position, consequence, source, geneid, genename, transcript, feature, genetype,proteinposition, aachange, codonchange ) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");
          $sth ->execute($_[1], $chrom, $position, $consequence, $extra{'SOURCE'}, $geneid, $extra{'SYMBOL'}, $transcriptid, $featuretype, $extra{'BIOTYPE'} , $pposition, $aminoacid, $codons) or die "\nERROR:\t Complication in VarAnno table, contact $AUTHOR\n";
          undef %extra;
          $DBSNP{$chrom}{$position} = $dbsnp;
        }
      }
    }
  }
  close VEP;
  foreach my $chrom (sort keys %DBSNP) {
    foreach my $position (sort keys %{ $DBSNP{$chrom} }) {
      $sth = $dbh->prepare("update VarResult set dbsnpvariant = '$DBSNP{$chrom}{$position}' where sampleid = '$_[1]' and chrom = '$chrom' and position = $position"); $sth ->execute();
    }
  }
  $sth = $dbh->prepare("update VarSummary set annversion = 'VEP' where sampleid = '$_[1]'"); $sth ->execute();
}

sub ANNOVARIANT {
  my (%REFGENE, %ENSGENE, %CONTENT);
  open(ANNOVAR,$_[0]) or die ("\nERROR:\t Can not open annovar file $_[0]\n");
  my @annocontent = <ANNOVAR>; close ANNOVAR; 
  my @header = split("\t", lc($annocontent[0]));
  
  #getting headers
  foreach my $no (5..$#header-1){ #checking if ens and ref is specified
    my @tobeheader = split('\.', $header[$no]);
    if ($tobeheader[1] =~ /refgene/i){
      $REFGENE{$tobeheader[0]} = $header[$no];
    } elsif ($tobeheader[1] =~ /ensgene/i){ 
      $ENSGENE{$tobeheader[0]} = $header[$no];
    } else {
      die "ERROR:\t Do not understand notation '$tobeheader[1]' provided. Contact $AUTHOR \n";
    }
  }
  #convert content to a hash array.
  my $counter = $#header+1;
  @annocontent = @annocontent[1..$#annocontent];
  foreach my $rowno (0..$#annocontent) {
    my @arrayrow = split("\t", $annocontent[$rowno], $counter);
    foreach my $colno (0..$#header) {
      $CONTENT{$rowno}{$header[$colno]} = $arrayrow[$colno];
    }
    $CONTENT{$rowno}{'position'} = (split("\t",$arrayrow[$#arrayrow]))[4];
  }
  #working with ENS
  if (exists $ENSGENE{'func'}) {
    foreach my $newno (sort {$a<=>$b} keys %CONTENT){
      my $pposition = "-"; my $consequence = ""; my $transcript = ""; my $aminoacid = "-"; my $codons = "-";
      if ($CONTENT{$newno}{$ENSGENE{'func'}} =~ /^exonic/i) {
        $consequence = $CONTENT{$newno}{$ENSGENE{'exonicfunc'}};
        unless ($consequence =~ /unknown/i){         
          my @acontent = split(",", $CONTENT{$newno}{$ENSGENE{'aachange'}});
          my @ocontent = split (":", $acontent[$#acontent]);
          $transcript = $ocontent[1] =~ s/\.\d//g;
          foreach (@ocontent){
            if (/^c\.[a-zA-Z]/) {
              my ($a, $b, $c) = $_ =~ /^c\.(\S)(\d+)(\S)$/; 
              $codons = $a."/".$c;
            } elsif (/^c\.[0-9]/) {
              $codons = $_;
            }
            elsif (/^p\.\S\d+\S$/){ 
              my ($a, $b, $c) = $_ =~ /^p\.(\S)(\d+)(\S)$/;
              $pposition = $b;
              if ($a eq $c) {$aminoacid = $a;} else {$aminoacid = $a."/".$b;}
            } elsif (/^p\.\S\d+\S+$/) {
              my $a = $_ =~ /^p\.\S(\d+)\S+$/;
              $pposition = $a;
              $aminoacid = $_;
            }
          }
        } 
      } else {
        $consequence = $CONTENT{$newno}{$ENSGENE{'func'}};
      }
      unless ($consequence =~ /ncRNA/i) {
        $consequence = uc($consequence);
        if ($consequence eq "UTR5"){ $consequence = "5PRIME_UTR";}
        if ($consequence eq "UTR3"){ $consequence = "3PRIME_UTR";} 
      }
      $CONTENT{$newno}{$ENSGENE{'gene'}} =~ s/\.\d//g; 
      my $locate = "$_[1],$CONTENT{$newno}{'chr'}, $CONTENT{$newno}{'position'},$consequence,$CONTENT{$newno}{$ENSGENE{'gene'}},$pposition";
      if ( exists $ANNOhash{$locate} ) {
        unless ( $ANNOhash{$locate} eq $locate ){ die "\nERROR:\t Duplicate annotation in ANNOVAR file, contact $AUTHOR\n"; }
      } else {
        $ANNOhash{$locate} = $locate;
        $sth = $dbh->prepare("insert into VarAnno ( sampleid, chrom, position, consequence, source, geneid, transcript,proteinposition, aachange, codonchange ) values (?,?,?,?,?,?,?,?,?,?)");
        $sth ->execute($_[1], $CONTENT{$newno}{'chr'}, $CONTENT{$newno}{'position'}, $consequence, 'Ensembl', $CONTENT{$newno}{$ENSGENE{'gene'}}, $transcript, $pposition, $aminoacid, $codons) or die "\nERROR:\t Complication in VarAnno table, contact $AUTHOR\n";
      }
    }
  }
  
  #working with REF
  if (exists $REFGENE{'func'}) {
    foreach my $newno (sort {$a<=>$b} keys %CONTENT){
      my $pposition = "-"; my $consequence = ""; my $transcript = ""; my $aminoacid = ""; my $codons = "";
      if ($CONTENT{$newno}{$REFGENE{'func'}} =~ /^exonic/i) {
        $consequence = $CONTENT{$newno}{$REFGENE{'exonicfunc'}};
        unless ($consequence =~ /unknown/i){         
          my @acontent = split(",", $CONTENT{$newno}{$REFGENE{'aachange'}});
          my @ocontent = split (":", $acontent[$#acontent]);
          $transcript = $ocontent[1] =~ s/\.\d//g;
          foreach (@ocontent){
            if (/^c\.[a-zA-Z]/) {
              my ($a, $b, $c) = $_ =~ /^c\.(\S)(\d+)(\S)$/; 
              $codons = $a."/".$c;
            } elsif (/^c\.[0-9]/) {
              $codons = $_;
            }
            elsif (/^p\.\S\d+\S$/){ 
              my ($a, $b, $c) = $_ =~ /^p\.(\S)(\d+)(\S)$/;
              $pposition = $b;
              if ($a eq $c) {$aminoacid = $a;} else {$aminoacid = $a."/".$b;}
            } elsif (/^p\.\S\d+\S+$/) {
              my $a = $_ =~ /^p\.\S(\d+)\S+$/;
              $pposition = $a;
              $aminoacid = $_;
            }
          }
        } 
      } else {
        $consequence = $CONTENT{$newno}{$ENSGENE{'func'}};
      }
      unless ($consequence =~ /ncRNA/i) {
        $consequence = uc($consequence);
        if ($consequence eq "UTR5"){ $consequence = "5PRIME_UTR";}
        if ($consequence eq "UTR3"){ $consequence = "3PRIME_UTR";} 
      }
      $CONTENT{$newno}{$ENSGENE{'gene'}} =~ s/\.\d//g;
      my $locate = "$_[1],$CONTENT{$newno}{'chr'}, $CONTENT{$newno}{'position'},$consequence,$CONTENT{$newno}{$REFGENE{'gene'}},$pposition";
      if ( exists $ANNOhash{$locate} ) {
        unless ( $ANNOhash{$locate} eq $locate ){ die "\nERROR:\t Duplicate annotation in ANNOVAR file, contact $AUTHOR\n"; }
      } else {
        $ANNOhash{$locate} = $locate;
        $sth = $dbh->prepare("insert into VarAnno ( sampleid, chrom, position, consequence, source, genename, geneid, transcript,proteinposition, aachange, codonchange ) values (?,?,?,?,?,?,?,?,?,?,?)");
        $sth ->execute($_[1], $CONTENT{$newno}{'chr'}, $CONTENT{$newno}{'position'}, $consequence, 'RefSeq', $CONTENT{$newno}{$REFGENE{'gene'}},$CONTENT{$newno}{$REFGENE{'gene'}},$transcript, $pposition, $aminoacid, $codons) or die "\nERROR:\t Complication in VarAnno table, contact $AUTHOR\n";
      }
    }
  }
  $sth = $dbh->prepare("update VarSummary set annversion = 'ANNOVAR' where sampleid = '$_[1]'"); $sth ->execute();

}
#--------------------------------------------------------------------------------

=head1 SYNOPSIS

  tad-import.pl [arguments] <metadata-file|sample-location>

  Optional arguments:
	-h, --help		print help message
  	-m, --man		print complete documentation
  	-v, --verbose		use verbose output


        Arguments to import metadata or sample analysis
            --metadata          import metadata file provided
            --data2db		import data files from gene expression profiling and/or variant analysis (default: --gene)


        Arguments to control metadata import
	    -x, --excel         metadata will import the faang excel file provided (default)
      -t, --tab         	metadata will import the tab-delimited file provided
	     


	Arguments to control data2db import
            --gene     		data2db will import only the alignment file [TopHat2] and expression profiling files [Cufflinks] (default)
            --variant           data2db will import only the alignment file [TopHat2] and variant analysis files [.vcf]
            --all          	data2db will import all data files specified


        Arguments to fine-tune variant import procedure
            --vep		import ensembl vep variant annotation file [tab-delimited format] [suffix: .vep.txt] (in variant operation)
	    --annovar		import annovar variant annotation file [suffix: .multianno.txt] (in variant operation)


  Function: import data files into the database
 
  Example: #import metadata files
 	   tad-import.pl -metadata -v -t example/metadata/TEMPLATE/metadata_GGA_UD.txt
	   tad-import.pl -metadata -x -v example/metadata/FAANG/FAANG_GGA_UD.xlsx
 	   
  	   #import transcriptome analysis data files
 	   tad-import.pl -data2db example/sample_sxt/GGA_UD_1004/
	   tad-import.pl -data2db -all -v example/sample_sxt/GGA_UD_1014/
	   tad-import.pl -data2db -variant -annovar example/sample_sxt/GGA_UD_1004/


  Version: $Date: 2016-10-28 15:50:08 (Fri, 28 Oct 2016) $

=head1 OPTIONS

=over 8

=item B<--help>

print a brief usage message and detailed explantion of options.

=item B<--man>

print the complete manual of the program.

=item B<--verbose>

use verbose output.

=item B<--metadata>

import metadata file provided.
Metadata files accepted is either a tab-delmited (suffix: '.txt') file 
or FAANG biosamples excel (suffix: '.xls') file

=item B<--tab>

specify the file provided is in tab-delimited format (suffix: '.txt'). (default)

=item B<--excel>

specify the file provided is an excel spreadsheet (suffix: '.xls'/'.xlsx')

=item B<--data2db>

import data files from gene expression profiling analysis 
derived from using TopHat2 and Cufflinks. Optionally 
import variant file (see: variant file format) and 
variant annotation file from annovar or vep.

=item B<--gene>

specify only expression files will be imported. (default)

=item B<--variant>

specify only variant files will be imported.

=item B<--all>

specify both expression and variant files will be imported.

=item B<--vep>

specify annotation file provided was generated using Ensembl Variant Effect Predictor (VEP).

=item B<--annovar>

specify annotation file provided was predicted using ANNOVAR.

=back

=head1 DESCRIPTION

TransAtlasDB is a database management system for organization of gene expression
profiling from numerous amounts of RNAseq data.

TransAtlasDB toolkit comprises of a suite of Perl script for easy archival and 
retrival of transcriptome profiling and genetic variants.

TransAtlasDB requires all analysis be stored in a single folder location for 
successful processing.

Detailed documentation for TransAtlasDB should be viewed on github.

=over 8 

=item * B<directory/folder structure>
A sample directory structure contains file output from TopHat2 software, 
Cufflinks software, variant file from any bioinformatics variant analysis package
such as GATK, SAMtools, and (optional) variant annotation results from ANNOVAR 
or Ensembl VEP in tab-delimited format having suffix '.multianno.txt' and '.vep.txt' 
respectively. An example is shown below:

	/sample_name/
	/sample_name/tophat_folder/
	/sample_name/tophat_folder/accepted_hits.bam
	/sample_name/tophat_folder/align_summary.txt
	/sample_name/tophat_folder/deletions.bed
	/sample_name/tophat_folder/insertions.bed
	/sample_name/tophat_folder/junctions.bed
	/sample_name/tophat_folder/prep_reads.info
	/sample_name/tophat_folder/unmapped.bam
	/sample_name/cufflinks_folder/
        /sample_name/cufflinks_folder/genes.fpkm_tracking
        /sample_name/cufflinks_folder/isoforms.fpkm_tracking
        /sample_name/cufflinks_folder/skipped.gtf
        /sample_name/cufflinks_folder/transcripts.gtf
        /sample_name/variant_folder/
        /sample_name/variant_folder/<filename>.vcf
        /sample_name/variant_folder/<filename>.multianno.txt
        /sample_name/variant_folder/<filename>.vep.txt

=item * B<variant file format>

A sample variant file contains one variant per line, with the fields being chr,
start, end, reference allele, observed allele, other information. The other
information can be anything (for example, it may contain sample identifiers for
the corresponding variant.) An example is shown below:

        16      49303427        49303427        C       T       rs2066844       R702W (NOD2)
        16      49314041        49314041        G       C       rs2066845       G908R (NOD2)
        16      49321279        49321279        -       C       rs2066847       c.3016_3017insC (NOD2)
        16      49290897        49290897        C       T       rs9999999       intronic (NOD2)
        16      49288500        49288500        A       T       rs8888888       intergenic (NOD2)
        16      49288552        49288552        T       -       rs7777777       UTR5 (NOD2)
        18      56190256        56190256        C       T       rs2229616       V103I (MC4R)

=item * B<invalid input>

If any of the files input contain invalid arguments or format, TransAtlas 
will terminate the program and the invalid input with the outputted. 
Users should manually examine this file and identify sources of error.

=back


--------------------------------------------------------------------------------

TransAtlasDB is free for academic, personal and non-profit use.

For questions or comments, please contact $ Author: Modupe Adetunji <amodupe@udel.edu> $.

=cut


