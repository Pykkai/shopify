<!-- Copyright (C) 2026 Brad Shapcott brad@shapcott.com brash@pyyk.ai -->

# Application Starter

Specify the application in this markdown file, then run ***./bin/starter.sh***

# FizzBuzz

- This application should replace the Hello World implementation.
- The application will receive a single argument on the command line.
- This argument must be a positive integer.
- Otherwise an error message is displayed along with usage.

## Specification

Given an integer n, return a string array answer (1-indexed) where:

answer[i] == "FizzBuzz" if i is divisible by 3 and 5.
answer[i] == "Fizz" if i is divisible by 3.
answer[i] == "Buzz" if i is divisible by 5.
answer[i] == i (as a string) if none of the above conditions are true.
 
## Example 1:

Input: n = 3
Output: ["1","2","Fizz"]

## Example 2:

Input: n = 5
Output: ["1","2","Fizz","4","Buzz"]

## Example 3:

Input: n = 15
Output: ["1","2","Fizz","4","Buzz","Fizz","7","8","Fizz","Buzz","11","Fizz","13","14","FizzBuzz"]
 

## Constraints:

1 <= n <= 104.
