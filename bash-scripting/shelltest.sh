
## Chapter One: Basics 7
#!/bin/bash
read -p "Take a moment to take it all in. You're about to make the best GIT decision you've ever made by using this script"
read -p "Press Enter when you're ready.
Goodluck!"
echo Hello World! 
pwd
echo $SHELL
echo You can also run the script file using _bash filename_
echo chmod u+x filename gives only the owner access to run the script

## Chapter Two: Using Variables
FIRST_NAME=Olorunshogo
MIDDLE_NAME=Moses
LAST_NAME=BAMTEFA

echo My name is $FIRST_NAME $MIDDLENAME $LAST_NAME

## Chapter 3 - Positional argument
echo Hello $1 $2 $3.

## If, Elif, and Else
read -p "What is your ifElifElse name?" IF_ELIF_ELSE_NAME

if [ $IF_ELIF_ELSE_NAME = Olorunshogo ]; then
    echo "Oh, you're the boss here. Welcome!"
elif [ $IF_ELIF_ELSE_NAME = help ]; then
    echo "Just emter your username, duh!"
else 
    echo "I don't know who you are. But you're not the boss of me!"
fi
