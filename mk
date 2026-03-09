#!/usr/bin/env bash

# Naming Policy:
#
# Standalone script — no namespace prefix, no global suffix.
# Functions: cmd.PascalCase (mk.bash convention).
# Locals: camelCase.  Globals: PascalCase.
# _ suffix: contains IFS characters (e.g., Usage_).

Prog=$(basename "$0")   # match what the user called
Version=0.2

read -rd '' Usage_ <<END
Usage:

  $Prog [OPTIONS] [--] COMMAND

  Commands:

    test          -- run all tests

    contract      -- publish a contract event
    complete      -- publish a completion event
    interaction   -- publish an interaction event
    plan          -- publish a plan event (from file)

    task          -- publish a task event
    done          -- publish a task-done event
    open          -- list open tasks
    audit         -- full task reconciliation
    claim         -- claim a task
    unclaim       -- release a claim
    claims        -- list active claims

  Options:

    -h | --help     show this message and exit
    -v | --version  show the program version and exit
    -x | --trace    enable debug tracing
END

BinDir=bin
ProjectRoot=$PROJECT_ROOT
TaskStream=tasks.$(basename "$ProjectRoot")
TaskAudit=$ProjectRoot/$BinDir/task-audit

## helpers

json.Str() {
  local v=${1//\\/\\\\}
  v=${v//\"/\\\"}
  printf '%s' "$v"
}

## commands

cmd.test() {
  mk.Cue bash tests/integration/smoke-test.sh
}

## protocol event commands

cmd.contract() {
  local payload
  if [[ $# -ge 1 ]]; then
    payload=$1
  else
    payload=$(cat)
  fi
  [[ -n $payload ]] || { echo "usage: $Prog contract <criteria> (or pipe/heredoc)" >&2; return 1; }
  era publish -s $TaskStream --type contract "$payload"
}

cmd.complete() {
  local payload
  if [[ $# -ge 1 ]]; then
    payload=$1
  else
    payload=$(cat)
  fi
  [[ -n $payload ]] || { echo "usage: $Prog complete <attestation> (or pipe/heredoc)" >&2; return 1; }
  era publish -s $TaskStream --type complete "$payload"
  echo "$payload" | $ProjectRoot/$BinDir/validate-attestation $TaskStream
}

cmd.interaction() {
  [[ $# -ge 1 ]] || { echo "usage: $Prog interaction <description>" >&2; return 1; }
  local payload
  payload=$(printf '{"description":"%s"}' "$(json.Str "$1")")
  era publish -s $TaskStream --type interaction "$payload"
}

cmd.plan() {
  [[ $# -ge 1 ]] || { echo "usage: $Prog plan <file>" >&2; return 1; }
  [[ -f $1 ]] || { echo "error: '$1' not found" >&2; return 1; }
  era publish -s $TaskStream --type plan "$(cat "$1")"
}

## task stream commands

cmd.task() {
  [[ $# -ge 1 ]] || { echo "usage: $Prog task <description>" >&2; return 1; }
  local payload
  payload=$(printf '{"description":"%s"}' "$(json.Str "$1")")
  era publish -s $TaskStream --type task "$payload"
}

cmd.done() {
  [[ $# -ge 1 ]] || { echo "usage: $Prog done <id>[,<id>...] [evidence]" >&2; return 1; }
  local ids=$1
  local evidence=${2:-}
  # validate: all comma-separated parts are numeric
  local parts
  IFS=, read -ra parts <<< "$ids"
  local id
  for id in "${parts[@]}"; do
    [[ $id =~ ^[0-9]+$ ]] || { echo "error: '$id' is not a numeric ID" >&2; return 1; }
  done
  # era splits -m on commas, so use + as separator in refs value
  local refsVal=${ids//,/+}
  local payload
  payload=$(printf '{"refs":"%s","description":"%s"}' "$ids" "$(json.Str "$evidence")")
  era publish -s $TaskStream --type task-done -m "refs=$refsVal" "$payload"
}

cmd.open() {
  $TaskAudit open $TaskStream
}

cmd.audit() {
  $TaskAudit audit $TaskStream
}

cmd.claim() {
  [[ $# -ge 2 ]] || { echo "usage: $Prog claim <id> <name>" >&2; return 1; }
  [[ $1 =~ ^[0-9]+$ ]] || { echo "error: '$1' is not a numeric ID" >&2; return 1; }
  if ! $TaskAudit check $TaskStream "$1" 2>/dev/null; then
    echo "warning: task #$1 already claimed" >&2
  fi
  local payload
  payload=$(printf '{"ref":%s,"claimer":"%s"}' "$1" "$(json.Str "$2")")
  era publish -s $TaskStream --type claim -m "refs=$1,claimer=$2" "$payload"
}

cmd.unclaim() {
  [[ $# -ge 1 ]] || { echo "usage: $Prog unclaim <id>" >&2; return 1; }
  [[ $1 =~ ^[0-9]+$ ]] || { echo "error: '$1' is not a numeric ID" >&2; return 1; }
  local payload
  payload=$(printf '{"ref":%s}' "$1")
  era publish -s $TaskStream --type unclaim -m "refs=$1" "$payload"
}

cmd.claims() {
  $TaskAudit claims $TaskStream
}

## boilerplate

source ~/.local/lib/mk.bash 2>/dev/null ||
  eval "$(curl -fsSL https://raw.githubusercontent.com/binaryphile/mk.bash/develop/mk.bash)" ||
  { echo 'fatal: mk.bash not found' >&2; exit 1; }

# enable safe expansion
IFS=$'\n'
set -o noglob

mk.SetProg $Prog
mk.SetUsage "$Usage_"
mk.SetVersion $Version

return 2>/dev/null    # stop if sourced, for interactive debugging
mk.HandleOptions $*   # handle standard options, returns 1-based offset
mk.Main ${*:$?}       # remaining arguments
