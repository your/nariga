# Coursera's Deadlines Visualizer (codename: Nariga) #

A *"at one glance"* solution for those who follow and are determined to succed in more than one course.

More info here: [http://res.sharped.net/](http://res.sharped.net/)

# What shall be done SOON

* Add a course adder (global) input field
* Add a status to a deadline: "working on"
* Add a status to a deadline: "accomplished"
* Add a course filter (choose only the courses you want to)
* Add a simple cookie mechanism to save settings (auth not required)

# What this in NOT (yet) and what is TODO

This, due to time constraints, has no rigourous programming design behind (so bad.).

If the idea is liked, TODOs are:

* Design a database (relational?) to allow people to have a personal account with settings
* Add support for deadlines from other MOOC services, such as edX
* Add timed email alerts

## Languages Used

Basic HTML and CSS, as a skeleton for a JavaScript compiled source code written in Dart Language.

## Installation Requirements
* Ruby (latest version)
* [Dart Editor](https://www.dartlang.org/) or equivalent framework with Dart SDK

## Installing on Deploy server
Installing [icalendar](https://github.com/icalendar/icalendar) ruby gem (patched)(*):

    gem uninstall icalendar
    cd icalendar_PATCHED
    gem build icalendar.gemspec 
    gem install icalendar-2.2.0.gem 
(\*) N.B. : **this will require the original version to be removed if present**; in a near future I'm forking it from the authors github and patching it there, or asking for a pull request to support the X-WR-CALNAME field.