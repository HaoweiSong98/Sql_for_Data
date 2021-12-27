USE zika;

-- Exercise 1
-- Write SQL to show the reports of Zika in the data set up to and including 4-29-2016 report date. Show
-- report_date, location, location_type, data_field and value. (Rows: 67710)
select * from zikacase;
-- ex1
SELECT report_date, location, location_type, data_field, case_value FROM zikacase where report_date <= '2016-04-29';

-- ex2
SELECT * FROM zikacase WHERE report_date = '2016-06-29' AND data_field = 'zika_reported_travel' AND location = 'United_States-Minnesota';

-- ex3
SELECT report_date, location, data_field FROM zikacase WHERE case_value = 161241;

-- ex4
SELECT report_date, location, data_field, case_value FROM zikacase WHERE location_type in ('county', 'territory', 'state') AND location LIKE 'United_States%' AND data_field = 'zika_reported_travel';

-- ex5
SELECT report_date, location, data_field, case_value FROM zikacase WHERE location_type = 'county' AND location LIKE 'United_States-Florida%' order by case_value DESC LIMIT 1;

-- ex6
SELECT * FROM zikacase WHERE location IN ('Brazil', 'El_Salvador');

-- ex7
SELECT report_date, location, sum(case_value) FROM zikacase WHERE location like 'Argentina%' and report_date = '2016-06-26' group by location;

-- ex8
SELECT data_field FROM zikacase GROUP BY data_field;

-- ex9
SELECT * FROM zikacase WHERE location = 'Brazil-Rio_de_Janeiro' and data_field = 'zika_reported' and (report_date > '2016-05-10' and report_date < '2016-07-01');

-- ex10
SELECT * FROM zikacase WHERE location = 'Brazil-Rio_de_Janeiro' and data_field = 'zika_reported' and report_date < '2016-05-10';


-- ex11
USE pets_stackexchange;
SELECT * FROM posts;
SELECT * FROM posts order by Score DESC LIMIT 15;
SELECT * FROM posts as P
	JOIN users ON P.OwnerUserId = users.Id
	ORDER BY Score DESC LIMIT 15;
-- -- After sort by score I Start to join users data, I find these users have high reputation
-- Then I join one more table - comments to check

SELECT * FROM posts as P
	JOIN users ON P.OwnerUserId = users.Id
    JOIN comments AS C ON C.PostId = P.Id
	ORDER BY P.Score DESC;
-- I see the user 129, this user has a lot of posts and likes to edit others post, 
-- so my preliminary judgment is that the scoring is based on several aspects. 
-- For example, if a user has a higher number of views on other posts or the user 
-- has a higher-rated reply, then he may have a higher hidden score.
SELECT * FROM users ORDER BY Reputation DESC;

-- ex12

    
SELECT Title, DisplayName, Reputation FROM posts
	JOIN users ON users.Id = posts.OwnerUserId
    where Title is not null ORDER BY Reputation DESC;
	

-- ex13
  
SELECT Title,
	(SELECT CreationDate FROM Posts AS P WHERE P.Id = PostId) AS first_creationdate,
    (SELECT Title FROM Posts AS  P WHERE P.Id = RelatedPostId) AS linked_post_title,
    (SELECT CreationDate FROM Posts AS P WHERE P.Id = RelatedPostId) AS second_creationdate
    FROM Postlinks
	JOIN Posts ON Posts.Id = PostId
    WHERE LinkTypeId = 3;

-- ex14
SELECT Title, Posts.CreationDate, Text, comments.CreationDate FROM comments
	JOIN Posts ON Posts.Id = PostId
    WHERE Posts.Score >= 20 AND Title IS NOT NULL;
    
-- ex15

SELECT Title, DisplayName, Age, Location FROM Posts
	JOIN votes AS V ON V.PostId = Posts.Id
    JOIN Users AS U ON U.Id = OwnerUserId
    WHERE OwnerUserId = V.UserId;
    
-- ex16

SELECT Id, DisplayName, Location FROM Users
    WHERE BINARY users.Location LIKE '%NY%' OR BINARY users.Location LIKE '%New York%';

-- ex17

SELECT DisplayName, Location, WebsiteUrl FROM Users
	WHERE Id IN (SELECT UserId FROM badges);


SELECT DisplayName, Location, WebsiteUrl FROM Users
	WHERE Id IN (SELECT UserId FROM badges);
    
SELECT distinct DisplayName, Location, WebsiteUrl FROM Users
	join badges as B
    where Users.Id = B.UserId;

-- ex18
SELECT P.Title, Posts.Body, Posts.Score FROM Posts
	JOIN Posts AS P
	WHERE Posts.Id = p.AcceptedAnswerId AND Posts.Score >= 20;

-- ex19
SELECT posts.Id, posts.Title, Us.DisplayName, Us.Location,
	(SELECT DisplayName FROM users AS U WHERE U.Id = LastEditorUserId) AS LastEditor_Name,
    (SELECT Location FROM users AS U WHERE U.Id = LastEditorUserId) AS LastEditor_Location
    From posts
	JOIN users AS Us ON Us.Id = OwnerUserId
    WHERE ViewCount > 2000 AND LastEditorUserId IS NOT NULL;

-- ex20

SELECT T.TagName, max(ViewCount) FROM posts
	JOIN tags AS T WHERE Tags LIKE CONCAT('%<', TagName,'>%') group by TagName;

SELECT Id, Title, ViewCount, TagName FROM posts
	JOIN (SELECT TagName, max(ViewCount) as max_num FROM posts
			JOIN tags AS T WHERE Tags LIKE CONCAT('%<', TagName,'>%') group by TagName) as TT USING (TagName)
	JOIN tags AS T WHERE Tags LIKE CONCAT('%<', TagName,'>%') group by TagName;

