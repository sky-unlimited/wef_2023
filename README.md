# INTRODUCTION

<img src="https://github.com/alexstan67/wef_2023/blob/master/app/assets/images/full-logo-early-dark.png" width="200" />

Weekend-Fly, built on the Rails framework, is tailored to assist a community of general aviation pilots in discovering destinations, ensuring they only fly where the weather welcomes them!"

Your Rules. Your Interests. Your Destinations.🌴🏕️

One Community. 💪

# WEEKEND-FLY

## Features
- 5 countries covered (lu,fr,de,nl,dk)
- User management
- Pilot preferences
- Airport searcher
- Airport details
- Fuel stations management
- Trip request to find best destinations
- Weather algorithm
- Newsletter subscription
- Contact form
- Legal terms
- 2 languages support (fr/en)

## Requirements
* ruby 3.2.2
* rbenv 1.2.0
* rails 7.1.2
* bundler 2.4.10
* postgresql-14
* memcached 1.6.14

## Required packages
On Debian distributions:

`sudo apt install postgresql-14-postgis-3 libproj-dev proj-bin libpq-dev gh memcached imagemagick libvips42`

## Installation
To run Weekend-Fly localy, follow those steps:

### ourairports.com sub-module
We update airports data from: [https://github.com/davidmegginson/ourairports-data]()

`git submodule update --init --recursive`

### Install all of the required gems
````bash 
bundle install
````

### Secrets - Credentials
Store following secrets in `config/credentials.yml.enc` by using: `EDITOR=vim rails credentials:edit`
````bash
#config/credentials.yml.enc
secret_key_base: your_secret_key

development:
  openweathermap:
    app_id: your_secret_key

action_mailer:
  mail_smtp_server: your_server
  mail_smtp_port: your_port
  mail_domain:  your_domain
  mail_login: your_login
  mail_password: your_password
````
Should you work in the team, ask for the encryption file `master.key`

### Secrets - Database
Copy the file `config/database.yml.example` and rename it `config/database.yml` that will be git ignored.
Make your own modifications inside it. However, Postgresql is mandatory because of the geospatial functions
handeled by Postgis extension.

````bash
# To create new db user, let's assume your database user will be `rubyuser`:
sudo su - postgres
createuser --pwprompt rubyuser
psql
ALTER USER rubyuser WITH SUPERUSER;
````
- Take care to use `postgis` adapter instead of `postgres` in `config/database.yml`

### Run migrations

Database creation: (Follow this order 👇) 
````bash
rails db:create
rails db:migrate
rails db:seed
````
Import the point of interests table (osm_pois). Should you need it, please ask for it: contact@sky-unlimited.lu
````bash
# Adapt to your PostgreSQL environment
psql -U rubyuser -h localhost -d wef_2023_development < osm_pois_backup.sql
````

### Launch local web server

`passenger start`

Visit http://localhost:3000

### Launch ActiveJob queuing backend

`bundle exec rake solid_queue:start`

## How to contribute

### Pull the code from master ⚠️

`git pull --recurse-submodules origin master`

### Create a new branch
Always work on branches that are linked to an issue.
1. Create or work on an existing issue that you assign yourself
2. Create a branch from github directly in order to retrieve a standardized branch name
3. To close a ticket, add "closes#xxx" in the issue when the PR is merged.

### Create a pull request
Please ensure before PR, the folliwing tests do pass:
- `rubocop`
- `Rails test`
- `Rails test:system`
Then,
1. `git push origin <branch>`
2. Let your coding partner review
3. Merge the pull request on master

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
