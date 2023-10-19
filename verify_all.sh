#! /bin/bash

verify_sh="$HOME/repos/ApprovalTests.shell/bash/verify.sh"

function verify_fn(){
    bash ${verify_sh} "$*" -d 'meld'
}


for risk in safe validated risky broken
do
    intention="undefined"
    test_name="${risk}_unnamed-intention_by_looping"
    message="Risk/Intention message for ${risk}/${intention}"

    ricm -r $risk "$message" | verify_fn -t${test_name} 
done
