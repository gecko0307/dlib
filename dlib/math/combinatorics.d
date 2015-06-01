module dlib.math.combinatorics;

import std.traits;
import std.functional;

ulong factorial(ulong n) @safe nothrow {
    alias mfac = memoize!factorial;

    return n * mfac(n - 1);
}

unittest {
    assert(factorial(10) == 3_628_800);

    int n = 5;
    assert(n.factorial == 5.factorial && 5.factorial == 120);
}

ulong combinations(ulong objects, ulong taken) @safe nothrow {
    return objects.factorial / (taken.factorial * (objects.factorial - taken.factorial));
}

alias C = combinations;
alias choose = combinations;

ulong permutations(ulong objects, ulong taken) {
    return objects.factorial / (taken.factorial * (objects - taken));
}

alias P = permutations;

unittest {
    assert(5.choose(2) == 10);
    assert(10.P(2) == 90);
}
