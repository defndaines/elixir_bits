# Elixir Hodge Podge

Repository of miscellaneous Elixir code.

[exercism](exercism) Solutions to
[Exercism](http://exercism.io/languages/elixir/about) problems.

[2018-advent-of-code](2018-advent-of-code) In December 2018, I did a week of
Advent of Code in Elixir before getting too busy to continue.

[samples](samples) Some sanitized modules pulled from work code in order to
capture some examples of code I've written.

[game_of_life](game_of_life) Toying around with Conway's Game of Life back in
June 2021, but not in a working state. Was digging into optimizing for indexed
access, but got busy with non-game life.

## Elixir Projects

Rundown of other Elixir code I've pushed up to GitHub.

### Summoners Tail

Project using the Riot Games API.

https://github.com/defndaines/summoners_tail

2022-03-06

### Jishin

Project which monitors USGS earthquake information and notifies subscribers
via webhooks.

https://github.com/defndaines/jishin

2022-03-05

### Eiga

Personal dataset of movie reviews from a personal website I maintained up
until April 2007.

#### Phoenix with GraphQL

https://github.com/defndaines/eiga/tree/main/phoenix/eiga

2021-12-21

Playing around with [Absinthe](https://absinthe-graphql.org/) and GraphQL to
expose the movie data with relationships.

#### Maru with SQLite

https://github.com/defndaines/eiga/tree/main/maru_sqlite

2017-03-18

RESTful interface to movie and review data using Maru, which was a lightweight
API framework that's no longer actively maintained.

### Meat Bar

https://github.com/defndaines/meat_bar

2016-11-27

Simple REST-like service for tracking and analyzing Meat Bar consumption by
registered users. This was a take-home project for a job I was applying for,
so the functionality is aligned with that company's expectations.

### ToDo

https://github.com/defndaines/to_do

2016-09-26

Simple JSON API (using RESTful principles) that helps users manage tasks. This
was a take-home project for a job I was applying for, so the functionality is
aligned with that company's expectations.

### Logger.Backends.Logstash

https://github.com/defndaines/logger_logstash_backend

2015-06-08

This was an attempt to mimic the behavior of the `lager_logstash_backend`, but
for Elixir. The company I worked at at the time was using Logstash with
Erlang, but also had some Elixir code (using v0.12 of Phoenix). We ended up
finding a better way to solve the problem.
