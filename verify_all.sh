#! /bin/bash

verify_sh="$HOME/repos/ApprovalTests.shell/bash/verify.sh"

function verify_fn(){
    bash ${verify_sh} "$*" -d 'meld'
}

echo "Hello world" |  verify_fn -thello-world
ricm -r safe -i refactoring 'Randomness' | verify_fn -tsafe_refactoring
