#!/usr/bin/env bats

load suite_functions.bash


function remote_git_dirs_working_with_commit_logging { #@test

    # Move .git somewhere else
    dotgittestdir="$local_repo/../foreign_git"
    mkdir "$dotgittestdir"
    mv "$local_repo/.git/"* "$dotgittestdir"
    rmdir "$local_repo/.git"

    start_gitwatch -l 10 -g "$dotgittestdir"

    # According to inotify documentation, a race condition results if you write
    # to directory too soon after it has been created; hence, a short wait.
    sleep $before_writing_to_a_newly_created_directory

    echo "line1" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    # Store commit for later comparison
    lastcommit=$(commit_hash --git-dir "$dotgittestdir")

    # Make a new change
    echo "line2" >> file1.txt
    sleep $to_let_gitwatch_react_to_changes

    # Verify that new commit has happened
    [[ $(commit_hash --git-dir "$dotgittestdir") != "$lastcommit" ]]

    # Check commit log that the diff is in there
    run git --git-dir "$dotgittestdir" log -1 --oneline
    [[ $output == *"file1.txt"* ]]

}

