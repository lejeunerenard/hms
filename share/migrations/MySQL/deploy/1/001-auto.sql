-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sun Aug  9 23:27:48 2015
-- 
;
SET foreign_key_checks=0;
--
-- Table: `roles`
--
CREATE TABLE `roles` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `users`
--
CREATE TABLE `users` (
  `created_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `id` integer NOT NULL auto_increment,
  `email` varchar(128) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(64) NOT NULL,
  `last_name` varchar(64) NOT NULL,
  `invited_on` datetime NULL,
  `invitation_key` varchar(255) NULL,
  `is_email_confirmed` enum('0','1') NULL DEFAULT '0',
  `email_confirmation_key` varchar(255) NULL,
  PRIMARY KEY (`id`),
  UNIQUE `users_email` (`email`)
) ENGINE=InnoDB;
--
-- Table: `houses`
--
CREATE TABLE `houses` (
  `owner_id` integer NOT NULL,
  `created_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  INDEX `houses_idx_owner_id` (`owner_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `houses_fk_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;
--
-- Table: `categories`
--
CREATE TABLE `categories` (
  `owner_id` integer NOT NULL,
  `created_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `id` integer NOT NULL auto_increment,
  `house_id` integer NOT NULL,
  `name` varchar(64) NOT NULL,
  INDEX `categories_idx_house_id` (`house_id`),
  INDEX `categories_idx_owner_id` (`owner_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `categories_fk_house_id` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`),
  CONSTRAINT `categories_fk_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;
--
-- Table: `months_staying`
--
CREATE TABLE `months_staying` (
  `owner_id` integer NOT NULL,
  `created_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `id` integer NOT NULL auto_increment,
  `user_id` integer NOT NULL,
  `house_id` integer NOT NULL,
  `month` integer NOT NULL,
  `year` integer NOT NULL,
  `percentage` decimal(3, 2) NOT NULL,
  INDEX `months_staying_idx_house_id` (`house_id`),
  INDEX `months_staying_idx_owner_id` (`owner_id`),
  INDEX `months_staying_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `months_staying_fk_house_id` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`),
  CONSTRAINT `months_staying_fk_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`),
  CONSTRAINT `months_staying_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;
--
-- Table: `role_user`
--
CREATE TABLE `role_user` (
  `created_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `role`  NOT NULL,
  `user`  NOT NULL,
  INDEX `role_user_idx_role` (`role`),
  INDEX `role_user_idx_user` (`user`),
  PRIMARY KEY (`role`, `user`),
  CONSTRAINT `role_user_fk_role` FOREIGN KEY (`role`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `role_user_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `expenses`
--
CREATE TABLE `expenses` (
  `owner_id` integer NOT NULL,
  `created_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `id` integer NOT NULL auto_increment,
  `house_id` integer NOT NULL,
  `category_id` integer NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NULL,
  `amount` decimal(8, 2) NOT NULL,
  `month` integer NOT NULL,
  `year` integer NOT NULL,
  INDEX `expenses_idx_category_id` (`category_id`),
  INDEX `expenses_idx_house_id` (`house_id`),
  INDEX `expenses_idx_owner_id` (`owner_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `expenses_fk_category_id` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `expenses_fk_house_id` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`),
  CONSTRAINT `expenses_fk_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;
SET foreign_key_checks=1;
