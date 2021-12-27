USE imdb;
-- ex1
alter table movies_sample add index release_year_ix (release_year);
alter table movies_sample drop index release_year_ix;
SELECT * FROM movies_sample WHERE release_year = 2000;
explain SELECT * FROM movies_sample WHERE release_year = 2008;

-- ex2
alter table movies_sample add index movieid_ix (movieid);
alter table movies_sample drop index movieid_ix;
SELECT moviename, release_year FROM movies_sample WHERE movieid = 476084;
explain SELECT moviename, release_year FROM movies_sample WHERE movieid = 476084;

-- ex3
alter table movies_sample add index movies_year_name_ix (release_year, moviename);
alter table movies_sample drop index movies_year_name_ix;
SELECT moviename,
        release_year
   FROM movies_sample
  WHERE release_year BETWEEN 2000 AND 2010
    AND moviename = 'The Gift';
-- If I drop the index the running time will be 1.894 sec, but after I add index the running time will be 0.229sec
    
-- ex4
SELECT * FROM movies_sample where moviename REGEXP ' [0-9]{3}$';

-- ex5
SELECT `number`,count(`number`) as number_times FROM movies_sample as m1 
LEFT JOIN (SELECT movieid, right(moviename,3) as `number` from movies_sample) as m2 USING(movieid)
where moviename REGEXP ' [0-9]{3}$'
group by `number`
order by number_times DESC limit 10;

-- ex6
SELECT moviename as name2, movieid FROM movies_sample where moviename REGEXP '^wars$|^wars[^a-z]|[^a-z]wars[^a-z]|[^a-z]wars$';
SELECT * FROM movies_sample where moviename REGEXP '^war$|^war[^a-z]|[^a-z]war[^a-z]|[^a-z]war$|^wars$|^wars[^a-z]|[^a-z]wars[^a-z]|[^a-z]wars$';

-- ex7
USE employees;
DELIMITER $$
DROP PROCEDURE sp_update_dept;
CREATE PROCEDURE sp_update_dept(IN empid int, IN depid varchar(7))
BEGIN
	UPDATE dept_emp SET to_date = date(now()) - 1 WHERE emp_no = empid;
    INSERT INTO dept_emp VALUES(empid, depid,date(now()),99990101);
END$$
DELIMITER ;
