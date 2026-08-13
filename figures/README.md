# Analysis figures

The four-year (2023–2026) analysis figures previously here were **withdrawn on
2026-08-13** and removed.

They were generated from DIA-NN searches that did not pin the **scan window**. DIA-NN's
parallel workflow reuses per-file `.quant` files between steps, and DIA-NN warns that
combining that reuse with automatic scan-window optimisation gives results differing from
the analysis that produced those files. Checking the logs confirmed it: the window took 15
different values across 399 runs, and for 21% of runs it differed between the pass that
produced the `.quant` and the pass that reused it.

Corrected searches are running with the window pinned. Figures will be republished here
once the analysis is rebuilt.

Nothing that was previously in this folder should be used or cited.
