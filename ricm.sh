#!/bin/bash

space=' '
dash='-'

warn() {
    echo "$*" >&2
}


parse_args() {
    while getopts "r:i:h" opt; do
      case $opt in
        r)
          risk="$OPTARG"
          ;;
        i)
          intention="$OPTARG"
          ;;
	h) 
	    do_help
	    exit 2
	    ;;
        \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND-1))
    
    message="$*"
}


do_help(){
    usage 2>&1
    echo
    echo

    cat <<HELP_MESSAGE
|-------------------------------------------------------------------+----------------------------------------+--------------|
| Risk Level        | Code |  Meaning                               | Correctness Guarantees                                |
|-------------------+------+----------------------------------------+----------------------------------------+--------------|
| Known safe        | .    | Addresses all known and unknown risks. | Intended Change, Known Invariants, Unknown Invariants |
| Validated         | ^    | Addresses all known risks.             | Intended Change, Known Invariants                     |
| Risky             | !    | Some known risks remain unverified.    | Intended Change                                       |
| (Probably) Broken | @    | No risk attestation.                   |                                                       |
|-------------------------------------------------------------------+----------------------------------------+--------------|


|--------------------------------------------------------------------------------------------------------------------|
| Core intentions                                                                                                    |
|--------------------------------------------------------------------------------------------------------------------|
| Prefix | Name          | Intention                                                                                 |
|--------+---------------+-------------------------------------------------------------------------------------------|
| F      | Feature       | Change or extend one aspect of program behavior without altering others.                  |
| B      | Bugfix        | Repair one existing, undesirable program behavior without altering any others.            |
| r      | Refactoring   | Change implementation without changing program behavior.                                  |
| d      | Documentation | Change something which communicates to team members and does not impact program behavior. |
|--------+---------------+-------------------------------------------------------------------------------------------|


|--------------------------------------------------------------------------------------------------------------------|
| Extension intentions                                                                                               |
|--------------------------------------------------------------------------------------------------------------------|
| Prefix | Name          | Intention                                                                                 |
|--------|---------------+-------------------------------------------------------------------------------------------|
|        |               | Provable Refactorings                                                                     |
|        |               | Test-supported Procedural Refactorings                                                    |
|        |               | End-User Documentation                                                                    |
|        |               | Small Features and Bug Fixes                                                              |
|--------+---------------+-------------------------------------------------------------------------------------------|



# Extension Intentions

Each project can define a set of extension intentions. Each project
should define which extension codes it uses. It is up to each project
to define the approaches for each of the 4 risk levels.

These are some common intentions, each used in several projects. Each
also lists alternatives used in projects that don't use the code.

| Prefix | Name               | Intention                                                                                                                                                                   | Alternatives                                                                                                                                                                                                                                       |
| ---    | ---                | ---                                                                                                                                                                         | ---                                                                                                                                                                                                                                                |
| m      | Merge              | Merge branches.<br>Set risk level based on maximum for any individual commit in the branch.                                                                                 | Use 'F', 'B', or 'r', based on the primary intention of the branch. Optionally leave blank for merge from 'main' to a feature branch.                                                                                                              |
| t      | Test-only          | Alter automated tests without altering functionality. May include code-generating code that just throws a 'NotImplementedException' or similar approaches.                  | Use 'F' or 'B', depending on which kind of work this test is going to validate. Use 'r' if this is a refactoring purely within test code. It is a '.' risk level unless you also change product code.                                              |
| e      | Environment        | Environment (non-code) changes that affect development setup, and other tooling changes that don't affect program behavior (e.g. linting)                                   | Consider the environment to be a product where the users are team members, and code it accordingly.                                                                                                                                                |
| a      | Auto               | Automatic formatting, code generation, or similar tasks.                                                                                                                    | Use the intention that matches the reason you are performing the action, almost-certainly as a lower-case level of risk. For example, code cleanup would be 'r', and generating code to make a test for a new feature compile would be 't' or 'F'. |
| c      | Comment            | Changes comments only. Does not include comments that are visible to doc-generation tools.                                                                                  | Use 'd'.                                                                                                                                                                                                                                           |
| C      | Content            | Changes user-visible content, such as website copy.                                                                                                                         | Use 'F'.                                                                                                                                                                                                                                           |
| p      | Process            | Changes some team process or working agreement.                                                                                                                             | Any of: <ul><li>Use a tacit, informal process.</li><li>Use 'd'.</li><li>Keep your process definition outside of source control.</li></ul>                                                                                                          |
| s      | Spec               | Changes the spec or design. Used when team does formal specs or design reviews and keeps all such documents in the main product source, perhaps in the product code itself. | Any of: <ul><li>Use informal specs.</li><li>Use 'd'.</li><li>Use your test suite as your only spec and use 't'.</li><li>Keep your spec / design outside of source control.</li></ul>                                                               |
| n      | NOP                | A commit with no changes ('--allow-empty')                                                                                                                                  | Use 'r'.                                                                                                                                                                                                                                           |
| @      | Unknown / multiple | Made a bunch of changes and are just getting it checked in. No real way to validate safety, and may not even compile. Usually used at the highest risk level ('@ @').       | Don't allow this. Require each commit to do exactly one intention and document itself accordingly.                                                                                                                                                 |
HELP_MESSAGE

}


function risk_code {
    case $1 in
	safe)      echo -n '.' ;;
	validated) echo -n '^' ;;
	risky)     echo -n '!' ;;
	broken)    echo -n '@' ;;

	*)         echo -n ' ' ;;
    esac
}


risk_values() {
    echo "safe validated risky broken"
}


function intention_code {
    case $1 in
	feature)       echo -n 'f' ;;
	bugfix)        echo -n 'b' ;;
	refactoring)   echo -n 'r' ;;
	documentation) echo -n 'd' ;;

	*)             echo -n ' ' ;;
    esac	
}


intention_values() {
    echo "feature bugfix refactoring documentation"
}


usage() {
    warn "USAGE: $(basename $0) -r risk  -i intention  message..."
    warn "    risk in      $(risk_values)"
    warn "    intention in $(intention_values)"
}


validate_args(){
    if [[ "${risk}" == '' ]] 
    then
	warn 'Undefined risk.  Specify with -r flag.'
	usage
	exit 1
    fi

    if [[ "${intention}" == '' ]] 
    then
	warn 'Undefined intention.  Specify with -i flag.'
	usage
	exit 1
    fi

    if [[ "${message}" == '' ]]
    then
	warn 'Undefined message.'
	usage
	exit 1
    fi
}


parse_and_validate_args(){
    parse_args "$@"
    validate_args
}


main() {
    local risk=
    local intention=

    parse_and_validate_args "$@"

    risk_code="$(risk_code $risk)"
    intention_code="$(intention_code $intention)"

    echo "${risk_code}${space}${intention_code}${space}${message}"
}


main "$@"
