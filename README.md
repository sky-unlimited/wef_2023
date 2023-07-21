# INTRODUCTION

<img src="https://github.com/alexstan67/wef_2023/blob/master/app/assets/images/full-logo-beta-dark.png" width="200" />

weekend-fly is based on Rails framework helping General Aviation fellows to find a destination !

# WEEKEND-FLY

## Features
TODO

## Requirements
* ruby 3.2.2
* rails 7.0.5
* bundler 2.4.10

## Installation
To run weekend-fly locally, follow those steps:

Ensure to have a ".env" file at root directory containing devise confirmable email settings:
````bash
MAIL_USERNAME=noreply
MAIL_PASSWORD=password
MAIL_DOMAIN=example.com
MAIL_SMTP_SERVER=example.com
OPENWEATHERMAP_API=your openweather api key
````
We update airports data from: [https://github.com/davidmegginson/ourairports-data]()

`git submodule update --init`

`bundle`

Database creation: (Follow this order 👇) 
````bash
rails db:create
rails db:migrate
rails import:countries
rails import:airports
rails import:runways
rails db:seed
````

Launch local server:
`rails s`

Visit http://localhost:3000
