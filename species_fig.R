## make a tree of all of the species currently in the codebase
library(phytools)
library(ggtree)
library(tidyverse)

tree<-read.tree("./species.nwk")
species<-tibble(species=tree$tip.label) %>%
  mutate(original=ifelse(gsub("_", " ", species) %in% c("Homo sapiens", "Drosophila melanogaster", "Arabidopsis thaliana", 
                                        "Pongo abelii", "Canis familiaris", "Escherichia coli"), "original", "new"))
ggtree(tree)
