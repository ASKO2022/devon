#!/usr/bin/env bats
load ../helper.bash

setup()    { setup_common; }
teardown() { teardown_common; }

@test "devon CLI is available" {
  run devon --version
  [ "$status" -eq 0 ]
}

@test "cert-reload command is defined" {
  run bash -c 'source ~/.devon/commands/cert-reload.sh; type cert_reload >/dev/null'
  [ "$status" -eq 0 ]
}

@test "devon cert-reload runs without error" {
  run devon cert-reload
  [ "$status" -eq 0 ]
}

@test "cert-reload output contains helpful info" {
  run devon cert-reload
  [[ "$output" =~ "Traefik" ]]
  [[ "$output" =~ "file-provider" ]]
  [[ "$output" =~ "Configuration loaded" ]]
}
