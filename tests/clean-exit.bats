#!/usr/bin/env bats

load suite_functions.bash

teardown(){
  # stop_gitwatch # don't try and stop gitwatch a second time
  kill_any_descendant_processes # in case the test fails
}

@test 'descendant processes are terminated on exit' {

  start_gitwatch
  sleep 0.2 # enough time to allow gitwatch to launch descendant processes

  stop_gitwatch
  sleep 1.3 # enough time to allow descendant processes to wind down

  assert_no_descendant_processes_running

}
