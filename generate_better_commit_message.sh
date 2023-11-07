#! /bin/bash


export n_th_parent="${1?n-th parent must be specified as first argument}"
export generation_count="${2-1}"

export commit_reference_oldest="HEAD~${n_th_parent}"
export commit_reference_newest="HEAD~$((${n_th_parent} - ${generation_count}))"



(
    set -x;
    git diff --no-prefix --unified=0 "${commit_reference_oldest}" "${commit_reference_newest}"
) 2>&1 | pbcopy
pbpaste


(
    echo "Related git-log messages"

    git log --oneline |
    head -n$(($n_th_parent)) |
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
