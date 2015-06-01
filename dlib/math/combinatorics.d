//          Copyright Nick Papanastasiou 2015.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

/// Authors: Nick Papanastasiou

module dlib.math.combinatorics;

import std.functional : memoize;
import std.algorithm : iota, reduce;

/// Returns the factorial of n
ulong factorial(ulong n) @safe nothrow {
    if(n <= 1) {
        return 1;
    }
    alias mfac = memoize!factorial;

    return n * mfac(n - 1);
}

unittest {
    assert(factorial(10) == 3_628_800);

    int n = 5;
    assert(n.factorial == 5.factorial && 5.factorial == 120);
}

/// Computes the double factorial of n: n * (n - 2) * (n - 4) * ... 1
ulong doubleFactorial(ulong n) {
    if(n <= 1) {
        return 1;
    }

    alias mDoubleFac = memoize!doubleFactorial;

    return n * doubleFactorial(n - 2);
}

/++
+ Compute the number of combinations of `objects` types of items
+ when considered `taken` at a time, where order is ignored
+/
ulong combinations(ulong objects, ulong taken) @safe nothrow {
    return objects.factorial / (taken.factorial * (objects.factorial - taken.factorial));
}

/// Common vernacular for combinations
alias C = combinations;

/// Ditto
alias choose = combinations;

/++
+  Compute the number of permutations of `objects` types of items
+ when considered `taken` at a time, where order is considered
+/
ulong permutations(ulong objects, ulong taken) @safe nothrow {
    return objects.factorial / (taken.factorial * (objects - taken));
}

// Common vernacular for permutations
alias P = permutations;

unittest {
    assert(5.choose(2) == 10);
    assert(10.P(2) == 90);
}

/// Computes the nth catalan number
ulong catalan(ulong n)
in {
    assert(n >= 0);
} body {
    if(n <= 1) {
        return 1;
    } else {
        alias mcat = memoize!catalan;
    
        return (2 * (2 * n - 1) / n + 1) * mcat(n - 1);

    }
}

unittest {
    assert(catalan(1) == 1);
    assert(catalan(2) == 1);
    assert(catalan(3) == 2);
    assert(catalan(4) == 5);
}
