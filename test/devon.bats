#!/usr/bin/env bats
load helper.bash

@test "CLI loads successfully" {
  run devon
  [ "$status" -eq 0 ]
  [[ "$output" =~ "devon" ]]
}

@test "shows version info" {
  run devon --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "devon" ]]
}

@test "prints helpful message on unknown command" {
  run devon foobar
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unbekanntes Kommando" ]]
}

@test "displays help output" {
  run devon help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "USAGE" ]]
}
