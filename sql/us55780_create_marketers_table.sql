-- phpMyAdmin SQL Dump
-- version 4.0.6
-- http://www.phpmyadmin.net
--
-- Host: localhost:3306
-- Generation Time: Dec 11, 2015 at 03:52 AM
-- Server version: 5.5.37
-- PHP Version: 5.4.19

SET SQL_MODE  = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `catering`
--

-- --------------------------------------------------------

--
-- Table structure for table `marketers`
--
-- Creation: Dec 11, 2015 at 03:50 AM
--

DROP TABLE IF EXISTS `marketers`;
CREATE TABLE IF NOT EXISTS `marketers` (
  `id`       bigint(20)   unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(40)  COLLATE utf8_unicode_ci NOT NULL,
  `password` char(40)     COLLATE utf8_unicode_ci NOT NULL,
  `poc_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `company`  varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email`    varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `phone`    varchar(25)  COLLATE utf8_unicode_ci NOT NULL,
  `street1`  varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `street2`  varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city`     varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `state`    varchar(50)  COLLATE utf8_unicode_ci NOT NULL,
  `zip`      varchar(15)  COLLATE utf8_unicode_ci NOT NULL,
  `country`  char(2)      COLLATE utf8_unicode_ci NOT NULL,
  `website`  varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_on` datetime  NOT NULL,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Catering marketer records' AUTO_INCREMENT=1 ;

