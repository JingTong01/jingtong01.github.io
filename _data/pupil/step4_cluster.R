library(tidyverse)
library(exchangr)
library(clusterperm)

time_data <- read.table("D:/0eye_tracking/1data_formal_exp1/3_Prepara_for_cluster/stp3_allsub.txt",
                        header = TRUE,
                        sep = "\t")



cur2 <- aov_by_bin(
  time_data,
  time,
  pupil ~ condition + Error(subID)
)

orig <- detect_clusters_by_effect(
  cur2,
  effect,
  time,
  stat,
  p
)

dat_prec <- time_data %>%
  nest(data = -c(subID, condition))

nhds_prec <- cluster_nhds(
  1000,
  dat_prec,
  time,
  pupil ~ condition + Error(subid),
  shuffle_each,
  condition,
  subID
)

results_prec <- pvalues(orig, nhds_prec)

write.table(results_prec,
            file = "pupil_cluster_results.csv")

cluster_lim <- c(results_prec$b0[1], results_prec$b1[1])

write.table(cluster_lim,
            file = "pupil_cluster_limits.csv",
            col.names = FALSE)

