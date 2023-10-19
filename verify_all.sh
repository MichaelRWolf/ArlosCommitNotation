#! /bin/bash

verify_sh="$HOME/repos/ApprovalTests.shell/bash/verify.sh"

function verify_fn(){
    bash ${verify_sh} "$*" -d 'meld'
}

# echo "Hello world" |  verify_fn -thello-world
# ricm -r safe -i refactoring 'Randomness'     | verify_fn -tsafe_refactoring
# ricm -r validated -i refactoring 'Message 2' | verify_fn -tvalidated_refactoring
# ricm -r risky -i refactoring 'Message 3'     | verify_fn -trisky_refactoring


for risk in safe validated risky broken
do
    intention="undefined"
    test_name="${risk}_unnamed-intention_by_looping"
    message="Risk/Intention message for ${risk}/${intention}"

    ricm -r $risk "$message" | verify_fn -t${test_name} 
done
