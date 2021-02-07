drop table if exists player_match;
drop table if exists ball_by_ball;
drop table if exists match;
drop table if exists player;
drop table if exists venue;
drop table if exists team;

create table team
	(team_id		int,
	 team_name		varchar(100),
	 primary key (team_id)
	);

create table venue
	(venue_id		int,
	 venue_name		varchar(100),
	 city_name		varchar(100),
	 country_name	varchar(100),
	 primary key (venue_id)
	);

create table player
	(player_id		int,
	 player_name	varchar(100),
	 dob			date,
	 batting_hand	varchar(100),
	 bowling_skill	varchar(100),
	 country_name	varchar(100),
	 primary key (player_id)
	);

create table match
	(match_id		int,
	 season_year	int,
	 team1			int,
	 team2			int,
	 venue_id		int,
	 toss_winner	int,
	 match_winner	int,
	 toss_name		varchar(100)	check (toss_name in ('field', 'bat')), 
	 win_type		varchar(100)	check (win_type in ('wickets', 'runs') or win_type is null), 
	 man_of_match	int,
	 win_margin		int,
	 primary key (match_id),
	 foreign key (team1) references team,
	 foreign key (team2) references team,
	 foreign key (toss_winner) references team,
	 foreign key (match_winner) references team,
	 foreign key (venue_id) references venue,
	 foreign key (man_of_match) references player
	);


create table player_match
	(
		playermatch_key		bigint,
	 	match_id			int,
	 	player_id			int,
	 	role_desc			varchar(100)	check (role_desc in ('Player', 'Keeper', 'CaptainKeeper', 'Captain')), 
	 	team_id				int,
	 	primary key (playermatch_key),
	 	foreign key (match_id) references match,
	 	foreign key (player_id) references player,
	 	foreign key (team_id) references team
	);

create table ball_by_ball
	(match_id		int,
	 innings_no		int		check (innings_no >= 1 and innings_no <= 2),
	 over_id		int,
	 ball_id		int,
	 runs_scored	int 	check (runs_scored >= 0 and runs_scored <= 6),
	 extra_runs		int,
	 out_type		varchar(100)	check (out_type in ('caught', 'caught and bowled', 'bowled', 'stumped', 'retired hurt', 'keeper catch', 'lbw', 'run out', 'hit wicket') or out_type is null), 
	 striker		int,
	 non_striker	int,
	 bowler			int,
	 primary key (match_id, innings_no, over_id, ball_id),
	 foreign key (match_id) references match,
	 foreign key (striker) references player,
	 foreign key (non_striker) references player,
	 foreign key (bowler) references player
	);


