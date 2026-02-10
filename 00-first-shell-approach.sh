#!/bin/bash
# My very first script - kept for its sentimental value.

echo "test";
target_user="$1";

stdin_test=""; 
stdout_test="";
touch stdout;
touch stderr;
ls -l | grep " $stdin_test" | grep "$stdout_test" 2>stderr



echo $stdin_test

echo "Search about: $target_user";
touch target_users;
grep "$target_user" /etc/passwd >>target_users 2>stderr
 
