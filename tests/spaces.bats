#!/usr/bin/env bats

load suite_functions.bash


# This inserts custom repo location because of spaces in the file name
setup_file(){
  # this needs to be exported to be seen by setup()
  export local_repo="local with spaces/repo with spaces"
}

function spaces_in_target_dir { #@test
    # pwd | info
    start_gitwatch -l 10

    # According to inotify documentation, a race condition results if you write
    # to directory too soon after it has been created; hence, a short wait.
    sleep $before_writing_to_a_newly_created_directory

    echo "line1" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    echo "line2" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    # Check commit log that the diff is in there
    run git log -1 --oneline
    [[ $output == *"file1.txt"* ]]
}

