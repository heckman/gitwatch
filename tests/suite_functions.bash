## common functions for the gitwatch bats test suite


## setup and teardown functions

setup(){
  export gitwatch_pid=0
  export gitwatch_script="${BATS_TEST_DIRNAME}/../gitwatch.sh"

  # delays
  export to_let_gitwatch_react_to_changes=4
  export before_writing_to_a_newly_created_directory=1

  # paths to all the things
  readonly repo_branch="master"
  readonly local_repo="${BATS_TEST_TMPDIR}/${local_repo:-local/repo}"
  readonly remote_repo="${BATS_TEST_TMPDIR}/remote/repo"
  readonly gitwatch_output="${BATS_TEST_TMPDIR}/output"
  readonly watched_directory="$local_repo"

  initialize_git_repositories
  # shellcheck disable=SC2164 # bats will catch this
  cd "$watched_directory"
}

teardown(){
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

commit_hash() {
  git "$@" rev-parse master
}

origin_commit_hash() {
  git "$@" rev-parse origin/master
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
