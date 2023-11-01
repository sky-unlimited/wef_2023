# INTRODUCTION

<img src="https://github.com/alexstan67/wef_2023/blob/master/app/assets/images/full-logo-early-dark.png" width="200" />

weekend-fly is based on Rails framework helping General Aviation fellows to find a destination !

Your Rules. Your Interests. Your Destination.🌴☀️🏕️

One Community 💪

# WEEKEND-FLY

## Features
TODO

## Requirements
* ruby 3.2.2
* rails 7.0.5
* bundler 2.4.10

## Installation
To run weekend-fly localy, follow those steps:

Ensure to have a ".env" file at root directory containing devise confirmable email settings:
````bash
MAIL_USERNAME=noreply
MAIL_PASSWORD=password
MAIL_DOMAIN=example.com
MAIL_SMTP_SERVER=example.com
MAIL_SMTP_PORT=465
OPENWEATHERMAP_API=your openweather api key
````
We update airports data from: [https://github.com/davidmegginson/ourairports-data]()

`git submodule update --init --recursive`

then, `bundle`

Database creation: (Follow this order 👇) 
````bash
rails db:create
rails db:migrate
rails import:countries
rails import:airports
rails import:runways
rails db:seed
````
Import the point of interest tables (osm_points, osm_lines, osm_polygones). Should you need them, please ask for it: contact@sky-unlimited.lu
````bash
# Adapt to your PostgreSQL environment
pg_restore -U $target_user --single-transaction --table=osm_points --data-only -h $target_host -d $target_database osm_points_backup.sql
pg_restore -U $target_user --single-transaction --table=osm_lines --data-only -h $target_host -d $target_database osm_lines_backup.sql
pg_restore -U $target_user --single-transaction --table=osm_polygones --data-only -h $target_host -d $target_database osm_polygones_backup.sql
````

Launch local server:

`rails s`

Visit http://localhost:3000

## How to contribute

### Pull the code from master ⚠️

`git pull --recurse-submodules origin master`

### Create a pull request
Always work on branches that are linked to an issue.
1. Create or work on an existing issue that you assign yourself
2. Create a branch from github directly in order to retrieve a standardized branch name
3. To close a ticket, add "closes#xxx" in the issue when the PR is merged.
4. `git push origin <branch>`
5. Merge the pull request

### Update submodules
````bash
cd ourairports-data
git pull origin main
cd ..
git commit -am"update ourairports-data"
git push origin master
# This way, the project will be associated to a defined version of the submodule
rails import:airports
rails import:runways
````
