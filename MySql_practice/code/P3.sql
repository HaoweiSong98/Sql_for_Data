-- HW3
USE pets_stackexchange;
-- ex1

SELECT DisplayName, Location, WebsiteUrl FROM Users as U
left JOIN badges as B on B.UserId = U.Id
where B.UserId is null
GROUP BY DisplayName, Location, WebsiteUrl;

-- ex2
SELECT U.Id, P.Id
FROM users as U
LEFT JOIN posts as P ON P.OwnerUserId = U.id
UNION ALL
SELECT U.Id, P.Id FROM posts AS P
left join users as U on U.Id = P.OwnerUserId 
where U.Id is null;

-- ex3
-- SELECT DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)
-- SELECT DATEADD(dd, DATEDIFF(dd, 0, CreationDate), 0) as datea, count(datea) FROM posts group by CreationDate;
-- Select count(cast(CreationDate as DATE)) as min_date FROM posts group by cast(CreationDate as DATE) limit 1;

-- Select cast(CreationDate as DATE) as dt, count(cast(CreationDate as DATE)) as dt_time FROM posts group by cast(CreationDate as DATE);
select count(*) as min_date,
	(select count(*) from posts where cast(CreationDate as DATE) = '2014-05-03') as max_date,
    (select AVG(Score) from posts) as avg_score
from posts where cast(CreationDate as DATE) = '2013-10-08';




-- ex4
-- select Name, count(Name) as num from badges group by Name;
-- select Name, count(Name) as num from badges group by Name order by num DESC limit 1;
select Name, count(Name) as num from badges group by Name having num > 15 order by num DESC;

-- ex5

SELECT Id, Title, ViewCount, max_num,Tags, TagName FROM posts as p1
	JOIN (SELECT TagName, max(ViewCount) as max_num FROM posts
			JOIN tags AS T WHERE Tags LIKE CONCAT('%<', TagName,'>%') group by TagName) as TT on p1.Tags LIKE CONCAT('%<', TT.TagName,'>%')
            where ViewCount > max_num * 0.9 and ViewCount < max_num;
-- ex6
USE enron;
SELECT HOUR(messagedt), count(HOUR(messagedt)) 
FROM enron.edgemap
group by HOUR(messagedt) order by HOUR(messagedt);

-- ex7
SELECT substr(body, 1, locate(' ', body)) as fir_word, count(substr(body, 1, locate(' ', body))) as count 
FROM bodies group by substr(body, 1, locate(' ', body)) 
order by count DESC limit 20; 

-- ex8
SELECT E1.senderid as personid, E1.recipientid, max(datediff(E2.messagedt, E1.messagedt)) as datenum from edgemap as E1 
left join edgemap as E2 on E2.senderid = E1.recipientid and E2.recipientid = E1.senderid 
where E2.senderid is not null group by E1.senderid, E1.recipientid HAVING E1.senderid <> E1.recipientid ORDER by datenum DESC;
-- I think the personid who with 1489 is longest-tenured employee, because he or she return a email after 603 days.

-- ex9
SELECT personid, email, `name`, count(email) as send_time FROM messages LEFT JOIN (recipients LEFT JOIN people USING(personid)) USING(messageid) 
where senderid = personid and reciptype = 'to' and reciporder <> 1
group by personid, email, `name`;


-- 10



-- 11
USE Chinook;
SELECT `Name`, Composer, Title, sum(UnitPrice * Q) as `Total Sale` FROM Track
LEFT JOIN Album AS A USING (AlbumId)
LEFT JOIN (SELECT Trackid,count(TrackId) AS Q FROM InvoiceLine group by TrackId) AS T USING (Trackid)
GROUP by `Name`, Composer, Title having `Total Sale` > 1;

-- 12
SELECT E.FirstName, E.LastName, sum(`Total Track`), sum(`Total Sale`) FROM Employee AS E
LEFT JOIN (SELECT * FROM Customer 
	LEFT JOIN (SELECT CustomerId, sum(Totalnum) AS `Total Track`, sum(Total) as `Total Sale` FROM Invoice 
		LEFT JOIN (SELECT InvoiceId,sum(Quantity) as Totalnum FROM InvoiceLine group by InvoiceId) AS IL USING (InvoiceId) 
			group by CustomerId) AS CU USING (CustomerId)) AS CC ON CC.SupportRepId = EmployeeId
WHERE SupportRepId is not null
GROUP BY E.FirstName, E.LastName
ORDER BY E.FirstName, E.LastName;

-- 13
SELECT A.`Name`, count(A.`Name`) AS AppearNum FROM PlaylistTrack 
LEFT JOIN (Track LEFT JOIN (Album LEFT JOIN Artist AS A USING(ArtistId)) USING(AlbumId)) USING (TrackId)
WHERE MediaTypeId = 1
Group by A.`Name`
ORDER BY AppearNum DESC, A.`Name`;

-- 14
SELECT CustomerId, FirstName, LastName, year(InvoiceDate) as `year`, sum(Total) as Total FROM Invoice as I1
LEFT JOIN Customer using(CustomerId)
LEFT JOIN (SELECT CustomerId as CusId, (year(InvoiceDate) + 1) as `lastyear`, sum(Total) as preTotal FROM Invoice 
LEFT JOIN Customer using(CustomerId)
group by CustomerId, `lastyear`) AS I2 ON (I2.CusId = I1.CustomerId and lastyear = year(InvoiceDate))
group by CustomerId, FirstName, LastName, `year`, preTotal having Total > preTotal;

-- 15
SELECT `Name`, count(`Name`) as Name_t FROM (SELECT Artist.Name, count(Artist.Name) as Name_time, DATE_FORMAT(InvoiceDate,'%Y%m') as Year_m FROM InvoiceLine 
LEFT JOIN Invoice USING (InvoiceId)
LEFT JOIN (Track LEFT JOIN (Album LEFT JOIN Artist USING(ArtistId)) USING (AlbumId)) USING (TrackId)
group by Year_m,Artist.Name ORDER BY Year_m, Name_time DESC) AS A Group by `Name` ORDER BY Name_t DESC;