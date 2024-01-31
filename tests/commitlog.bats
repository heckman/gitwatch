#!/usr/bin/env bats

load suite_functions.bash


function commit_log_messages_working { #@test

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

