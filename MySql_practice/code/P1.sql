-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema a8_ex1
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema a8_ex1
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `a8_ex1` DEFAULT CHARACTER SET utf8 ;
USE `a8_ex1` ;

-- -----------------------------------------------------
-- Table `a8_ex1`.`Employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`Employee` (
  `eid` INT NOT NULL AUTO_INCREMENT,
  `emp_fname` VARCHAR(45) CHARACTER SET 'DEFAULT' NULL,
  `emp_lname` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`eid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `a8_ex1`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`Patient` (
  `pid` INT NOT NULL AUTO_INCREMENT,
  `pat_fname` VARCHAR(45) NULL,
  `pat_lname` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`pid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `a8_ex1`.`Doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`Doctor` (
  `eid` INT NOT NULL,
  `specialty` VARCHAR(45) NULL,
  PRIMARY KEY (`eid`),
  CONSTRAINT `eid`
    FOREIGN KEY (`eid`)
    REFERENCES `a8_ex1`.`Employee` (`eid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `a8_ex1`.`Appointment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`Appointment` (
  `aid` INT NOT NULL AUTO_INCREMENT,
  `scheduled_time` DATETIME NOT NULL,
  `Doctor_eid` INT NOT NULL,
  `Patient_pid` INT NOT NULL,
  PRIMARY KEY (`aid`),
  INDEX `fk_Appointment_Doctor1_idx` (`Doctor_eid` ASC) VISIBLE,
  INDEX `fk_Appointment_Patient1_idx` (`Patient_pid` ASC) VISIBLE,
  CONSTRAINT `fk_Appointment_Doctor1`
    FOREIGN KEY (`Doctor_eid`)
    REFERENCES `a8_ex1`.`Doctor` (`eid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Appointment_Patient1`
    FOREIGN KEY (`Patient_pid`)
    REFERENCES `a8_ex1`.`Patient` (`pid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `a8_ex1`.`Note`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`Note` (
  `noteid` INT NOT NULL AUTO_INCREMENT,
  `note_text` VARCHAR(45) NOT NULL,
  `aid` INT NOT NULL,
  PRIMARY KEY (`noteid`, `aid`),
  INDEX `fk_Note_Appointment1_idx` (`aid` ASC) VISIBLE,
  CONSTRAINT `fk_Note_Appointment1`
    FOREIGN KEY (`aid`)
    REFERENCES `a8_ex1`.`Appointment` (`aid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `a8_ex1`.`Nurse`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`Nurse` (
  `eid` INT NOT NULL,
  PRIMARY KEY (`eid`),
  CONSTRAINT `eid`
    FOREIGN KEY (`eid`)
    REFERENCES `a8_ex1`.`Employee` (`eid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `a8_ex1`.`NurseAppointment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `a8_ex1`.`NurseAppointment` (
  `Nurse_eid` INT NOT NULL,
  `aid` INT NOT NULL,
  PRIMARY KEY (`Nurse_eid`, `aid`),
  INDEX `fk_NurseAppointment_Appointment1_idx` (`aid` ASC) VISIBLE,
  CONSTRAINT `Nurse_eid`
    FOREIGN KEY (`Nurse_eid`)
    REFERENCES `a8_ex1`.`Nurse` (`eid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `aid`
    FOREIGN KEY (`aid`)
    REFERENCES `a8_ex1`.`Appointment` (`aid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
