# Adapted from: https://github.com/SchlossLab/Westcott_OptiClust_mSphere_2017/blob/master/code/marine.R
# Creates a .names file to facilitate data processing by mothur

make_files_file <- function() {
  sample_map <- c(
    "SRR3085688" = "JLB",
    "SRR3085689" = "ARD",
    "SRR3085690" = "CJ",
    "SRR3085691" = "TBON",
    "SRR3085692" = "CJ2",
    "SRR3085693" = "LBK",
    "SRR3085694" = "FWC",
    "SRR3085695" = "CJ",
    "SRR3085696" = "TBON",
    "SRR3085697" = "CJ2",
    "SRR3085698" = "LBK",
    "SRR3085699" = "JLB",
    "SRR3085700" = "ARD",
    "SRR3085701" = "FWC"
  )

  read_1 <- list.files(path = "data/marine/raw/", pattern = "*1.fastq")
  read_2 <- gsub("_1", "_2", read_1)

  stub <- gsub("_1.*", "", read_1)
  sample <- sample_map[stub]

  files <- data.frame(sample, read_1, read_2)
  write.table(files, "data/marine/marine.files", row.names = F, col.names = F, quote = F, sep = "\t")
}

make_files_file()
