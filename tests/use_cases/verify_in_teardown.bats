#!/usr/bin/env bats

load '../../load'

function teardown() {
    unstub_all
}

@test "test success" {
    stub mycommand "foo : "
    run mycommand foo
}

@test "test failure due to missing call" {
    stub mycommand "foo : "
}

@test "test failure due to wrong call" {
    stub mycommand "foo : "
    run mycommand bar
}
