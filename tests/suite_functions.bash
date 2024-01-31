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
  stop_gitwatch # fail if gitwach is not running, because that is unexpected
}



## suite functions

initialize_git_repositories() {
  git init --quiet --bare --initial-branch "$repo_branch" "$remote_repo"
  git clone --quiet "$remote_repo" "$local_repo" 2>/dev/null
}

# if gitwach is already running fail with exit code 71
# (at the moment, gitwatch never terminates with that exit code)
start_gitwatch() {
  (( "$gitwatch_pid" == 0 )) || return 71
  "$gitwatch_script" "$@" "$watched_directory" > "${gitwatch_output}" 3>&- &
  gitwatch_pid=$!
}

# if gitwach is not running fail with exit code 71
# (kill probably doesn't make use of that exit code; its documentation is vague)
stop_gitwatch() {
  (( "$gitwatch_pid" > 0 )) || return 71
  kill "$gitwatch_pid"
  gitwatch_pid=0
  }

commit_hash() {
  git "$@" rev-parse master
}

origin_commit_hash() {
  git "$@" rev-parse origin/master
}



## utility functions

assert_no_descendant_processes_running() {
  ! pgrep -fl "$watched_directory" >&2
}

kill_any_descendant_processes() {
  # exit 1 means no matches and that is ok
  pkill -f "$watched_directory" || return "$(tr 1 0 <<<$?)"
}

# usefull for debugging
info(){ { (( "$#" == 0 )) && cat - || echo "$@"; } >&3; }
debug(){ info "$@"; }
debug_funcname(){ debug "${FUNCNAME[1]}" "$@"; }
