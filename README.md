# Advent of Code

This repository contains my solutions to [advent of code](https://adventofcode.com/).
Inputs are omitted as these are available on the advent of code site.

# AOC Module

Besides my solutions, this repository contains the AOC module.
This module contains a macro, `aoc`, that automatically generates a module named
based on the provided day and year. Besides this, it provides the `input` function
which automatically loads an input file in the correct location as a Stream of
strings.

# Mix Tasks

This repo also contains a mix task which automatically fetches the input and
creates a code skeleton for a given day.

It can be called as follows: `mix aoc.start -d <day> -y <year> -s <session>`.
Day and year can be omitted, when this is done they will default to the current
day and year.

The session argument is needed to fetch an input for a given day. It can be
obtained by investigating your cookies when logged in on the advent of code website.
When the session cookie is omitted, the mix task will load the session key specified
in the application configuration. If no session key is present, input can not be fetched.
