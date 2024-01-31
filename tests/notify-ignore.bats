#!/usr/bin/env bats

load suite_functions.bash


# Test for exclude from notifications. Verify that a subdirectory is ignored from notification.
function notify_ignore { #@test

    start_gitwatch -x test_subdir

    mkdir test_subdir
    # According to inotify documentation, a race condition results if you write
    # to directory too soon after it has been created; hence, a short wait.
    sleep $before_writing_to_a_newly_created_directory

    echo "line1" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    cd test_subdir
    echo "line2" >> file2.txt
    sleep $to_let_gitwatch_react_to_changes

    cat "$gitwatch_output"
    run git log --name-status --oneline
    echo $output

    # Look for files in log: file1 should be there, file2 should not be
    run grep "file1.txt" "$gitwatch_output"
    [ $status -eq 0 ]

    run grep "file2.txt" "$gitwatch_output"
    [ $status -ne 0 ]

}


