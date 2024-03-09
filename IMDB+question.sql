USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:


SELECT 
    COUNT(*)
FROM
    director_mapping;
-- No. of rows=3867
    
SELECT 
    COUNT(*)
FROM
    genre;
-- No. of rows=14662

SELECT 
    COUNT(*)
FROM
    movie;
    
-- No. of rows=7997
    
SELECT 
    COUNT(*)
FROM
    names;

-- No. of rows=25735
    
SELECT 
    COUNT(*)
FROM
    ratings;
    
-- No. of rows=7997
    
SELECT 
    COUNT(*)
FROM
    role_mapping;

-- No. of rows=15615




-- Q2. Which columns in the movie table have null values?
-- Type your code below:

select sum(case when id is null then 1 else 0 end) as is_null
from movie;

-- No null values


select sum(case when title is null then 1 else 0 end) as is_null
from movie;

-- No null values

select sum(case when year is null then 1 else 0 end) as is_null
from movie;

-- No null values

select sum(case when date_published is null then 1 else 0 end) as is_null
from movie;

-- No null values

 select sum(case when country is null then 1 else 0 end) as is_null
from movie;

-- 20 null values

select sum(case when worlwide_gross_income is null then 1 else 0 end) as is_null
from movie;

-- 3724 null values

select sum(case when languages is null then 1 else 0 end) as is_null
from movie;

-- 194 null values


select sum(case when production_company is null then 1 else 0 end) as is_null
from movie;

-- 528 null values



-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Part 1
SELECT 
    YEAR(date_published) AS Year, COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY YEAR(date_published)
ORDER BY number_of_movies DESC;

-- Solution Comment: Most movies were released in 2017.

-- Part 2 

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY number_of_movies DESC;

-- Solution  Comment: Most movies were released in March




/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:


SELECT 
    SUM(number_of_movies)
FROM
    (SELECT 
        country, COUNT(*) AS number_of_movies
    FROM
        movie
    WHERE
        YEAR(date_published) = 2019
            AND (country LIKE '%USA%'
            OR country LIKE '%India%')
    GROUP BY country) AS IQ;


-- Solution Comment: Total no. of movies produced by India and US is 1059 in 2019.




/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

-- List

SELECT DISTINCT
    (genre)
FROM
    genre;


SELECT 
    COUNT(DISTINCT (genre))
FROM
    genre;

-- Solution Comment: No. of unique genres is 13






/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
    genre, COUNT(*) AS number_of_movies
FROM
    movie m
        JOIN
    genre g ON m.id = g.movie_id
GROUP BY genre
ORDER BY number_of_movies DESC;

-- Solution Comment: Drama has the most movies produced







/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:



WITH movie_with_one_genre as 
	(SELECT id, 
			title,
			genre,
			count(genre) over(partition by id )as number_of_genres_for_each_movie
	FROM
		movie m join genre g
	ON m.id=g.movie_id)

SELECT 
    COUNT(*) AS number_of_movies_with_one_genre
FROM
    movie_with_one_genre
WHERE
    number_of_genres_for_each_movie = 1;

-- Solution Comment: No. of movies with one genre is 3289







/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    genre, AVG(duration) AS avg_duration
FROM
    movie m
        JOIN
    genre g ON m.id = g.movie_id
GROUP BY genre
ORDER BY avg_duration DESC;





/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


SELECT IQ.*,
RANK() OVER(ORDER BY movie_count desc)
FROM(
	SELECT genre,count(*) as movie_count 
	FROM
	movie m JOIN genre g
	ON m.id=g.movie_id
	GROUP BY genre) as IQ;


-- Solution Comment: Thriller genre is at rank 3 among the movies with 1484 movies.




/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;


    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT 
	title,
	avg_rating,
	rank() over(order by avg_rating desc) as movie_rank 
FROM
	movie m 
	JOIN
	ratings r
ON m.id=r.movie_id;







/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, COUNT(*) AS movie_count
FROM
    movie m
        JOIN
    ratings r ON m.id = r.movie_id
GROUP BY median_rating
ORDER BY movie_count DESC;

-- Solution Comment: 7 has the max movie count followed by 8





/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	*,
    rank() over(order by movie_count desc) as prod_company_rank
FROM(
	SELECT 
		production_company,
        count(*) as movie_count
	FROM
		movie m
        JOIN
    ratings r ON m.id = r.movie_id
    WHERE avg_rating>8 and production_company is not null
GROUP BY production_company) as IQ;






-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:



SELECT 
    genre, COUNT(*) AS movie_count
FROM
    movie m
        JOIN
    ratings r ON m.id = r.movie_id
        JOIN
    genre g ON r.movie_id = g.movie_id
WHERE
    MONTH(date_published) = 3
        AND YEAR(date_published) = 2017
        AND total_votes > 1000
        AND country LIKE '%USA%'
GROUP BY genre
ORDER BY movie_count DESC;

-- Solution Comment: Drama has the highest amount of movies released in USA in MArch 2017 with 24 movies.





-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:



SELECT 
    title, avg_rating, genre
FROM
    movie m
        JOIN
    ratings r ON m.id = r.movie_id
        JOIN
    genre g ON r.movie_id = g.movie_id
WHERE
    avg_rating > 8 AND title LIKE 'The%'
ORDER BY genre;






-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:



SELECT 
    COUNT(*)
FROM
    movie m
        JOIN
    ratings r ON m.id = r.movie_id
        JOIN
    genre g ON r.movie_id = g.movie_id
WHERE
    date_published BETWEEN '2018-04-01' AND '2019-04-01'
        AND median_rating = 8;

-- Solution Comment: No. of movies is 652



-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


SELECT 
    SUM(total_votes)
FROM
    movie m
        JOIN
    ratings r ON m.id = r.movie_id
WHERE
    languages LIKE '%German%';


-- No. of votes = 4421525

SELECT 
    SUM(total_votes)
FROM
    movie m
        JOIN
    ratings r ON m.id = r.movie_id
WHERE
    languages LIKE '%Italian%';

-- No. of votes= 2559540






-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names;





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Finding the top 3 genres:

SELECT 
    genre, COUNT(*)
FROM
    genre g
        JOIN
    movie m 
		ON 
    g.movie_id = m.id
		JOIN
	ratings r
		ON
	r.movie_id=m.id
WHERE avg_rating>8        
GROUP BY genre
ORDER BY COUNT(*) DESC
LIMIT 3;

-- Top 3 genres are Drama, Action and Comedy



SELECT 
    name, COUNT(*)
FROM
     names n 
        JOIN
    director_mapping d ON d.name_id = n.id
        JOIN
    genre g ON d.movie_id = g.movie_id
        JOIN
    ratings r ON g.movie_id = r.movie_id
WHERE
    avg_rating > 8 AND genre in( 'Drama','Action','Comedy')
	
GROUP BY name
ORDER BY COUNT(*) DESC;

-- Solution Comment: James Mangold is the top director




/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    name, COUNT(*) AS movie_count
FROM
    ratings
        JOIN
    role_mapping USING (movie_id)
        JOIN
    names ON names.id = role_mapping.name_id
WHERE
    median_rating >= 8
        AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;

-- Solution Comment : Answer is Mammootty and Mohanlal



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select 
	*,
	rank() over(order by vote_count desc) as prod_comp_rank
	from(
			select production_company,sum(total_votes) as vote_count from 
			movie m join ratings r
			on m.id=r.movie_id
			group by production_company) as IQ limit 3;


-- Solution comment: Marvel Studios has the highest amount of votes, follwed by Twentieth Century fox and Warner Bros.





/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH actor AS(
		SELECT 
			name as actor_name, 
            sum(total_votes) as total_vote,
            count(*) as movie_count, 
            round(sum(total_votes*avg_rating)/sum(total_votes),2) as actor_avg_rating

		FROM 
			ratings r JOIN movie m ON
            r.movie_id=m.id JOIN role_mapping rm 
			ON rm.movie_id=m.id
			JOIN names n ON
			rm.name_id=n.id
			WHERE country LIKE'%India%' AND category='actor'
			GROUP BY name
			HAVING movie_count>=5)

SELECT 
	*,
	RANK() OVER(ORDER BY actor_avg_rating DESC,total_vote DESC) AS actor_rank
FROM 
	actor;





-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress AS(
		SELECT 
			name AS actress_name, 
			sum(total_votes) AS total_vote,
			count(*) AS movie_count, 
			round(sum(total_votes*avg_rating)/sum(total_votes),2) AS actress_avg_rating

		FROM
			ratings r 
            JOIN movie m 
            ON r.movie_id=m.id 
            JOIN role_mapping rm 
			ON rm.movie_id=m.id
			JOIN names n ON
			rm.name_id=n.id
			WHERE country LIKE '%India%' AND category='actress' AND languages LIKE '%Hindi%'
			GROUP BY NAME
			HAVING movie_count>=3)

SELECT 
	*,
	RANK() OVER(ORDER BY actress_avg_rating DESC,total_vote DESC) AS actress_rank
FROM 
	actress;


-- Solution Comment: Tapsee Pannu is ranked no. 1




/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

CREATE VIEW thriller AS
    SELECT 
        title,
        CASE
            WHEN avg_rating > 8 THEN 'Superhit movies'
            WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
            WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
            ELSE 'Flop movies'
        END AS movie_classification
    FROM
        movie m
            JOIN
        genre g ON m.id = g.movie_id
            JOIN
        ratings r ON g.movie_id = r.movie_id
    WHERE
        genre LIKE '%Thriller%';

SELECT 
    movie_classification, COUNT(*) as number_of_movies
FROM
    thriller
GROUP BY movie_classification
ORDER BY number_of_movies DESC;



-- Solution Comment: One-time-watch movies are the highest in number, followed by flop movies




/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT
	genre,
    AVG(duration) OVER(PARTITION BY genre) AS avg_duration,
	sum(duration) OVER(PARTITION BY genre ORDER BY movie_id ASC) AS runnint_total_duration,
	ROUND(avg(duration) OVER(PARTITION BY genre ORDER BY movie_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS moving_avg_duration
FROM 
	genre g JOIN movie m
	ON g.movie_id=m.id;




-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

SELECT 
    genre, COUNT(*)
FROM
    genre g
        JOIN
    movie m ON g.movie_id = m.id
GROUP BY genre
ORDER BY COUNT(*) DESC
LIMIT 3;

-- Comment: Top 3 genres are Drama, Comedy and Thriller

SELECT * 
FROM(
	SELECT genre,year, 
	title as movie_name,worlwide_gross_income as worldwide_gross_income,
	dense_rank() over(partition by year order by cast(substring(worlwide_gross_income,3) as signed) desc) as movie_rank
	FROM
	genre g join movie m
	ON g.movie_id=m.id
	WHERE genre in ('Drama','Comedy','Thriller')) as IQ
WHERE movie_rank between 1 and 5;

-- Comment: Dense Rank is used here to simplify movies repeating twice due to different genres


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH production_company AS(
		SELECT 
			production_company,
            count(*) AS movie_count 
		FROM
			movie m JOIN ratings r
			ON m.id=r.movie_id
			WHERE languages LIKE'%,%' and median_rating>=8 and production_company is not null
			GROUP BY production_company)

SELECT 
*,
RANK() OVER(ORDER BY movie_count desc) as prod_comp_rank
FROM production_company;


-- Star Cinema tops the list followed by Twentieth Century Fox


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT 
*, 
RANK() OVER(ORDER BY movie_count desc,actress_avg_rating desc) AS actress_rank
FROM(
	SELECT 
		name AS actress_name,
		sum(total_votes) AS 'total_votes',
		count(*) AS movie_count, 
		(sum(avg_rating * total_votes))/(sum(total_votes)) AS actress_avg_rating

	FROM 
		names n JOIN role_mapping rm
		ON n.id=rm.name_id join ratings r
		ON rm.movie_id=r.movie_id
		JOIN genre g ON r.movie_id=g.movie_id
		JOIN movie m on g.movie_id=m.id
		WHERE avg_rating>8 and genre ='Drama' and category='actress'
		GROUP BY name
		ORDER BY count(*) desc) as IQ;


-- Comment: 4 actresses have the max no. of movies, out of which Susan Brown, Amanda Lawrence and Denise Gough 
-- have the higher average rating

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:




CREATE VIEW directors AS
    (SELECT 
        dm.name_id,
        r.movie_id,
        name,
        title,
        date_published,
        avg_rating,
        total_votes,
        duration
    FROM
        names n
            JOIN
        director_mapping dm ON n.id = dm.name_id
            JOIN
        movie m ON dm.movie_id = m.id
            JOIN
        ratings r ON m.id = r.movie_id);

CREATE VIEW target AS(
	SELECT 
		*,
        ROW_NUMBER() OVER (ORDER BY number_of_movies desc) AS row_n
	FROM(
		SELECT 
			name_id,
            count(*) as number_of_movies
		FROM directors
	GROUP BY name_id) as IQ
LIMIT 9);

CREATE VIEW ct AS
    (SELECT 
        *
    FROM
        directors
    WHERE
        name_id IN (SELECT 
                name_id
            FROM
                target));

create view ctr as(
select *,lag(date_published) over(partition by name_id order by date_published) as lag_date
from ct);

CREATE VIEW final AS
    (SELECT 
        *, DATEDIFF(date_published, lag_date) AS inter_movie_days
    FROM
        ctr);

SELECT 
    name_id AS director_id,
    name AS director_name,
    COUNT(*) AS number_of_movies,
    AVG(inter_movie_days) AS avg_inter_movie_days,
    SUM(avg_rating * total_votes) / SUM(total_votes) AS 'avg_rating',
    SUM(total_votes) AS 'total_votes',
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM
    final
GROUP BY name_id
ORDER BY COUNT(*) DESC;


