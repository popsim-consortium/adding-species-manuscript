## make a tree of all of the species currently in the codebase
library(phytools)
library(ggtree)
library(tidyverse)
library(tidytree)

tree<-read.tree("./species.nwk")
tree$tip.label<-gsub("_"," ",tree$tip.label)
species<-tibble(species=tree$tip.label) %>%
  mutate(species = gsub("_", " ", species),
    original=ifelse(species %in% c("Homo sapiens", "Drosophila melanogaster", "Arabidopsis thaliana", 
                                        "Pongo abelii", "Canis familiaris", "Escherichia coli"), "original", "new"))

ggtree(tree, size=2) %<+% species +
  geom_tiplab(aes(color=original), fontface='bold.italic', hjust=-.08)+
  ggplot2::xlim(0, 6000) +
  scale_color_manual(values=c("darkorange3","darkblue")) +
  theme(legend.position = "none")
  
ggsave("./species_fig.png")
