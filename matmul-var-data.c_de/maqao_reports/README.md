# MAQAO Loop Analysis Guide (matmul-var-data.c_de)

This guide documents the exact command sequence used to analyze loops in `wrapper` and how MAQAO loop IDs map back to [`core.c`](/home/sarram02/sido/matmul-var-data.c_de/core.c).

## Binary analyzed

- `/home/sarram02/sido/matmul-var-data.c_de/wrapper`

## MAQAO binary

- `/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao`

## Sequence of commands

1. Build and run matmul wrapper (optional but recommended first):
```bash
/home/sarram02/sido/matmul-var-data.c_de/build_and_run_matmul.sh
```

2. List loops and MAQAO IDs:
```bash
/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao analyze -ll --show-extra-info /home/sarram02/sido/matmul-var-data.c_de/wrapper
```
For assembly view
```bash
/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao analyze -li --show-extra-info /home/sarram02/sido/matmul-var-data.c_de/wrapper
```

3. Analyze all loops in function `core`:
```bash
/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao cqa --fct-loops=core /home/sarram02/sido/matmul-var-data.c_de/wrapper
```

4. Analyze a specific loop by ID:
```bash
/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao cqa conf=all --loop=<ID> /home/sarram02/sido/matmul-var-data.c_de/wrapper
```

Examples:
```bash
/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao cqa conf=all --loop=4 /home/sarram02/sido/matmul-var-data.c_de/wrapper
/home/sarram02/maqao/maqao.aarch64.2025.1.0/bin/maqao cqa conf=all --loop=1 /home/sarram02/sido/matmul-var-data.c_de/wrapper
```

Note: In this MAQAO version, the accepted option is `--loop` (singular), not `--loops`.

## Generated reports in this folder

- `cqa_core.txt`      : all loops under function `core`
- `cqa_loop4.txt`     : loop ID 4 report
- `cqa_loop1.txt`     : loop ID 1 report (innermost loop)

## Loop mapping to core.c

Source loop nest in [`core.c`](/home/sarram02/sido/matmul-var-data.c_de/core.c):

```c
for (int m = 0; m <= M - 1; ++m) {      // line 17
  for (int n = 0; n <= N - 1; ++n) {    // line 18
    for (int k = 0; k <= K - 1; ++k) {  // line 19
      c[m][n] = c[m][n] + a[m][k] * b[k][n]; // line 20
    }
  }
}
```

MAQAO IDs observed for `core` from `analyze -ll --show-extra-info`:

- `loop #4` (depth 0): outer/top-level loop region for the full nest in `core` (`core.c:15-25`)
- `loop #1` (depth 4): innermost compute loop (`k` loop, `core.c:19-20`)
- `loop #0`, `#3`, `#2`: intermediate nested binary-loop levels reported by MAQAO for the same source nest (`core.c:15-20`)

Practical usage:

- Use `--loop=1` to focus on optimization of the innermost arithmetic loop.
- Use `--loop=4` to analyze the outer region/self-part behavior of the whole nest.
