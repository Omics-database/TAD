-- MySQL Script
-- 
-- Host: localhost    Database: transatlasdb
-- Model: TransAtlasDB		Version: 1.0
-- Function: TransAtlasDB Schema Script
-- 
-- ---------------------------------------------------
-- Server version	5.5.52
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
-- -----------------------------------------------------
-- Table structure for table `Sample`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Sample` ;
CREATE TABLE IF NOT EXISTS `Sample` (`sampleid` INT(11) NOT NULL,`samplename` VARCHAR(50) NOT NULL,`sampleinfo` VARCHAR(100) NULL DEFAULT NULL,`species` VARCHAR(100) NOT NULL,`line` VARCHAR(100) NULL DEFAULT NULL,`tissue` VARCHAR(100) NULL DEFAULT NULL,`method` VARCHAR(100) NULL DEFAULT NULL,`scientist` VARCHAR(100) NULL DEFAULT NULL,`date` DATETIME NOT NULL,`notes` TEXT NULL DEFAULT NULL,PRIMARY KEY (`sampleid`, `samplename`),INDEX `sample_indx_species` (`species` ASC)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `MapStats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `MapStats` ;
CREATE TABLE IF NOT EXISTS `MapStats` (`sampleid` INT(11) NOT NULL DEFAULT '0', `totalreads` INT(11) NULL DEFAULT NULL, `mappedreads` INT(11) NULL DEFAULT NULL, `unmappedreads` INT(11) NULL DEFAULT NULL, `deletions` INT(11) NULL DEFAULT NULL, `insertions` INT(11) NULL DEFAULT NULL, `junctions` INT(11) NULL DEFAULT NULL, `isoforms` INT(11) NULL DEFAULT NULL, `genes` INT(11) NULL DEFAULT NULL, `infoprepreads` TEXT NULL DEFAULT NULL, `date` DATE NULL DEFAULT NULL, `status` CHAR(10) NULL, PRIMARY KEY (`sampleid`), CONSTRAINT `MapStats_ibfk_1` FOREIGN KEY (`sampleid`) REFERENCES `Sample` (`sampleid`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `Metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Metadata` ;
CREATE TABLE IF NOT EXISTS `Metadata` ( `sampleid` INT(11) NOT NULL DEFAULT '0', `refgenome` VARCHAR(50) NULL DEFAULT NULL, `annfile` VARCHAR(20) NULL DEFAULT NULL, `annfilever` VARCHAR(50) NULL DEFAULT NULL, `stranded` VARCHAR(50) NULL DEFAULT NULL, `sequencename` TEXT NULL DEFAULT NULL, CONSTRAINT `metadata_ibfk_1` FOREIGN KEY (`sampleid`) REFERENCES `MapStats` (`sampleid`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `GenesFpkm`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `GenesFpkm` ;
CREATE TABLE IF NOT EXISTS `GenesFpkm` (`sampleid` INT(11) NOT NULL DEFAULT '0', `trackingid` VARCHAR(50) NOT NULL DEFAULT '', `classcode` VARCHAR(20) NULL DEFAULT NULL, `nearestrefid` VARCHAR(20) NULL DEFAULT NULL, `geneid` VARCHAR(50) NOT NULL DEFAULT '', `geneshortname` VARCHAR(200) NOT NULL DEFAULT '', `tssid` VARCHAR(50) NOT NULL DEFAULT '', `chromnumber` VARCHAR(50) NOT NULL DEFAULT '', `chromstart` INT(11) NOT NULL DEFAULT '0', `chromstop` INT(11) NOT NULL DEFAULT '0', `length` INT(11) NULL DEFAULT NULL, `coverage` DOUBLE(20,10) NULL DEFAULT NULL, `fpkm` DOUBLE(20,5) NOT NULL DEFAULT '0.00000', `fpkmconflow` DOUBLE(20,5) NOT NULL DEFAULT '0.00000', `fpkmconfhigh` DOUBLE(20,5) NOT NULL DEFAULT '0.00000', `fpkmstatus` VARCHAR(10) NULL DEFAULT NULL, INDEX `genesfpkm_indx_geneshortname` (`geneshortname` ASC), INDEX `genesfpkm_ibfk_1_idx` (`sampleid` ASC), PRIMARY KEY (`sampleid`), CONSTRAINT `genesfpkm_ibfk_1` FOREIGN KEY (`sampleid`) REFERENCES `Sample` (`sampleid`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `IsoformsFpkm`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IsoformsFpkm` ;
CREATE TABLE IF NOT EXISTS `IsoformsFpkm` ( `sampleid` INT(11) NOT NULL DEFAULT '0', `trackingid` VARCHAR(50) NOT NULL DEFAULT '', `classcode` VARCHAR(20) NULL DEFAULT NULL, `nearestrefid` VARCHAR(20) NULL DEFAULT NULL, `geneid` VARCHAR(50) NOT NULL DEFAULT '', `geneshortname` VARCHAR(20) NOT NULL DEFAULT '', `tssid` VARCHAR(50) NOT NULL DEFAULT '', `chromnumber` VARCHAR(50) NOT NULL DEFAULT '', `chromstart` INT(11) NOT NULL DEFAULT '0', `chromstop` INT(11) NOT NULL DEFAULT '0', `length` INT(11) NULL DEFAULT NULL, `coverage` DOUBLE(20,10) NULL DEFAULT NULL, `fpkm` DOUBLE(20,5) NOT NULL DEFAULT '0.00000', `fpkmconflow` DOUBLE(20,5) NOT NULL DEFAULT '0.00000', `fpkmconfhigh` DOUBLE(20,5) NOT NULL DEFAULT '0.00000', `fpkmstatus` VARCHAR(10) NULL DEFAULT NULL, INDEX `isoformsfpkm_indx_geneshortname` (`geneshortname` ASC), INDEX `isoformsfpkm_ibfk_1_idx` (`sampleid` ASC), PRIMARY KEY (`sampleid`), CONSTRAINT `isoformsfpkm_ibfk_1` FOREIGN KEY (`sampleid`) REFERENCES `Sample` (`sampleid`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `VarSummary`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `VarSummary` ;
CREATE TABLE IF NOT EXISTS `VarSummary` (`sampleid` INT(11) NOT NULL DEFAULT '0', `totalvariants` INT(11) NULL DEFAULT NULL, `totalsnps` INT(11) NULL DEFAULT NULL, `totalindels` INT(11) NULL DEFAULT NULL, `annversion` VARCHAR(50) NULL DEFAULT NULL, `varianttool` VARCHAR(50) NULL DEFAULT NULL, `toolversion` VARCHAR(50) NULL DEFAULT NULL, `date` DATE NOT NULL, `status` CHAR(10) NULL DEFAULT NULL, `nosql` CHAR(10) NULL DEFAULT NULL, PRIMARY KEY (`sampleid`), CONSTRAINT `varsummary_ibfk_1` FOREIGN KEY (`sampleid`) REFERENCES `MapStats` (`sampleid`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `VarResult`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `VarResult` ;
CREATE TABLE IF NOT EXISTS `VarResult` ( `sampleid` INT(11) NOT NULL DEFAULT '0', `chrom` VARCHAR(50) NOT NULL DEFAULT '', `position` INT(11) NOT NULL DEFAULT '0', `refallele` VARCHAR(50) NULL DEFAULT NULL, `altallele` VARCHAR(50) NULL DEFAULT NULL, `quality` DOUBLE(20,5) NULL DEFAULT NULL, `variantclass` VARCHAR(50) NULL DEFAULT NULL, `zygosity` VARCHAR(50) NULL DEFAULT NULL, `dbsnpvariant` VARCHAR(50) NULL DEFAULT NULL, PRIMARY KEY (`sampleid`, `chrom`, `position`), CONSTRAINT `varresult_ibfk_1` FOREIGN KEY (`sampleid`) REFERENCES `VarSummary` (`sampleid`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- Table structure for table `VarAnno`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `VarAnno` ;
CREATE TABLE IF NOT EXISTS `VarAnno` (`sampleid` INT(11) NOT NULL DEFAULT '0', `chrom` VARCHAR(50) NOT NULL DEFAULT '', `position` INT(11) NOT NULL DEFAULT '0', `consequence` VARCHAR(50) NOT NULL DEFAULT '', `geneid` VARCHAR(50) NOT NULL DEFAULT '', `genename` VARCHAR(50) NULL DEFAULT NULL, `transcript` VARCHAR(200) NULL DEFAULT NULL, `feature` VARCHAR(50) NULL DEFAULT NULL, `genetype` VARCHAR(200) NULL DEFAULT NULL, `proteinposition` VARCHAR(50) NOT NULL DEFAULT '', `aachange` VARCHAR(50) NULL DEFAULT NULL, `codonchange` VARCHAR(50) NULL DEFAULT NULL, PRIMARY KEY (`consequence`, `geneid`, `proteinposition`, `sampleid`, `chrom`, `position`), INDEX `varanno_indx_genename` (`genename` ASC), CONSTRAINT `varanno_ibfk_1` FOREIGN KEY (`sampleid` , `chrom` , `position`) REFERENCES `VarResult` (`sampleid` , `chrom` , `position`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1;
-- -----------------------------------------------------
-- procedure usp_genedgenedtissue
-- -----------------------------------------------------
-- DROP procedure IF EXISTS `usp_genedgenedtissue`;
-- CREATE PROCEDURE `usp_genedgenedtissue`(in gname varchar(45), in tissue varchar(45), in specie varchar(45)) select a.geneshortname `Gene Name`, b.line `Line`, max(a.fpkm) `Maximum Fpkm`, CAST(avg(a.fpkm) AS DECIMAL(20,5)) `Average Fpkm`, min(a.fpkm) `Minimum Fpkm` from GenesFpkm a join Sample b on a.sampleid = b.sampleid where a.geneshortname like CONCAT('%', TRIM(IFNULL(gname, '')), '%') and b.tissue = tissue and b.line is not null and b.tissue is not null and b.species = specie group by a.geneshortname, b.line order by a.geneshortname;
/* Create a stored procedure to get fpkm details of a gene based on tissue and species */
/* call usp_genedgenedtissue("ASB6", "liver", "gallus"); */
-- -----------------------------------------------------
-- procedure usp_genedgenedtissueless
-- -----------------------------------------------------
-- DROP procedure IF EXISTS `usp_genedgenedtissueless`;
-- CREATE PROCEDURE `usp_genedgenedtissueless`(in gname varchar(45), in tissue varchar(45), in specie varchar(45)) select a.geneshortname `Gene Name`, b.line `Line`, max(a.fpkm) `Maximum Fpkm`, CAST(avg(a.fpkm) AS DECIMAL(20,5)) `Average Fpkm`, min(a.fpkm) `Minimum Fpkm`  from GenesFpkm a join Sample b on a.sampleid = b.sampleid where a.geneshortname like CONCAT('%', TRIM(IFNULL(gname, '')), '%') and  b.tissue = tissue and b.species = specie group by a.geneshortname, b.line order by a.geneshortname;
/* Create a stored procedure to get fpkm details of a gene based on tissue and species */
/* call usp_genedgenedtissueless("usp", "lung", "mus_musculus"); */ 
-- -----------------------------------------------------
-- procedure usp_varchrom
-- -----------------------------------------------------
-- DROP procedure IF EXISTS `usp_varchrom`;
-- CREATE PROCEDURE `usp_varchrom`(in specie varchar(45), in chrom varchar(45), in vstart int(20), in vend int(20)) select c.line `Line`, a.chrom `Chrom`, a.position `Position`, a.refallele `Ref`, a.altallele `Alt`, group_concat(distinct a.variantclass) `Class`, group_concat(distinct b.consequence) `Annotation`, group_concat(distinct b.genename) `Gene Name`, group_concat(distinct a.dbsnpvariant) `dbSNP` from VarResult a join VarAnno b on a.sampleid = b.sampleid and a.chrom = b.chrom and a.position = b.position join Sample c on a.sampleid = c.sampleid where c.species = specie  and a.chrom = chrom  and c.line is not null and a.position between vstart and vend group by a.chrom, a.position, c.line order by c.line;
/* Create a stored procedure to get variant info after specifying chromosomal location */
/* call usp_varchrom("gallus", "chr1", "57800", "60000"); */
-- -----------------------------------------------------
-- procedure usp_varchromless
-- -----------------------------------------------------
-- DROP procedure IF EXISTS `usp_varchromless`;
-- CREATE PROCEDURE `usp_varchromless`(in specie varchar(45), in chrom varchar(45), in vstart int(20), in vend int(20)) select a.chrom `Chrom`, a.position `Position`, a.refallele `Ref`, a.altallele `Alt`, group_concat(distinct a.variantclass) `Class`, group_concat(distinct b.consequence) `Annotation`, group_concat(distinct b.genename) `Gene Name`,  group_concat(distinct a.dbsnpvariant) `dbSNP` from VarResult a join VarAnno b  on a.sampleid = b.sampleid and a.chrom = b.chrom and a.position = b.position  join Sample c on a.sampleid = c.sampleid where c.species = specie and a.chrom = chrom and a.position between vstart and vend group by a.chrom, a.position, c.line order by c.line;
/* Create a stored procedure to get variant info after specifying chromosomal location */
/* call usp_varchromless("mus_musculus", "NC_000071.6", "3200000", "3300000"); */ 
-- -----------------------------------------------------
-- procedure usp_vargene
-- -----------------------------------------------------
-- DROP procedure IF EXISTS `usp_vargene`;
-- CREATE PROCEDURE `usp_vargene`(in specie varchar(45), in gname varchar(45)) select c.line `Line`, a.chrom `Chrom`, a.position `Position`, a.refallele `Ref`, a.altallele `Alt`, group_concat(distinct a.variantclass) `Class`,group_concat(distinct b.consequence) `Annotation`, group_concat(distinct b.genename) `Gene Name`, group_concat(distinct a.dbsnpvariant) `dbSNP` from VarResult a join VarAnno b on a.sampleid = b.sampleid and a.chrom = b.chrom and a.position = b.position  join Sample c on a.sampleid = c.sampleid where c.species = specie and b.genename like CONCAT('%', TRIM(IFNULL(gname, '')), '%')  and c.line is not null group by a.chrom, a.position, c.line order by c.line;
/* Create a stored procedure to get variant info after specifying chromosomal location */
/* call usp_vargene("gallus", "golgb1"); */ 
-- -----------------------------------------------------
-- procedure usp_vargeneless
-- -----------------------------------------------------
-- DROP procedure IF EXISTS `usp_vargeneless`;
-- CREATE PROCEDURE `usp_vargeneless`(in specie varchar(45), in gname varchar(45)) select a.chrom `Chrom`, a.position `Position`, a.refallele `Ref`, a.altallele `Alt`, group_concat(distinct a.variantclass) `Class`, group_concat(distinct b.consequence) `Annotation`, group_concat(distinct b.genename) `Gene Name`, group_concat(distinct a.dbsnpvariant) `dbSNP` from VarResult a join VarAnno b on a.sampleid = b.sampleid and a.chrom = b.chrom and a.position = b.position join Sample c on a.sampleid = c.sampleid where c.species = specie and b.genename like CONCAT('%', TRIM(IFNULL(gname, '')), '%')  group by a.chrom, a.position, c.line order by c.line;
/* Create a stored procedure to get variant info after specifying chromosomal location */
/* call usp_vargeneless("mus_musculus", "Gm15772"); */ 
-- -----------------------------------------------------
-- View `vw_annotation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vw_annotation` (`sampleid` INT, `chrom` INT, `position` INT, `refallele` INT, `altallele` INT, `annotation` INT, `amount` INT);
DROP VIEW IF EXISTS `vw_annotation` ;
DROP TABLE IF EXISTS `vw_annotation`;
CREATE VIEW `vw_annotation` AS select `a`.`sampleid` AS `sampleid`,`a`.`chrom` AS `chrom`,`a`.`position` AS `position`,`a`.`refallele` AS `refallele`,`a`.`altallele` AS `altallele`,group_concat(distinct `b`.`consequence` separator '; ') AS `annotation`,count(0) AS `amount` from (`VarResult` `a` join `VarAnno` `b` on(((`a`.`sampleid` = `b`.`sampleid`) and (`a`.`chrom` = `b`.`chrom`) and (`a`.`position` = `b`.`position`)))) group by `a`.`sampleid`,`a`.`chrom`,`a`.`position`;
-- -----------------------------------------------------
-- View `vw_libraryinfo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vw_libraryinfo` (`sampleid` INT, `line` INT, `species` INT, `tissue` INT, `notes` INT, `mappedreads` INT, `genes` INT, `isoforms` INT, `totalvariants` INT, `totalsnps` INT, `totalindels` INT);
DROP VIEW IF EXISTS `vw_libraryinfo` ;
DROP TABLE IF EXISTS `vw_libraryinfo`;
CREATE VIEW `vw_libraryinfo` AS select `a`.`sampleid` AS `sampleid`,`a`.`line` AS `line`,`a`.`species` AS `species`,`a`.`tissue` AS `tissue`,`a`.`notes` AS `notes`,`b`.`mappedreads` AS `mappedreads`,`b`.`genes` AS `genes`,`b`.`isoforms` AS `isoforms`,`c`.`totalvariants` AS `totalvariants`,`c`.`totalsnps` AS `totalsnps`,`c`.`totalindels` AS `totalindels` from ((`Sample` `a` join `MapStats` `b` on((`a`.`sampleid` = `b`.`sampleid`))) join `VarSummary` `c` on((`a`.`sampleid` = `c`.`sampleid`)));
-- -----------------------------------------------------
-- View `vw_variants`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vw_variants` (`sampleid` INT, `chrom` INT, `position` INT, `refallele` INT, `altallele` INT, `variantclass` INT, `annotation` INT, `genename` INT, `dbsnpvariant` INT);
DROP VIEW IF EXISTS `vw_variants` ;
DROP TABLE IF EXISTS `vw_variants`;
CREATE VIEW `vw_variants` AS select `a`.`sampleid` AS `sampleid`,`a`.`chrom` AS `chrom`,`a`.`position` AS `position`,`a`.`refallele` AS `refallele`,`a`.`altallele` AS `altallele`,`a`.`variantclass` AS `variantclass`,group_concat(distinct ifnull(`b`.`consequence`,'none') separator '; ') AS `annotation`,ifnull(group_concat(distinct `b`.`genename` separator '; '),'none') AS `genename`,group_concat(distinct ifnull(`a`.`dbsnpvariant`,'none') separator '; ') AS `dbsnpvariant` from (`VarResult` `a` join `VarAnno` `b` on(((`a`.`sampleid` = `b`.`sampleid`) and (`a`.`chrom` = `b`.`chrom`) and (`a`.`position` = `b`.`position`)))) where (`b`.`genename` is not null) group by `a`.`sampleid`,`a`.`chrom`,`a`.`position`;
--
