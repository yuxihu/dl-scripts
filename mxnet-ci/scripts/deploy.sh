#!/usr/bin/env bash

nosetests -v $(ls mxnet-build/tests/python/unittest/test_gluon*.py | grep -v data | grep -v model_zoo)

wheel_name=$(ls -t dist | head -n 1)
if [[ (! -z $TRAVIS_TAG) || ( $TRAVIS_EVENT_TYPE == 'cron' ) ]]; then
    if [[ -f dist/$wheel_name ]]; then
        cp ./.pypirc ~/
        n=0
        until [ $n -ge 20 ]; do
            twine upload -r legacy --skip-existing dist/$wheel_name && break
            let n=n+1
        done
    fi
fi
