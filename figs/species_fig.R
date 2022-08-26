## make a tree of all of the species currently in the codebase
library(phytools)
library(ggtree)
library(tidyverse)
library(tidytree)
library(ggnewscale)
library(viridisLite)

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
                                          "Anolis carolinensis", "Gasterosteus aculeatus"), "hackathon", 
                           #"new"))) # different color for hackathon and after hackathon
                           "hackathon"))) # don't distinguish between hackathon and after

pdf(file="species_fig.pdf", width=6, height=8, pointsize=10)
ggtree(tree, size=2) %<+% species +
  geom_tiplab(aes(color=original, label=str_wrap(plot_species,15)), 
              lineheight=0.8, fontface='bold.italic', hjust=-.08)+
  ggplot2::xlim(0, 6000) +
#  scale_color_manual(values=c("darkorange3","seagreen","darkblue")) +
  scale_color_manual(values=c("darkorange3","darkblue")) +
  theme(legend.position = "none")

# add number of demographic models, genomic maps, annotations, DFE (as of 25 Aug 2022)
data<-rbind(c("Escherichia coli" ,0,0,0,0),
            c("Streptococcus agalactiae",0,0,0,0),
            c("Aedes aegypti",0,0,0,0),
            c("Anas platyrhynchos",0,0,0,0),
            c("Anolis carolinensis",0,0,0,0),
            c("Anopheles gambiae",1,0,0,0),
            c("Apis mellifera",0,0,0,0),
            c("Arabidopsis thaliana",3,1,2,0),
            c("Bos taurus",1,0,0,0),
            c("Caenorhabditis elegans",1,0,0,0),
            c("Canis familiaris",0,1,0,0),
            c("Chlamydomonas reinhardtii",0,0,0,0),
            c("Drosophila melanogaster",2,2,2,2),
            c("Drosophila sechellia",0,0,0,0),
            c("Escherichia coli",0,0,0,0),
            c("Gasterosteus aculeatus",0,0,0,0),
            c("Helianthus annuus",0,0,0,0),
            c("Heliconius melpomene",0,0,0,0),
            c("Homo sapiens",13,30,2,2),
            c("Pan troglodytes",1,0,0,0),
            c("Papio anubis",1,1,0,0),
            c("Pongo abelii",1,2,0,0),
            c("Streptococcus agalactiae",0,0,0,0))
colnames(data)<-c("species","demog","map","annotations","DFE")
species<-species %>%
  full_join(data,copy=TRUE) %>%
  mutate(demog=as.numeric(demog),
         map=as.numeric(map),
         annotations=as.numeric(annotations),
         DFE=as.numeric(DFE)) %>%
  mutate(demog=ifelse(demog==0,NA,demog),
         map=ifelse(map==0,NA,map))

tree_plot <- ggtree(tree, size=2) %<+% species +
  geom_tiplab(aes(color=original, label=str_wrap(plot_species,15)), 
              lineheight=0.8, fontface='bold.italic', hjust=-.08)+
  ggplot2::xlim(0, 6000) +
#  scale_color_manual(values=c("darkorange3","seagreen","darkblue"), guide="none") +
  scale_color_manual(values=c("darkorange3","darkblue"), guide="none") +
  new_scale_color()

species_long <-species %>% 
  pivot_longer(cols=c(demog,map,annotations,DFE)) %>%
  mutate(name=ifelse(name=="demog","demographic\nmodels",
                     ifelse(name=="map","genetic\nmaps",
                            name)),
         name=factor(name,levels=c("demographic\nmodels","genetic\nmaps","annotations","DFE")))
tree_plot +
  geom_fruit(data=species_long,
             geom=geom_tile,
             aes(y=species,x=name,fill=value),
             pwidth=.3,
             offset=0.22,
             axis.params=list(
               axis="x", # add axis text of the layer.
               text.angle=90, # the text angle of x-axis.
               text.size=3,
               hjust=1,
               ),  # adjust the horizontal position of text of axis.
             alpha=0,
             color="grey"
             ) +
   geom_text(aes(label = demog),nudge_x = 1900) +
   geom_text(aes(label = map), nudge_x = 2325) +
   geom_text(aes(label = annotations), nudge_x = 2750) +
   geom_text(aes(label = DFE), nudge_x = 3175) +
   ggplot2::xlim(0, 8000) +
   ggplot2::ylim(-1.5,21.5) 

#ggsave("./species_fig_temp1.png",height=9,width=9)

tree_plot +
  geom_fruit(data=species_long %>% mutate(value=ifelse(value==0,0,1), value=factor(value)),
             geom=geom_point,
             aes(y=species,x=name,color=name,alpha=value),
             pwidth=.3,
             offset=0.22,
             axis.params=list(
               axis="x", # add axis text of the layer.
               text.angle=90, # the text angle of x-axis.
               text.size=3,
               hjust=1
             ),  # adjust the horizontal position of text of axis.
             size=4
  ) +
  scale_alpha_discrete(range=c(0,1)) +
  ggplot2::xlim(0, 8000) +
  ggplot2::ylim(-1.5,21.5)

#ggsave("./species_fig_temp2.png",height=9,width=9)

tree_plot +
  geom_fruit(data=species_long %>% filter(name!="DFE", name!="annotations") %>% mutate(name=droplevels(name)), #%>% mutate(value=ifelse(value==0,0,1), value=factor(value)),
             geom=geom_point,
             aes(y=species,x=name,color=name,alpha=log(value)),
             pwidth=.15,
             offset=0.22,
             axis.params=list(
               axis="x", # add axis text of the layer.
               text.angle=90, # the text angle of x-axis.
               text.size=3,
               hjust=1
             ),  # adjust the horizontal position of text of axis.
             size=4
  ) +
  ggplot2::xlim(0, 8000) +
  ggplot2::ylim(-1.5,21.5)

#ggsave("./species_fig_temp3.png",height=9,width=9)

tree_plot +
  geom_fruit(data=species_long %>% filter(name!="DFE", name!="annotations") %>% mutate(name=droplevels(name)), #%>% mutate(value=ifelse(value==0,0,1), value=factor(value)),
             geom=geom_point,
             aes(y=species,x=name,color=log(value)),
             pwidth=.15,
             offset=0.22,
             axis.params=list(
               axis="x", # add axis text of the layer.
               text.angle=90, # the text angle of x-axis.
               text.size=3,
               hjust=1
             ),  # adjust the horizontal position of text of axis.
             size=4
  ) +
  ggplot2::xlim(0, 8000) +
  ggplot2::ylim(-1.5,21.5)

#ggsave("./species_fig_temp4.png",height=9,width=9)

tree_plot +
  geom_fruit(data=species_long %>% filter(name!="DFE", name!="annotations") %>% mutate(name=droplevels(name)), #%>% mutate(value=ifelse(value==0,0,1), value=factor(value)),
             geom=geom_point,
             aes(y=species,x=name,color=log(value)),
             pwidth=.15,
             offset=0.22,
             axis.params=list(
               axis="x", # add axis text of the layer.
               text.angle=90, # the text angle of x-axis.
               text.size=3,
               hjust=1
             ),  # adjust the horizontal position of text of axis.
             size=7,
             alpha=.7
  ) +
   scale_color_viridis_c(na.value="white", option="C", name="count") +
   geom_text( aes(label = demog), nudge_x = 1875, family="bold") +
   geom_text(aes(label = map), nudge_x = 2525, family="bold") +
  ggplot2::xlim(0, 8000) +
  ggplot2::ylim(-1.5,21.5)

#ggsave("./species_fig_temp5.png",height=9,width=9)

tree_plot +
  geom_fruit(data=species_long %>% filter(name!="DFE", name!="annotations") %>% 
               mutate(name=droplevels(name)) %>%
               mutate(value=ifelse(value==1,1,ifelse(value>1,">1",NA)),
                      value=factor(value,levels=c("1",">1"))), 
             geom=geom_point,
             aes(y=species,x=name,color=value),
             pwidth=.15,
             offset=0.22,
             axis.params=list(
               axis="x", # add axis text of the layer.
               text.angle=90, # the text angle of x-axis.
               text.size=3,
               hjust=1
             ),  # adjust the horizontal position of text of axis.
             size=7,
             alpha=.7
  ) +
  scale_color_manual(name="count", na.value="white", values = c("grey","black")) +
  ggplot2::xlim(0, 8000) +
  ggplot2::ylim(-1.5,21.5)

ggsave("./species_fig_temp6.png",height=9,width=9)

# increase size of column labels, angle, remove "NA" in legend - do this outside R because ggtree doesn't want to
