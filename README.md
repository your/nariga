# Coursera's Deadlines Visualizer (codename: Nariga) #

A *"at one glance"* solution for those who follow and are determined to succed in more than one course.

More info here: [http://res.sharped.net/](http://res.sharped.net/)

# What shall be done SOON

* Add a course adder (global) input field [STARTED: REQ COMPLETION]
* Add a status to a deadline: "working on" [STARTED: REQ COMPLETION]
* Add a status to a deadline: "accomplished" [STARTED: REQ COMPLETION]
* Add a course filter (choose only the courses you want to) [NOT STARTED YET!]
* Add a simple cookie mechanism to save settings (auth not required) [STARTED: REQ COMPLETION]
* Add a script to handle cron jobs [NOT STARTED YET!]

# What this in NOT (yet) and what is TODO

This, due to time constraints, has no rigourous programming design behind (so bad.).

If the idea is liked, TODOs are:

* Design a database (relational?) to allow people to have a personal account with settings [STARTED: REQ COMPLETION]
* Add support for deadlines from other MOOC services, such as edX [NOT STARTED YET!]
* Add timed email alerts [NOT STARTED YET!]

## Languages Used

Basic HTML and CSS, as a skeleton for a JavaScript compiled source code written in Dart Language.

Main management scripts are Unix shell scripts (Bash and sh supported), which call several Ruby scripted codes.
JSONs and AUTH are handled by a Python program, running with uWSGI wrapper over ngnix.

## Installation Requirements
* Ruby (latest version)
* Python (what version am I using?)
* [Dart Editor](https://www.dartlang.org/) or equivalent framework with Dart SDK

## Installing on Deploy server
Installing [icalendar](https://github.com/icalendar/icalendar) ruby gem (patched)(*):

    gem uninstall icalendar
    cd icalendar_PATCHED
    gem build icalendar.gemspec 
    gem install icalendar-2.2.0.gem 
(\*) N.B. : **this will require the original version to be removed if present**; in a near future I'm forking it from the authors github and patching it there, or asking for a pull request to support the X-WR-CALNAME field.

Installing uWSGI
(..)

Installing mongoDB
(..)

## Usage:

To manually add a new course:

    ./managers/nadd.sh https://class.coursera.org/COURSENAME-XYZ/api/course/calendar

To manually update all the courses:

    ./managers/nupdate.sh