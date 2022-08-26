## make a tree of all of the species currently in the codebase
library(phytools)
library(ggtree)
library(tidyverse)
library(tidytree)

tree <- read.tree("species.nwk")
tree$tip.label <- gsub("_"," ",tree$tip.label)
tree$tip.label[which(tree$tip.label=="Canis lupus")] <- "Canis familiaris"

species <- tibble(species=tree$tip.label) %>%
  mutate(plot_species = gsub("_", " ", species),
    original=ifelse(plot_species %in% c("Homo sapiens", "Drosophila melanogaster", "Arabidopsis thaliana", 
                                        "Pongo abelii", "Canis familiaris", "Escherichia coli"), "original", 
                    ifelse(plot_species %in% c("Bos taurus","Anas platyrhynchos", "Aedes aegypti", "Chlamydomonas reinhardtii",
                                          "Apis mellifera", "Heliconius melpomene", "Caenorhabditis elegans",
                                          "Streptococcus agalactiae", "Drosophila sechellia", "Papio anubis",
                                          "Anolis carolinensis", "Gasterosteus aculeatus"), "hackathon", "new")))

pdf(file="species_fig.pdf", width=6, height=8, pointsize=10)
ggtree(tree, size=2) %<+% species +
  geom_tiplab(aes(color=original, label=str_wrap(plot_species,15)), 
              lineheight=0.8, fontface='bold.italic', hjust=-.08)+
  ggplot2::xlim(0, 6000) +
  scale_color_manual(values=c("darkorange3","seagreen","darkblue")) +
  theme(legend.position = "none")
dev.off()
  
