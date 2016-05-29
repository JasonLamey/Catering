-- MySQL dump 10.13  Distrib 5.7.11, for Linux (x86_64)
--
-- Host: localhost    Database: catering
-- ------------------------------------------------------
-- Server version	5.7.11

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

--
-- Table structure for table `admin_logs`
--

DROP TABLE IF EXISTS `admin_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admin` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `log_level` enum('Debug','Info','Warning','Error') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Info',
  `log_message` text COLLATE utf8_unicode_ci NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `admin_id` (`admin`),
  KEY `log_level_INDEX` (`log_level`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_logs`
--

LOCK TABLES `admin_logs` WRITE;
/*!40000 ALTER TABLE `admin_logs` DISABLE KEYS */;
INSERT INTO `admin_logs` VALUES (1,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-03-25 22:33:54'),(2,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-06 01:40:37'),(3,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-06 17:41:05'),(4,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-07 02:13:09'),(5,'testadmin','10.0.2.2 - ','Info','Account Changes By Admin: Caterer &gt;Caterers R Us&lt;: street2: \'\' -> \'HASH(0x5ac15a0)-{street2}\'','2016-04-07 02:22:47'),(6,'testadmin','10.0.2.2 - ','Info','Account Changes By Admin: Caterer &gt;Caterers R Us&lt;: street2: \'Apt. B\' -> \'Apt. C\'','2016-04-07 02:26:05'),(7,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-07 18:59:11'),(8,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-07 19:10:52'),(9,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-07 19:48:22'),(10,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-07 20:15:28'),(11,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-10 03:14:10'),(12,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-04-26 01:04:40'),(13,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-05-11 17:48:23'),(14,'testadmin','10.0.2.2 - ','Info','Successful Logout','2016-05-11 17:49:02'),(15,'testadmin','10.0.2.2 - ','Info','Successful Login','2016-05-11 17:49:31');
/*!40000 ALTER TABLE `admin_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admins` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `password` char(73) COLLATE utf8_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `admin_type` enum('Admin','Op') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Op',
  `created_on` datetime NOT NULL,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'testadmin','{CRYPT}$2a$04$SLg1Ogo/Hat3ZPFUf.SN9.iQ/gOkewGyQBE5guuEK/ox4UaxuY01G','Test Admin','badkarma@side7.com',NULL,'Admin','2016-01-17 22:17:38',NULL),(2,'testop','{CRYPT}$2a$04$eOmkj6ZgJQQg0Ip4QjYbauvoBVQLv/PF.F90rkA5o32sX2iZT1okC','Test Op','testop@example.com','','Op','2016-02-19 01:24:20',NULL);
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caterer_listings`
--

DROP TABLE IF EXISTS `caterer_listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caterer_listings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) NOT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `slogan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `about` text COLLATE utf8_unicode_ci,
  `special_offer` text COLLATE utf8_unicode_ci,
  `cuisine_types` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `client_idx` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caterer_listings`
--

LOCK TABLES `caterer_listings` WRITE;
/*!40000 ALTER TABLE `caterer_listings` DISABLE KEYS */;
INSERT INTO `caterer_listings` VALUES (1,2,'Caterers R Us','We Cater So You Don\'t Have To!','<p>Cater! Cater! Cater!</p>\r\n<p>&nbsp;</p>\r\n<p><span style=\"font-family: arial black,sans-serif; font-size: 18pt;\"><strong>WE LOVE TO CATER!</strong></span></p>','',NULL,'2016-04-19 16:11:02','2016-04-19 20:11:42');
/*!40000 ALTER TABLE `caterer_listings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caterer_locations`
--

DROP TABLE IF EXISTS `caterer_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caterer_locations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `street1` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `street2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `postal` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `country` char(2) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'US',
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Caterer Locations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caterer_locations`
--

LOCK TABLES `caterer_locations` WRITE;
/*!40000 ALTER TABLE `caterer_locations` DISABLE KEYS */;
INSERT INTO `caterer_locations` VALUES (3,2,'Marshland','(555) 555-1212','543 Blah Blah Road','','Gummyville','Florida','43210','us','','http://www.company.com','2016-04-15 19:05:41',NULL),(5,2,'Mos Eisley','(555) 555-1979','999 Dark Alley','','Mos Eisley','Tennessee','54321','us','scum@galaxy.org','http://scumandvillany.com','2016-04-17 13:34:07',NULL);
/*!40000 ALTER TABLE `caterer_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clients` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `password` char(73) COLLATE utf8_unicode_ci NOT NULL,
  `poc_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` char(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed` int(1) unsigned NOT NULL DEFAULT '0',
  `created_on` datetime NOT NULL,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='utf8_unicode_ci';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (1,'newuser','{CRYPT}$2a$04$Oicr1.KOKxLJQztbSkd8T.uJM6GEGeLYzHBNWFD/nTinE6nGwBSbK','New User','Test Caterer','test@test.com','123 555-1212','423 Some Street','','Township','VA','12345','us',NULL,1,'2016-02-05 21:16:58','2016-02-17 10:50:00'),(2,'tlee','{CRYPT}$2a$04$4KRXKeIcoi70OAlMUpIrV.0dgVEhmr/KKr6LZzx1qWbB9dXjOuY36','Tommy Lee','Caterers R Us','cru@example.com','(200) 555-2121','400 Food Street','Apt. C2','Fredericksburg','VA','22401','us',NULL,1,'2016-02-18 01:37:10','2016-04-26 04:59:27');
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `confirmation_codes`
--

DROP TABLE IF EXISTS `confirmation_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `confirmation_codes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `confirmation_code` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `account_id` bigint(20) unsigned NOT NULL,
  `account_type` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `confirmed` int(1) unsigned NOT NULL DEFAULT '0',
  `created_on` datetime NOT NULL,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='utf8_unicode_ci';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `confirmation_codes`
--

LOCK TABLES `confirmation_codes` WRITE;
/*!40000 ALTER TABLE `confirmation_codes` DISABLE KEYS */;
INSERT INTO `confirmation_codes` VALUES (1,'pF27V9Jffhi4QcrUJjyU4JbMdPKYzYlL',3,'Marketer',1,'2016-01-16 22:01:07','2016-01-19 23:29:24'),(2,'cTnW9FeIdqmJSrgKYAsluHBUQBkop1ex',1,'User',1,'2016-01-17 22:17:38',NULL),(3,'whauHm8ovs2eWAfssmKmvr8edexrNu2y',4,'Marketer',0,'2016-02-05 21:17:51',NULL);
/*!40000 ALTER TABLE `confirmation_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuisine_types`
--

DROP TABLE IF EXISTS `cuisine_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cuisine_types` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `sort_by` char(3) COLLATE utf8_unicode_ci NOT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuisine_types`
--

LOCK TABLES `cuisine_types` WRITE;
/*!40000 ALTER TABLE `cuisine_types` DISABLE KEYS */;
INSERT INTO `cuisine_types` VALUES (1,'Barbecue','bar','2016-03-24 14:03:35',NULL),(2,'Chinese','chi','2016-03-24 14:03:35',NULL),(3,'Mediterranian','med','2016-03-24 14:03:35',NULL),(4,'Italian','ita','2016-03-24 14:03:35',NULL),(5,'Cajun','caj','2016-03-24 14:03:35',NULL),(6,'TexMex','tex','2016-03-24 14:03:35',NULL);
/*!40000 ALTER TABLE `cuisine_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marketer_ads`
--

DROP TABLE IF EXISTS `marketer_ads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketer_ads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `marketer_id` bigint(20) unsigned NOT NULL,
  `headline` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marketer_ads`
--

LOCK TABLES `marketer_ads` WRITE;
/*!40000 ALTER TABLE `marketer_ads` DISABLE KEYS */;
INSERT INTO `marketer_ads` VALUES (1,3,'Test Headline.','<p>This is the body of the advertisement.</p>\r\n<p>I know it is bland. <strong>BUT WHO CARES?</strong></p>','1234547890','bob@example.com','http://www.example.com','2016-04-29 19:06:21',NULL),(2,3,'This is a great advert with a very long headline. Want to see how things look when characters are cut off.','<p>We like big <span style=\"color: #993300; background-color: #000000;\"><strong><span style=\"font-size: 14pt;\">ads</span></strong></span>!&nbsp; How about you?</p>\r\n<p>We like <span style=\"font-size: 18pt; font-family: impact,sans-serif;\"><strong>big</strong></span> ads, yes we do!</p>','(123) 456-0987','bob@example.com','http://www.example.com','2016-05-03 18:58:53',NULL);
/*!40000 ALTER TABLE `marketer_ads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marketers`
--

DROP TABLE IF EXISTS `marketers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `password` char(73) COLLATE utf8_unicode_ci NOT NULL,
  `poc_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` char(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed` int(1) unsigned NOT NULL DEFAULT '0',
  `created_on` datetime NOT NULL,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='utf8_unicode_ci';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marketers`
--

LOCK TABLES `marketers` WRITE;
/*!40000 ALTER TABLE `marketers` DISABLE KEYS */;
INSERT INTO `marketers` VALUES (3,'marketertest','{CRYPT}$2a$04$EIhpFlkKS2QPvesVKr44d.clB.1F8mH7//3T9fGSHyvwPKlOXHz5G','Marketer Test, Jr.','Bob\'s Photography Palace','PhotoBob@example.com','800 555-1234','21 Jump Street','','San Francisco','CA','94101','us',NULL,1,'2016-01-16 22:01:07','2016-05-12 03:54:16'),(5,'tedwax','{CRYPT}$2a$04$aCCc7cM3ZezcInc/lzHMr.wVSVdVtthrMUkrTAIKTfBX.De22Rnqm','Ted Wax','Scented Candles 4U','sc4u@example.com','900 555-4321','79 Walnut Street','','Houston','TX','77001','us',NULL,1,'2016-02-18 04:31:04',NULL);
/*!40000 ALTER TABLE `marketers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saved_searches`
--

DROP TABLE IF EXISTS `saved_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_searches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `search_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `postal_code` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `search_radius` int(10) unsigned NOT NULL,
  `cuisine` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idsaved_searches_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saved_searches`
--

LOCK TABLES `saved_searches` WRITE;
/*!40000 ALTER TABLE `saved_searches` DISABLE KEYS */;
/*!40000 ALTER TABLE `saved_searches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_logs`
--

DROP TABLE IF EXISTS `user_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `log_level` enum('Debug','Info','Warning','Error') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Info',
  `log_message` text COLLATE utf8_unicode_ci NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `admin_id` (`user`),
  KEY `log_level_INDEX` (`log_level`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_logs`
--

LOCK TABLES `user_logs` WRITE;
/*!40000 ALTER TABLE `user_logs` DISABLE KEYS */;
INSERT INTO `user_logs` VALUES (1,'tlee (Client)','10.0.2.2 - ','Info','Added New Location: name -> \'A Location\', website -> \'\', email -> \'\', phone -> \'1234567890\', street1 -> \'123 Rar Ave.\', street2 -> \'\', city -> \'City\', state -> \'Virginia\', country -> \'us\', postal -> \'23456\'','2016-04-17 13:41:56'),(2,'tlee (Client)','10.0.2.2 - ','Info','Updated Location: name: \'A Location\' -> \'Some Location\'','2016-04-17 13:42:42'),(3,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: &gt;Some Location&lt;','2016-04-17 13:43:20'),(4,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: &gt;Some Location&lt;','2016-04-17 13:59:09'),(5,'tlee (Client)','10.0.2.2 - ','Info','Updated Listing: about: \'\' -> \'<p>We\'re a catering company.</p>\r\n<p>&nbsp;</p>\r\n<p><span style=\"font-size: 18pt; color: #e9f505;\">WE LOVE CATERING!</span></p>\', cuisine_types: \'\' -> \'TexMex\', slogan: \'\' -> \'We Cater So You Don\'t Have To!\'','2016-04-19 15:49:52'),(6,'tlee (Client)','10.0.2.2 - ','Info','Updated Listing: about: \'\' -> \'<p>Cater! Cater! Cater!</p>\r\n<p>&nbsp;</p>\r\n<p><span style=\"font-family: arial black,sans-serif; font-size: 18pt;\"><strong>WE LOVE TO CATER!</strong></span></p>\', company: \'\' -> \'Caterers R Us\', cuisine_types: \'\' -> \'TexMex\', slogan: \'\' -> \'We Cater So You Don\'t Have To!\'','2016-04-19 16:11:02'),(7,'tlee (Client)','10.0.2.2 - ','Info','Updated Listing: cuisine_types: \'TexMex\' -> undef','2016-04-19 16:11:43'),(8,'tlee (Client)','10.0.2.2 - ','Info','Account Changes: phone: \'200 555-2121\' -> \'(200) 555-2121\'','2016-04-20 17:28:58'),(9,'tlee (Client)','10.0.2.2 - ','Info','Added New Location: name -> \'La La Land\', website -> \'\', email -> \'\', phone -> \'(123) 456-0987\', street1 -> \'1 Any Street\', street2 -> \'\', city -> \'Boomtown\', state -> \'New York\', country -> \'us\', postal -> \'54637\'','2016-04-20 20:30:27'),(10,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: \'La La Land\'','2016-04-20 20:33:22'),(11,'tlee (Client)','10.0.2.2 - ','Info','Added New Location: name -> \'La La Land\', website -> \'\', email -> \'jasonlamey@gmail.com\', phone -> \'(123) 456-0987\', street1 -> \'1 Any Street\', street2 -> \'\', city -> \'Boomtown\', state -> \'New York\', country -> \'us\', postal -> \'54637\'','2016-04-20 20:33:43'),(12,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: \'La La Land\'','2016-04-20 20:38:09'),(13,'tlee (Client)','10.0.2.2 - ','Info','Added New Location: name -> \'La La Land\', website -> \'\', email -> \'\', phone -> \'(123) 456-0987\', street1 -> \'1 Any Street\', street2 -> \'\', city -> \'Boomtown\', state -> \'New York\', country -> \'us\', postal -> \'54637\'','2016-04-20 20:38:27'),(14,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: \'La La Land\'','2016-04-20 20:41:42'),(15,'tlee (Client)','10.0.2.2 - ','Info','Added New Location: name -> \'La La Land\', website -> \'\', email -> \'\', phone -> \'(123) 456-0987\', street1 -> \'1 Any Street\', street2 -> \'\', city -> \'Boomtown\', state -> \'New York\', country -> \'us\', postal -> \'54637\'','2016-04-20 20:47:33'),(16,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: \'La La Land\'','2016-04-20 20:52:39'),(17,'tlee (Client)','10.0.2.2 - ','Info','Account Changes: ','2016-04-21 03:20:38'),(18,'tlee (Client)','10.0.2.2 - ','Info','Added New Location: name -> \'La La Land\', website -> \'\', email -> \'\', phone -> \'(123) 456-0987\', street1 -> \'1 Any Street\', street2 -> \'\', city -> \'Boomtown\', state -> \'New York\', country -> \'us\', postal -> \'54637\'','2016-04-21 03:23:54'),(19,'tlee (Client)','10.0.2.2 - ','Info','Deleted Location: \'La La Land\'','2016-04-21 03:24:14'),(20,'tlee (Client)','10.0.2.2 - ','Info','Account Changes: street2: \'Apt. C\' -> \'Apt. C2\'','2016-04-26 00:59:27'),(21,'marketertest (Marketer)','10.0.2.2 - ','Info','Added New Advertisementheadline -> \'Test Headline.\'; body -> \'<p>This is the body of the advertisement.</p>\r\n<p>I know it is bland. <strong>BUT WHO CARES?</strong></p>\'; email -> \'bob@example.com\'; phone -> \'1234547890\'; website -> \'http://www.example.com\'','2016-04-29 19:06:21'),(22,'marketertest (Marketer)','10.0.2.2 - ','Info','Added New Advertisementheadline -> \'This is a great advert with a very long headline. Want to see how things look when characters are cut off.\'; body -> \'<p>We like big <span style=\"color: #993300; background-color: #000000;\"><strong><span style=\"font-size: 14pt;\">ads</span></strong></span>!&nbsp; How about you?</p>\r\n<p>We like <span style=\"font-size: 18pt; font-family: impact,sans-serif;\"><strong>big</strong></span> ads, yes we do!</p>\'; email -> \'bob@example.com\'; phone -> \'(123) 456-0987\'; website -> \'http://www.example.com\'','2016-05-03 18:58:53'),(23,'marketertest (Marketer)','10.0.2.2 - ','Info','Added New Advertisementheadline -> \'Use Our Service!\'; body -> \'<p>We like caterers, which is why you want to use us!</p>\r\n<p>Seriously!</p>\r\n<p>Use our service.&nbsp; Buy from us.</p>\'; email -> \'\'; phone -> \'\'; website -> \'\'','2016-05-05 18:07:30'),(24,'marketertest (Marketer)','10.0.2.2 - ','Info','Updated Advertisementheadline: \'Use Our Service!\' -> \'Use Our Service! Please!\'','2016-05-05 18:32:03'),(25,'marketertest (Marketer)','10.0.2.2 - ','Info','Deleted Advertisement &gt;Use Our Service! Please!&lt;','2016-05-05 19:05:53'),(26,'marketertest (Marketer)','10.0.2.2 - ','Info','Account Changes: company: \'Bob\'s Photography\' -> \'Bob\'s Photography Palace\'; username: \'MarketerTest\' -> \'\'','2016-05-11 17:44:19'),(27,'marketertest (Marketer)','10.0.2.2 - ','Info','Account Changes: poc_name: \'Marketer Test\' -> \'Marketer Test, Jr.\'; username: \'marketertest\' -> \'\'','2016-05-11 21:56:45'),(28,'marketertest (Marketer)','10.0.2.2 - ','Info','Account Changes: username: \'marketertest\' -> \'\'','2016-05-11 23:48:30'),(29,'marketertest (Marketer)','10.0.2.2 - ','Info','Account Changes: username: \'marketertest\' -> \'\'','2016-05-11 23:50:58'),(30,'marketertest (Marketer)','10.0.2.2 - ','Info','Account Changes: ','2016-05-11 23:54:16');
/*!40000 ALTER TABLE `user_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` char(73) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `confirmed` int(1) unsigned DEFAULT '0',
  `created_on` datetime NOT NULL,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='utf8_unicode_ci';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'badkarma','Bad Karma','{CRYPT}$2a$04$SLg1Ogo/Hat3ZPFUf.SN9.iQ/gOkewGyQBE5guuEK/ox4UaxuY01G','badkarma@side7.com',1,'2016-01-17 22:17:38',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-05-13 16:21:42
