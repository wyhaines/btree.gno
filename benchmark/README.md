To get timings, use the `time` binary (not the shell builtin) with the `-v` flag. This may be

```
/usr/bin/time -v gno run ___
```

The `fastexit` versions all exit immediately after entering the `main()` function. This lets the amount of time required for `gno` to load libraries, parse code, etc... be determined so that it can be subtracted from the runtime of the benchmark, yielding a more accurate timing of code's performance.

Also of note, these benchmarks use the Xorshiftr128+ pseudorandom number generator, which has not yet been merged into the monorepo, because it's vastly faster, with better statistical properties, than the PCG PRNG that is the rand() default. This, in turn, limits how much of the benchmark's performance is influenced by the PRNG performance. So to run these, you'll need to pull that PRNG from the PR or wait until I can rebase the PR once again so that it works with the latest changes to strconv in gnovm master.
