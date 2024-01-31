#!/usr/bin/env bats

load suite_functions.bash


function syncing_correctly { #@test

    start_gitwatch -r origin

    # According to inotify documentation, a race condition results if you write
    # to directory too soon after it has been created; hence, a short wait.
    sleep $before_writing_to_a_newly_created_directory

    echo "line1" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    # Verify that push happened
    [ $(commit_hash) = $(origin_commit_hash) ]

    # Try making subdirectory with file
    lastcommit=$(commit_hash)

    mkdir subdir
    echo "line2" >> subdir/file2.txt
    sleep $to_let_gitwatch_react_to_changes

    # Verify that new commit has happened
    currentcommit=$(git rev-parse master)
    [ $(commit_hash) != $lastcommit ]

    # Verify that push happened
    [ $(commit_hash) = $(origin_commit_hash) ]

    # Try removing file to see if can work
    rm subdir/file2.txt
    sleep $to_let_gitwatch_react_to_changes

    # Verify that new commit has happened
    [ $(commit_hash) != $lastcommit ]

    # Verify that push happened
    [ $(commit_hash) = $(origin_commit_hash) ]

}

