#!/bin/sh

glmark2-es2 --benchmark refract --run-forever > /dev/null &
sleep 1
for i in {1..5};
do
    glmark2-es2 --benchmark refract --run-forever --off-screen > /dev/null &
    sleep 1
done
