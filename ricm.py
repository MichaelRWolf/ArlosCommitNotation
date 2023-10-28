#! /Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10

import argparse


def risk_code(risk):
    risk_mapping = {
        'safe': '.',
        'validated': '^',
        'risky': '!',
        'broken': '@',
    }
    return risk_mapping.get(risk, ' ')


def intention_code(intention):
    intention_mapping = {
        'feature': 'f',
        'bugfix': 'b',
        'refactoring': 'r',
        'documentation': 'd',
    }
    return intention_mapping.get(intention, ' ')


def do_ricm_help():
    ricm_help_message = """
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
"""
    print(ricm_help_message)


def main():
    # Check _only_ for --HELP_FOR_RICM flag then exit early.  
    # This prevents this 'required' arguments from triggering error
    h_parser = argparse.ArgumentParser(description="Just look for -H argument", add_help=False, exit_on_error=False)
    h_parser.add_argument("-H", "--HELP_FOR_RICM", action='store_true', help="N/A -- h_parser specified  add_help=False")

    h_args, h_unknown = h_parser.parse_known_args()
    if h_args.HELP_FOR_RICM:
        do_ricm_help()
        exit(0)
        
    # Check for ALL command line arguments.
    # Even though '-H' will never be detected here, add it so that usage/help messages appear correct
    parser = argparse.ArgumentParser(description="Construct a Git commit message", exit_on_error=False)
    parser.add_argument("-H", "--HELP_FOR_RICM", action='store_true', help="display RICM (FKA ArlosChangeNotation) values for --risk and --intention")
    parser.add_argument("-r", "--risk", choices=["safe", "validated", "risky", "broken"], help="Risk level", required=True)
    parser.add_argument("-i", "--intention", choices=["feature", "bugfix", "refactoring", "documentation"], help="Intention", required=True)
    parser.add_argument("message", help="Commit message")

    args = parser.parse_args()
    if args.HELP_FOR_RICM:
        print("Internal logic error.  Option should be detected on previous ArgumentParser")
        exit(3)
        
    both_risk_and_intention_args_provided = args.risk and args.intention
    if not both_risk_and_intention_args_provided :
        parser.print_usage()
        print("error: have not provided BOTH arguments:  --risk and --intention")
        exit(2)

    if not args.message:
        parser.print_usage()
        print("error: the following arguments are required: message")
        exit(2)

    risk_code_str = risk_code(args.risk)
    intention_code_str = intention_code(args.intention)

    commit_message = f"{risk_code_str} {intention_code_str} {args.message}"
    print(commit_message)

if __name__ == "__main__":
    main()
