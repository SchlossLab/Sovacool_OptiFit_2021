devtools::load_all("../ggraph")
library(cowplot)
library(glue)
library(gridExtra)
library(ggtext)
library(here)
library(patchwork)
library(reticulate)
library(tidygraph)
library(tidyverse)
set.seed(20200308)
# use_python('/usr/local/bin/python3')
source_python(here("code", "py", "algorithm_diagram.py"))
optifit <- create_optifit()
optifit_iters <- optifit$iterate %>%
  lapply(function(x) {
    return(list(
      nodes = x[["nodes"]] %>% py_to_r(),
      edges = x[["edges"]] %>% py_to_r() %>%
        bind_rows(data.frame(from = 1, to = 1, mcc = NA)) %>%
        mutate(
          is_loop = from == to,
          loop_dir = ifelse(from == 1, 270, 90)
        )
    ))
  })

plot_optifit_graph <- function(graph, title = "",
                               hide_loops = FALSE) {
  loop_dir <- 90
  loop_color <- ifelse(hide_loops, "white", "black")
  create_layout(graph, "linear", sort.by = id) %>%
    ggraph() +
    geom_edge_arc(aes(
      label = mcc,
      start_cap = label_rect(node1.name),
      end_cap = label_rect(node2.name,
        padding = margin(1, 1, 2.8, 1, "mm")
      )
    ),
    arrow = arrow(
      length = unit(3, "mm"),
      angle = 35,
      type = "closed"
    ),
    edge_colour = "gray",
    angle_calc = "along",
    label_dodge = unit(-2, "mm")
    ) +
    geom_edge_loop(aes(
      span = 1,
      direction = loop_dir,
      strength = 0.5,
      color = is_loop
    )) +
    geom_node_label(aes(label = name)) +
    scale_edge_color_manual(values = c(loop_color)) +
    labs(title = title) +
    theme_void() +
    theme(
      plot.margin = unit(x = c(0, 0, 0, 0), units = "pt"),
      legend.position = "none"
    )
}

i <- 0
optifit_graphs <- lapply(optifit_iters, function(x) {
  i <<- i + 1
  tbl_graph(nodes = x$nodes, edges = x$edges) %>%
    plot_optifit_graph(
      title = glue("{i}. MCC = {x$edges %>% filter(is_loop) %>% pull(mcc)}"),
      hide_loops = TRUE
    )
})


base_color <- "#000000"
ref_color <- "#D95F02"
query_color <- "#1B9E77"
ref_seqs <- LETTERS[1:17]
query_seqs <- LETTERS[23:26]

dist_dat <- get_dists() %>%
  arrange(seq1, seq2) %>%
  mutate(
    color1 = ifelse(seq1 %in% ref_seqs, ref_color, query_color),
    color2 = ifelse(seq2 %in% ref_seqs, ref_color, query_color),
  )
dist_dat[["color3"]] <- rep.int("black", nrow(dist_dat))
dist_dat[["dist"]] <- runif(nrow(dist_dat), 1.0, 2.9) %>%
  format(digits = 2) %>%
  as.character()
table_colors <- dist_dat %>%
  select(color1, color2, color3) %>%
  as.matrix() %>%
  t()

table_plot <- plot_grid(ggdraw() +
  draw_label("0. List of sequence pairs within the distance threshold",
    x = 0,
    hjust = 0
  ) +
  theme(plot.margin = margin(5, 0, 5, 0)),
tableGrob(dist_dat %>%
  select(seq1, seq2, dist) %>%
  rename(
    `% distance` = dist,
    ` ` = seq1,
    `  ` = seq2
  ) %>%
  t(),
theme = ttheme_default(
  base_size = 10,
  padding = unit(c(4, 4), "pt"),
  core = list(
    fg_params = list(col = table_colors),
    bg_params = list(col = "white")
  ),
  rowhead = list(bg_params = list(col = NA)),
  colhead = list(bg_params = list(col = NA))
)
),
ncol = 1, rel_heights = c(0.1, 1)
)

plot_diagram <- table_plot /
  optifit_graphs +
  plot_layout(heights = c(0.75, 1, 1.5, 1, 0.3))


dims <- eval(parse(text = snakemake@params[["dim"]]))
ggsave(snakemake@output[["tiff"]],
  device = "tiff", dpi = 300,
  width = dims[1], height = dims[2], units = "in"
)
