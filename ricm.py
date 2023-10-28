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

def main():
    parser = argparse.ArgumentParser(description="Construct a Git commit message")
    parser.add_argument("-r", "--risk", required=True, choices=["safe", "validated", "risky", "broken"], help="Risk level")
    parser.add_argument("-i", "--intention", required=True, choices=["feature", "bugfix", "refactoring", "documentation"], help="Intention")
    parser.add_argument("message", help="Commit message")

    args = parser.parse_args()

    risk_code_str = risk_code(args.risk)
    intention_code_str = intention_code(args.intention)

    commit_message = f"{risk_code_str} {intention_code_str} {args.message}"
    print(commit_message)

if __name__ == "__main__":
    main()
