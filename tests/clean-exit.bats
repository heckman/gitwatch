#!/usr/bin/env bats

setup_file() {
  export gitwatch_pid=0
  export gitwatch_script="${BATS_TEST_DIRNAME}/../gitwatch.sh"
}

setup(){
  readonly repo_branch="master"
  readonly local_repo="${BATS_TEST_TMPDIR}/local/repo"
  readonly remote_repo="${BATS_TEST_TMPDIR}/remote/repo"
  readonly gitwatch_output="${BATS_TEST_TMPDIR}/output"
  readonly watched_directory="$local_repo"
  initialize_git_repositories
  cd "$watched_directory"
}

@test 'descendant processes are terminated on exit' {
  start_gitwatch
  sleep 0.2 # enough time to allow gitwatch to launch descendant processes
  stop_gitwatch
  sleep 1.3 # enough time to allow descendant processes to wind down
  assert_no_descendant_processes_running
}

teardown() {
  stop_gitwatch_if_running
  sleep 1.3 # enough time to allow descendant processes to wind down
  kill_any_descendant_processes
}

## suite functions

initialize_git_repositories() {
  git init --quiet --bare --initial-branch "$repo_branch" "$remote_repo"
  git clone --quiet "$remote_repo" "$local_repo" 2>/dev/null
}

# fail if gitwach is already running
start_gitwatch() {
  (( "$gitwatch_pid" == 0 )) || return 1
  "$gitwatch_script" "$@" "$watched_directory" > "${gitwatch_output}" 3>&- &
  gitwatch_pid=$!
}

# fail if gitwach is not running
stop_gitwatch() {
  (( "$gitwatch_pid" > 0 )) || return 1
  kill "$gitwatch_pid"
  gitwatch_pid=0
  }

stop_gitwatch_if_running() {
  (( "$gitwatch_pid" == 0 )) || stop_gitwatch
}

## utility functions

assert_no_descendant_processes_running() {
  pgrep -fl "$watched_directory" >&2 && return 1 || return 0
}

kill_any_descendant_processes() {
  pkill -f "$watched_directory" || (( $? ==1 )) # exit 1 means no matches
}

# usefull for debugging
info(){ { (( "$#" == 0 )) && cat - || echo "$@"; } >&3; }
debug(){ info "$@"; }
debug_funcname(){ debug "${FUNCNAME[1]}" "$@"; }
