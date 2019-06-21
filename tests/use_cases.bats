#!/usr/bin/env bats

TESTS_ROOT="$BATS_TEST_DIRNAME/use_cases"

@test "verify in teardown" {
    run bats "$TESTS_ROOT/verify_in_teardown.bats" 
    [ "$status" -eq 1 ]
    echo "$output"
    [ "${lines[0]}" == '1..3' ]
    [ "${lines[1]}" == 'ok 1 test success' ]
    [ "${lines[2]}" == 'not ok 2 test failure due to missing call' ]
    [ "${lines[6]}" == '# Missing call[1]: `mycommand foo`' ]
    [ "${lines[7]}" == 'not ok 3 test failure due to wrong call' ]
    [ "${lines[11]}" == '# Unexpected call: `mycommand bar`' ]
}
