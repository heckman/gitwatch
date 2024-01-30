# Gitwatch Bats Tests

This directory contains tests for `gitwatch` written
using the [bats testing framework](https://github.com/bats-core/bats-core) ([documentation](https://bats-core.readthedocs.io/en/stable/)).

Executing `bats <file>.bats` will run all of the tests in `<file>.bats`.
So will executing `<file>.bats` directly (if it's executalbe).

Executing `bats <directory>` will run all of the tests
in every `.bats` file in the directory `<directory>`.
