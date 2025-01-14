select * from public.player_seasons ps limit 100


create TYPE season_stats as (
	season INTEGER,
	gp INTEGER,
	pts real,
	reb real,
	ast real
)

create type scoring_class as enum ('star', 'good', 'average', 'bad')

--drop table players;
create table players(
	player_name text,
	height text,
	college text,
	country text,
	draft_year text,
	draft_round text,
	draft_number text,
	season_stats season_stats[],
	scoring_class scoring_class,
	years_since_last_season INTEGER,
	current_season INTEGER,
	is_active BOOLEAN,
	primary key (player_name, current_season)
);


insert into players
with yesterday as (select * from public.players ps where ps.current_season = 2002),
	today as (select * from public.player_seasons ps where ps.season = 2003)
	select
		coalesce(t.player_name, y.player_name) as player_name,
		coalesce(t.height, y.height) as height,
		coalesce(t.college, y.college) as college,
		coalesce(t.country, y.country) as country,
		coalesce(t.draft_year, y.draft_year) as draft_year,
		coalesce(t.draft_round, y.draft_round) as draft_round,
		coalesce(t.draft_number, y.draft_number) as draft_number,
		case when y.season_stats is null then ARRAY[row(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
			when t.season is not null then y.season_stats || ARRAY[row(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
			else y.season_stats
		end as season_stats,
		case when t.season is not null then
			case when t.pts > 20 then 'star'
				when t.pts > 15 then 'good'
				when t.pts > 10 then 'average'
				else 'bad'
				end :: scoring_class
				else y.scoring_class
			end as scoring_class,
		case when t.season is not null then 0 else y.years_since_last_season + 1 end as years_since_last_season,
		coalesce(t.season, y.current_season + 1) as current_season,
		case when t.season is not null then true else false end as is_active
		from yesterday as y full outer join today as t on y.player_name = t.player_name;
		
	
select player_name, "scoring_class", is_active from players
where current_season =2001


create table players_scd (
	player_name text,
	scoring_class scoring_class,
	is_active BOOLEAN,
	current_season INTEGER,
	primary key(player_name, current_season)
)
