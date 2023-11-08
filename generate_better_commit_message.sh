#! /bin/bash

set -xv


export n_th_parent=0
export generation_count=1

if [[ "${1}" ]]; then
    n_th_parent="${1}"

    if [[ "${2}" ]]; then
	generation_count="${2}"
    fi
fi


export commit_reference_newest
export commit_reference_oldest

if (( ${n_th_parent} == 0 )); then
    commit_reference_newest=""
    commit_reference_oldest=""
else 
    commit_reference_newest="HEAD~${n_th_parent}"
    commit_reference_oldest="HEAD~$((${n_th_parent} + ${generation_count}))"
fi


(
    set -x;
    # Note:  No double-quotes below to avoid sending empty references (i.e. n_th_prent == 0)
    git diff --no-prefix --unified=0 ${commit_reference_newest} ${commit_reference_oldest}
) 2>&1 | pbcopy
pbpaste


(
    echo "Related git-log messages"

    git log --oneline |
        head -n$(($n_th_parent + $generation_count - 1)) |
	nl |
	tail -n"${generation_count}"
) >&2

# 
# echo '  VVVV'
# echo '  ^^^^' 
# git log --oneline | nl | head -n$(($n_th_parent + 3)) | tail -n 7
# 



display_gpt_instructions(){
    cat <<GPT_INSTRUCTIONS
Here's how I want to work together for a while.  I will pass you a git-diff (as above) for 2 consecutive 'git commit' commands.  I would like you to review the diff and generate a description of the changes.  Specify it in a format that would have been helpful for that commit.  This MUST include a short (approximately 50 characters) description of the change.  If the change is simple (automated) refactoring, that should be sufficient.  Try to infer the refactoring, and create a message like this
Extract variable: width
Extract method: get_width()
Inline method: calculate_area()
The message should contain both the name of the refactoring, and also the identifier (i.e. method, variable, subroutine, class).  Specify the new identifier, not the old one.

Do you understand?  If not, ask me clarifying questions.

ChatGPT
GPT_INSTRUCTIONS
}
