#!/bin/bash
# FizzBuzz - Behavioral Tests

FIZZBUZZ="../bin/fizzbuzz"

echo "=== FizzBuzz Tests ==="
echo "Testing: $FIZZBUZZ"
echo ""

PASS=0
FAIL=0

# T1: Script exists and is executable
if [[ -x "$FIZZBUZZ" ]]; then
    echo "PASS: T1 - Script exists and is executable"
    ((PASS++))
else
    echo "FAIL: T1 - Script exists and is executable"
    ((FAIL++))
fi

# T2: Outputs "1" for first line
if [[ $(bash "$FIZZBUZZ" 1) == "1" ]]; then
    echo "PASS: T2 - First line is 1"
    ((PASS++))
else
    echo "FAIL: T2 - First line is 1"
    ((FAIL++))
fi

# T3: Outputs "Fizz" for 3
if [[ $(bash "$FIZZBUZZ" 3 | tail -1) == "Fizz" ]]; then
    echo "PASS: T3 - Line 3 is Fizz"
    ((PASS++))
else
    echo "FAIL: T3 - Line 3 is Fizz"
    ((FAIL++))
fi

# T4: Outputs "Buzz" for 5
if [[ $(bash "$FIZZBUZZ" 5 | tail -1) == "Buzz" ]]; then
    echo "PASS: T4 - Line 5 is Buzz"
    ((PASS++))
else
    echo "FAIL: T4 - Line 5 is Buzz"
    ((FAIL++))
fi

# T5: Outputs "FizzBuzz" for 15
if [[ $(bash "$FIZZBUZZ" 15 | tail -1) == "FizzBuzz" ]]; then
    echo "PASS: T5 - Line 15 is FizzBuzz"
    ((PASS++))
else
    echo "FAIL: T5 - Line 15 is FizzBuzz"
    ((FAIL++))
fi

# T6: Full sequence 1-15 correct
expected="1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz"
actual=$(bash "$FIZZBUZZ" 15)
if [[ "$actual" == "$expected" ]]; then
    echo "PASS: T6 - Full sequence 1-15 correct"
    ((PASS++))
else
    echo "FAIL: T6 - Full sequence 1-15 correct"
    ((FAIL++))
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

exit $FAIL
