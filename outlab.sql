Q1.

Find, for each match venue, the average number of runs scored per match (total of both teams) in the stadium. You can get the runs scored from the ball_by_ball table. Output (venue_name, avg_runs) , in descending order of average runs per match.
Note : Calculate avg_run upto 3 decimal places. 

Ans. with match_avgs(match_id, venue_id, total_runs) as 
(
	select match.match_id, match.venue_id, cast(sum(runs_scored) as decimal(7,3))
	from match, ball_by_ball, venue
	where match.match_id = ball_by_ball.match_id and
	venue.venue_id = match.venue_id
	group by match.match_id

)
select venue_name, cast(avg(total_runs) as decimal(7,3)) from match_avgs, venue
where match_avgs.venue_id = venue.venue_id
group by venue_name
order by avg(total_runs) desc



Q2.

Find players who faced the maximum number of balls per match on average; a batsman faced a ball if there is an entry in ball_by_ball with that player as the striker. Limit your answer to the top 10 by using sparse rank (you may get more than 10 in case of ties).
Output (player_id, player_name, average count of balls faced per match)

Ans. with player_match(player_id, player_name, match_id, balls) as
(
	select player_id, player_name, match.match_id, count(*) as balls
	from ball_by_ball, player, match where
	match.match_id = ball_by_ball.match_id and player_id = ball_by_ball.striker
	group by player_id, match.match_id
),
player_avg(player_id, player_name, avg_cnt)
as (
	select player_id, player_name, avg(balls) as avg_cnt
	from player_match
	group by player_id, player_name
),
player_rank(player_id, player_name, avg_cnt, rank) 
as (
select player_id, player_name, avg_cnt, rank() over (order by avg_cnt desc) as balrank
from player_avg
	order by balrank
)
select player_id, player_name, avg_cnt from player_rank
where player_rank.rank <= 10;


Q3.

Find players who are the most frequent six hitters, that is, players who hit a 6 in the highest fraction of balls that they face. Output the player id, player name, the number of times the player has got 6 runs in a ball, the number of balls faced, and the fraction of 6s. Output (player_id, player_name, numsixes, numballs, frac)
(Note 1: The striker attribute in the ball_by_ball relation is the player who scored the runs.)
(Note 2: Int divided by int gives an int, so make sure to multiply by 1.0 before division.)

Ans. with player_balls(player_id, balls) as
(
	select striker, count(*)
	from ball_by_ball
	group by striker
),
player_sixs(player_id, sixs) as
(
	select striker, count(runs_scored)
	from ball_by_ball
	where runs_scored = 6
	group by striker
)
select player_id, player_name, numsixes, numballs, frac from
(
select player.player_id, player_name, sixs as numsixes, balls as numballs, (sixs*1.0)/balls as frac, rank() over (order by (sixs*1.0)/balls  desc) as frank
from  player_balls, player_sixs, player
where player_sixs.player_id = player.player_id and player.player_id = player_balls.player_id
order by frank
	) as outpu
where frank = 1



Q4.

Find top 3(exactly 3) batsmenÃÂ¢ÃÂÃÂ and top 3(exactly 3) bowlersÃÂ¢ÃÂÃÂ player_ids who got highest no of runs and highest no of wickets respectively in each season. Output (season_year, batsman, runs, bowler, wickets). Here batsman & bowler are player_ids of the players. Incase of ties output the player with lesser player_id first. Order by season_year (earlier year comes first) and rank(batsman and bowler with more no of runs and wickets in a particular season comes first). There will be (no_of_seasons*3) rows.

Ans. with season_bat(season_year, player_id, player_name, runs, runs_rank, runs_row)
as(
	select match.season_year, player_id, player_name, sum(runs_scored) as runs, 
	rank() over(partition by season_year order by sum(runs_scored) desc, player_id asc) as runs_rank,
	row_number() over(partition by season_year order by sum(runs_scored) desc, player_id asc) as runs_row
	from match, ball_by_ball, player
	where match.match_id = ball_by_ball.match_id and player.player_id = ball_by_ball.striker
	group by match.season_year, player_id, player_name
	order by sum(runs_scored) desc, player_id asc
),
season_bowl(season_year, player_id, player_name, wickets, wickets_rank, wickets_row)
as(
	select match.season_year, player_id, player_name, count(out_type) as wickets,
	rank() over(partition by season_year order by count(out_type) desc, player_id asc) as wickets_rank,
	row_number() over(partition by season_year order by count(out_type) desc, player_id asc) as wickets_row
	from match, ball_by_ball, player
	where match.match_id = ball_by_ball.match_id and player.player_id = ball_by_ball.bowler
	and out_type is not null and out_type not in ('run out', 'hit wicket', 'retired hurt')
	group by match.season_year, player_id, player_name
	order by count(out_type) desc, player_id asc
)
select season_bat.season_year, season_bat.player_id as batsman, season_bat.runs as runs,
season_bowl.player_id as bowler, season_bowl.wickets as wickets
from season_bat, season_bowl
where wickets_row <= 3 and runs_row <= 3 and wickets_row = runs_row and
season_bat.season_year = season_bowl.season_year
order by season_year, wickets_row asc



Q5.

Find the ids of players who got the highest no of partnership runs for each match. There can be multiple rows for a single match. Output (player1âs contribution i.e. runs1 >= player2âs contribution i.e. runs2 ), in descending order of pship_runs (incase of ties compare match_id in ascending order). If runs1=runs2  then player1_id > player2_id.
Note: extra_runs shouldnât be counted

Ans. with match_part(match_id, u1, u2, runs, prank)
as(
	select match_id, u1, u2, sum(runs_scored), 
	rank() over(partition by match_id order by sum(runs_scored) desc) 
	from
	(select *, least(striker, non_striker) as u1, greatest(striker, non_striker) as u2
	from ball_by_ball) as ball_extend
	group by match_id, u1, u2
	order by match_id, sum(runs_scored) desc
),
match_part2(match_id, u1, u2, runs, prank, u1_runs, u2_runs)
as(
	select ball_by_ball.match_id, u1, u2, runs, prank, sum(runs_scored), runs-sum(runs_scored)
	from match_part, ball_by_ball
	where match_part.match_id = ball_by_ball.match_id and u1 = striker 
	and u2 = non_striker
	group by ball_by_ball.match_id, u1, u2, runs, prank
),
match_part3(match_id, player1_id, player2_id, runs1, runs2, runs, prank)
as
(
select match_id,  
	case when u1_runs > u2_runs then u1 
		when u1_runs = u2_runs then (case when u1>u2 then u1 else u2 end)
		else u2 end, 
	case when u1_runs < u2_runs then u1 
		when u1_runs = u2_runs then (case when u1>u2 then u2 else u1 end)
		else u2 end,  
	case when u1_runs > u2_runs then u1_runs 
		when u1_runs = u2_runs then u1_runs 
		else u2_runs end,
	case when u1_runs < u2_runs then u1_runs 
		when u1_runs = u2_runs then u1_runs
		else u2_runs end, 
	runs, prank
from match_part2
)
select match_id, player1_id, player2_id, runs1, runs2, runs as pship_runs from match_part3
where prank<= 1
order by pship_runs desc, match_id asc



Q6.

For all the matches with win type as ÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂwicketsÃÂÃÂÃÂÃÂ¢ÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ, find the over ids in which the runs scored are less than 6 runs. Output (match_id, innings_no, over_id).
Note : Runs scored in an over also include the extra_runs.

Ans. with runs_over_match(match_id, innings_no, over_id, runs) as 
(	select match.match_id, innings_no, over_id, sum(runs_scored + extra_runs)
 	from ball_by_ball, match
 	where match.match_id = ball_by_ball.match_id and
 	match.win_type = 'wickets'
 	group by match.match_id, innings_no, over_id
 	order by match.match_id, innings_no, over_id
)
select match_id, innings_no, over_id from runs_over_match
where runs < 6



Q7.

List top 5 batsmen(exactly 5) by number of sixes hit in the season 2013? Break ties alphabetically. Output (player_name).

Ans. select player_name from (
select player_id, player_name, count(*) as sixes
from match, player, ball_by_ball
where match.match_id = ball_by_ball.match_id and match.season_year = 2013 and
player.player_id = ball_by_ball.striker and runs_scored = 6
group by player_id
order by sixes desc, player_name) as outpu
limit 5;



Q8.

List 5 bowlers(exactly 5) by lowest strike rate(average number of balls bowled per wicket taken) in the season 2013?  Break ties alphabetically. Output (player_name).

Ans. with player_balls(player_id, balls) as
(
	select bowler, count(*)
	from match, ball_by_ball
	where match.match_id = ball_by_ball.match_id and match.season_year = 2013
	group by bowler
),
player_wicks(player_id, wicks) as
(
	select bowler, count(out_type)
	from match, ball_by_ball
	where match.match_id = ball_by_ball.match_id and match.season_year = 2013
	and out_type is not null and out_type not in ('run out', 'hit wicket', 'retired hurt')
	group by bowler
)
select player_name from
(
select player_name, cast((balls*1.0)/wicks as decimal(10, 3)) as str_rate, wicks, balls
from  player_balls, player_wicks, player
where player_wicks.player_id = player.player_id and player.player_id = player_balls.player_id
order by str_rate asc, player_name asc
	limit 5
	) as outpu 



Q9.

For each country(with at least one player bowled out) find out the number of its players who were bowled out in any match. Output (country_name, count). Here the country is the home country of the player.

Ans. with bowled_players(player_id)
as (
	select distinct striker from ball_by_ball where
	out_type = 'bowled'
)
select country_name, count(distinct bowled_players.player_id)
from player, bowled_players where
player.player_id = bowled_players.player_id
group by country_name



Q10.

List the names of right- handed players who have scored at least a century in any match played in 'Pune'ÃÂ. Order the output alphabetically on player_name.  Output (player_name).

Ans. select player_name from (
select player_id, player_name, sum(runs_scored) as runs
from ball_by_ball, venue, match, player where
ball_by_ball.striker = player_id and city_name = 'Pune' and
batting_hand in ('Right-hand bat', 'Right-handed') and match.venue_id = venue.venue_id and 
ball_by_ball.match_id = match.match_id 
group by player_id, match.match_id
having sum(runs_scored) > 99 
	)
	as outpu
order by player_name



Q11.

Find the win percentage for all the teams that have won at least one match(across all seasons). Order the result alphabetically on team names.  Output (team_name, win_percentage).
Win percentage of a team can be calculated as = (number of matches won by the team / total number of the matches played by the team) * 100 
Note : Calculate percentage upto 3 decimal places. 

Ans. with team_matches(team_id, matches) as
(
	select team_id, count(*)
	from match, team
	where team1 = team_id or team2 = team_id
	group by team_id
),
team_wins(team_id, wins) as
(
	select team_id, count(*)
	from match, team
	where match_winner = team_id
	group by team_id
)
select team_name, cast((wins*100.0)/matches as decimal(10, 3)) as win_percentage
from  team_wins, team_matches, team
where team.team_id = team_wins.team_id and team_matches.team_id = team_wins.team_id
order by team_name







