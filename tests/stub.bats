#!/usr/bin/env bats

load '../load'

function teardown() {
    stub_reset
}

@test "Variables are set after loading" {
  [[ $BATS_MOCK_TMPDIR ]]
  [[ $BATS_MOCK_BINDIR ]]
}

@test "Stubs are created in BATS_MOCK_BINDIR which is subfolder of BATS_MOCK_TMPDIR" {
  stub mycommand "foo : "
  stub mycommand2 "foo2 : "
  # Folders must exist
  [[ -d "$BATS_MOCK_TMPDIR" ]]
  [[ -d "$BATS_MOCK_BINDIR" ]]
  # BINDIR must be in TMPDIR
  [[ "$BATS_MOCK_BINDIR" == "$BATS_MOCK_TMPDIR"/* ]]
  # Stubs must be inside BINDIR
  [[ "$(which mycommand)" == "$BATS_MOCK_BINDIR"/* ]]
  [[ "$(which mycommand2)" == "$BATS_MOCK_BINDIR"/* ]]
}

@test "Folders are cleaned up after unstub" {
  stub mycommand "foo : "
  stub mycommand2 "foo2 : "

  mycommand foo
  mycommand2 foo2
  # unstub first
  unstub mycommand
  # Folders must still exist
  [[ -d "$BATS_MOCK_TMPDIR" ]]
  [[ -d "$BATS_MOCK_BINDIR" ]]
  unstub mycommand2
  # Folders must be removed
  [[ ! -d "$BATS_MOCK_TMPDIR" ]]
  [[ ! -d "$BATS_MOCK_BINDIR" ]]
}

@test "stub_reset removes all stubs" {
  stub mycommand "foo : "
  stub mycommand2 "foo2 : "
  run stub_reset
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
  [[ "$(which mycommand)" != "$BATS_MOCK_BINDIR"/* ]]
  [[ "$(which mycommand2)" != "$BATS_MOCK_BINDIR"/* ]]
  # Folders must be removed
  [[ ! -d "$BATS_MOCK_TMPDIR" ]]
  [[ ! -d "$BATS_MOCK_BINDIR" ]]
}

@test "Calling stub_reset is always possible" {
  # Run without any stubs
  run stub_reset
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
  # Run after stub
  stub mycommand
  run stub_reset
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
  # Run twice
  run stub_reset
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
  # Run after unstub
  stub mycommand
  unstub mycommand
  run stub_reset
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}

@test "Calling stub_reset resets plans" {
  stub mycommand "foo : "
  stub mycommand2 "foo2 : "
  stub_reset
  stub mycommand "bar : "
  stub mycommand2 "bar2 : "
  mycommand bar
  mycommand2 bar2
  unstub mycommand # Success
  unstub mycommand2 # Success
}

@test "Calling unstub_all verifies all stubs" {
  # Success
  stub mycommand "foo : "
  stub mycommand2
  mycommand foo
  run unstub_all
  [ "$status" -eq 0 ]
  [ "$output" == "" ]

  # Fail first
  stub mycommand "foo : "
  stub mycommand2
  ! mycommand bar
  run unstub_all
  [ "$status" -eq 1 ]
  [ "$output" == 'Unexpected call: `mycommand bar`' ]

  # Fail second
  stub mycommand "foo : "
  stub mycommand2
  mycommand foo
  ! mycommand2
  run unstub_all
  [ "$status" -eq 1 ]
  [ "$output" == 'Unexpected call: `mycommand2`' ]

  # Fail both
  stub mycommand "foo : "
  stub mycommand2
  ! mycommand2
  run unstub_all
  [ "$status" -eq 1 ]
  [ "$output" == 'Missing call[1]: `mycommand foo`
Unexpected call: `mycommand2`' ]

  # Success if called again
  run unstub_all
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}
