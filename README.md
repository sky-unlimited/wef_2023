# INTRODUCTION

<img src="https://github.com/alexstan67/wanderbird/blob/master/app/assets/images/full-logo-beta-dark.png" width="200" />

Wanderbird is based on Rails framework helping General Aviation fellows to find a destination !

# WANDERBIRD

## Features
TODO

## Requirements
* ruby 3.2.2
* rails 7.0.5
* bundler 2.4.10

## Installation
To run wanderbird locally, follow those steps:

Ensure to have a ".env" file at root directory containing devise confirmable email settings:
````bash
MAIL_USERNAME=noreply
MAIL_PASSWORD=password
MAIL_DOMAIN=example.com
MAIL_SMTP_SERVER=example.com
CONTACT_FORM_RECIPIENT=noreply@example.com
````

At the root of the project, we'll need airport data from (ourairports-data)[https://github.com/davidmegginson/ourairports-data]

`git clone https://github.com/davidmegginson/ourairports-data`

`bundle`

Database creation:
````bash
rails db:create
rails db:migrate
rails db:seed
````

Import Ourairports-data into database:
````bash
rake import:airports`
rake import:runways`
````

Launch local server:
`rails s`

Visit http://localhost:3000
