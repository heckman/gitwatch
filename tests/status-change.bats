#!/usr/bin/env bats

load suite_functions.bash


function commit_only_when_git_status_change { #@test

    start_gitwatch

    # According to inotify documentation, a race condition results if you write
    # to directory too soon after it has been created; hence, a short wait.
    sleep $before_writing_to_a_newly_created_directory

    echo "line1" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    touch file1.txt
    sleep $to_let_gitwatch_react_to_changes

    echo "hi there" > "$gitwatch_output"
    cat "$gitwatch_output"
    run git log -1 --oneline
    echo $output
    run grep "nothing to commit" "$gitwatch_output"
    [ $status -ne 0 ]

}


