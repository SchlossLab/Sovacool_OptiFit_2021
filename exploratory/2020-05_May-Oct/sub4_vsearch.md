VSEARCH clustering
================
Oct. 2020

``` r
library(cowplot)
library(ggtext)
library(glue)
library(here)
library(knitr)
library(tidyverse)
theme_set(theme_classic())
color_palette <- RColorBrewer::brewer.pal(4, "Dark2")
dataset_colors <- c(
  human = color_palette[[3]],
  marine = color_palette[[1]],
  mouse = color_palette[[4]],
  soil = color_palette[[2]]
)
set.seed(2018)

optifit <- c('subworkflows/2_fit_reference_db/results/sensspec.tsv',
             'subworkflows/2_fit_reference_db/results/benchmarks.tsv',
             'subworkflows/2_fit_reference_db/results/fraction_reads_mapped.tsv'
             ) %>% 
  here() %>% 
  map(read_tsv) %>%
  reduce(full_join) 
opticlust <- c('subworkflows/1_prep_samples/results/sensspec.tsv',
               'subworkflows/1_prep_samples/results/benchmarks.tsv') %>% 
  here() %>% 
  map(read_tsv) %>% 
  reduce(full_join) 
vsearch <- read_tsv(here('subworkflows/4_vsearch/results/vsearch_results.tsv'))

dat <- bind_rows(optifit, opticlust) %>% 
  mutate(tool = "mothur") %>% 
  bind_rows(vsearch) %>% 
  mutate(mem_mb = max_rss,
         mem_gb = mem_mb / 1024,
         sec = s) %>% 
  filter(ref %in% c('gg', NA))
```

Preliminary results with just the soil dataset vs greengenes below. Will
expand to include more datasets later.

``` r
dat_filt <- dat %>% filter(ref %in% c('gg', NA), 
                           region %in% c('bact_v4', NA),
                           dataset == 'soil') %>% 
  select(dataset, ref, region, tool, method, mcc, sec, mem_gb, numotus, fraction_mapped) %>% 
  mutate(tool_method = glue("{tool}_{method}"))


dat_filt %>% pivot_longer(c(mcc, sec, mem_gb), names_to = 'metric') %>% 
  ggplot(aes(x = method, y = value, color = tool)) +
  geom_boxplot() +
  facet_wrap('metric', scales = 'free') + 
  labs(caption = "For reference clustering, the soil dataset was fit to the greengenes db.") +
  theme(axis.title = element_blank())
```

![](figures/vsearch-soil-only-1.png)<!-- -->

## OTU Quality

``` r
mcc <- dat %>% ggplot(aes(x = method, y = mcc, color = tool)) +
  geom_boxplot() +
  facet_wrap('dataset', ncol = 1) +
  ylim(0, 1) + 
  labs(x = '')
mcc
```

![](figures/vsearch_mcc-1.png)<!-- -->

## Performance

``` r
sec <- dat %>% ggplot(aes(x = method, y = sec, color = tool)) +
  geom_boxplot() +
  facet_wrap('dataset', scales = 'free', ncol = 1)  +
  labs(x = '')
sec
```

![](figures/vsearch_runtime-1.png)<!-- -->

``` r
mem <- dat %>% ggplot(aes(x = method, y = mem_gb, color = tool)) +
  geom_boxplot() +
  facet_wrap('dataset', scales = 'free', ncol = 1)  +
  labs(x = '')
mem
```

![](figures/vsearch_runtime-2.png)<!-- -->

## Fraction reads mapped during closed-reference clustering

``` r
dat %>% filter(method == 'closed') %>% 
  ggplot(aes(x = method, y = fraction_mapped, color = tool)) +
  geom_boxplot() +
  facet_wrap('dataset') +
  ylim(0, 1) +
  labs(caption = 'Sequences were aligned to the greengenes database.')
```

![](figures/vsearch_fraction-1.png)<!-- -->

## All metrics summarized on one plot

``` r
dat %>% pivot_longer(c(mcc, sec, mem_gb), names_to = 'metric') %>% 
  ggplot(aes(x = method, y = value, color = tool)) +
  geom_boxplot() +
  facet_wrap(dataset ~ metric, scales = 'free', ncol = 3, nrow = 4) + 
  labs(caption = "For reference clustering, the soil dataset was fit to the greengenes db.") +
  theme(axis.title = element_blank())
```

![](figures/vsearch_summary-1.png)<!-- -->

``` r
legend <- get_legend(mcc)
pgrid <- plot_grid(mcc + theme(legend.position = 'none'), 
          sec + theme(legend.position = 'none'), 
          mem + theme(legend.position = 'none'), 
          align = 'h', nrow = 1)
plot_grid(pgrid, legend, rel_widths = c(3, .4))
```

![](figures/vsearch_cowplot-1.png)<!-- -->
