Why does VSEARCH perform worse than in Pat’s 2015 PeerJ paper?
================
2021-09-22

``` r
library(glue)
library(here)
library(tidyverse)
theme_set(theme_bw())
```

Pat had MCC’s of \~`0.7` for the MiSeq mouse dataset with VSEARCH DGC.
I’m getting MCC’s of `0.5781`.

## VSEARCH version number

Pat used VSEARCH v1.5.0, I’m using v2.15.2.

I tried re-running my [Snakemake workflow on the mouse data but with
VSEARCH
v1.5.0](https://github.com/SchlossLab/Sovacool_OptiFit_2021/blob/2f39f25fc31980fe3a9a349562486a3f972efc8b/subworkflows/4_vsearch/Snakefile#L40),
and still got the exact same MCC result as before.

## MiSeq data preprocessing

## Silva & RDP versions
