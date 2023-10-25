#! /bin/bash

verify_sh="$HOME/repos/ApprovalTests.shell/bash/verify.sh"
diff_command="sdiff"
diff_command="meld"

warn() { 
    echo "$@" >&2
}


function verify_fn(){
    bash ${verify_sh} -d "${diff_command}" "$@" 
}

ricm_path=$(PATH=.:$PATH which ricm)


for risk in safe validated risky broken
do
    for intention in feature bugfix refactoring documentation
    do
	test_name="${risk}-${intention}"
	message="Message generated by: ${ricm_path} -r '${risk}'  -i '${intention}'"
	
	${ricm_path} -r "${risk}"  -i "${intention}"  "${message}"
    done
done | verify_fn -tall_risks_all_intentions


{
    ${ricm_path}                        Command line missing -r flag
    warn
    warn

    ${ricm_path} -r risk                Command line missing -i flag
    warn
    warn

    ${ricm_path} -r risk -i refactoring
    warn
    warn
} 2>&1 | verify_fn -t malformed_command_line

{
    echo "There is no help"
    set -xv
} | verify_fn -t help -d meld
