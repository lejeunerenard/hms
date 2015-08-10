-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sun Aug  9 23:27:48 2015
-- 

;
BEGIN TRANSACTION;
--
-- Table: roles
--
CREATE TABLE roles (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(128) NOT NULL
);
--
-- Table: users
--
CREATE TABLE users (
  created_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  updated_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  id INTEGER PRIMARY KEY NOT NULL,
  email varchar(128) NOT NULL,
  password varchar(255) NOT NULL,
  first_name varchar(64) NOT NULL,
  last_name varchar(64) NOT NULL,
  invited_on datetime,
  invitation_key varchar(255),
  is_email_confirmed boolean DEFAULT 0,
  email_confirmation_key varchar(255)
);
CREATE UNIQUE INDEX users_email ON users (email);
--
-- Table: houses
--
CREATE TABLE houses (
  owner_id integer NOT NULL,
  created_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  updated_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(255) NOT NULL,
  FOREIGN KEY (owner_id) REFERENCES users(id)
);
CREATE INDEX houses_idx_owner_id ON houses (owner_id);
--
-- Table: categories
--
CREATE TABLE categories (
  owner_id integer NOT NULL,
  created_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  updated_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  id INTEGER PRIMARY KEY NOT NULL,
  house_id integer NOT NULL,
  name varchar(64) NOT NULL,
  FOREIGN KEY (house_id) REFERENCES houses(id),
  FOREIGN KEY (owner_id) REFERENCES users(id)
);
CREATE INDEX categories_idx_house_id ON categories (house_id);
CREATE INDEX categories_idx_owner_id ON categories (owner_id);
--
-- Table: months_staying
--
CREATE TABLE months_staying (
  owner_id integer NOT NULL,
  created_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  updated_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  house_id integer NOT NULL,
  month integer NOT NULL,
  year integer NOT NULL,
  percentage decimal(3,2) NOT NULL,
  FOREIGN KEY (house_id) REFERENCES houses(id),
  FOREIGN KEY (owner_id) REFERENCES users(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX months_staying_idx_house_id ON months_staying (house_id);
CREATE INDEX months_staying_idx_owner_id ON months_staying (owner_id);
CREATE INDEX months_staying_idx_user_id ON months_staying (user_id);
--
-- Table: role_user
--
CREATE TABLE role_user (
  created_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  updated_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  role  NOT NULL,
  user  NOT NULL,
  PRIMARY KEY (role, user),
  FOREIGN KEY (role) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX role_user_idx_role ON role_user (role);
CREATE INDEX role_user_idx_user ON role_user (user);
--
-- Table: expenses
--
CREATE TABLE expenses (
  owner_id integer NOT NULL,
  created_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  updated_on datetime(32) DEFAULT CURRENT_TIMESTAMP,
  id INTEGER PRIMARY KEY NOT NULL,
  house_id integer NOT NULL,
  category_id integer NOT NULL,
  name varchar(255) NOT NULL,
  description text,
  amount decimal(8,2) NOT NULL,
  month integer NOT NULL,
  year integer NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (house_id) REFERENCES houses(id),
  FOREIGN KEY (owner_id) REFERENCES users(id)
);
CREATE INDEX expenses_idx_category_id ON expenses (category_id);
CREATE INDEX expenses_idx_house_id ON expenses (house_id);
CREATE INDEX expenses_idx_owner_id ON expenses (owner_id);
COMMIT;
