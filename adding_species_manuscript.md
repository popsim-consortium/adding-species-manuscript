---
title: ' Adding species to stdpopsim '
author:
- name: null
  affiliation: null
- name: null
  affiliation: null
- name: null
  affiliation: null
output:
  pdf_document:
    fig_caption: yes
    keep_tex: yes
    number_sections: yes
  word_document: default
bibliography: references.bib
keywords: ''
geometry: margin=1in
fontsize: 11pt
layout: review
preamble: |
  \usepackage[nomarkers]{endfloat}
  \linenumbers
  \usepackage{setspace}
  \doublespacing
---

**Abstract:**

Simulation is one of the key tools in population genetics, and
is useful for both methods development and empirical research, including
providing training data and null models for hypothesis testing.
As more and more information about many species becomes available
and more detailed models estimated,
the need for more and more detailed simulations of a wide range
of species becomes more acute. Population genetic data is being generated
faster than ever before, and there are currently efforts underway to
sequence all vertebrate species (Vertabrate Genomes Project) and 10,000 plant species
(10KP), among many others, that will facilitate an avalanche of population genetic
data in non-model organisms as well. 
The recently developed stdpopsim tool makes it easy to simulate
complex models using up to date information for a number of
well characterised and model organisms such as humans, chimpanzees, and *Arabadopsis*,
but provides little help in enabling simulations for less
well characterised organisms.
Many users wish to simulate their study organism, but do not
know what information is required in order to do this and
where this information might be found.
In this paper we discuss the elements of a population genetic
simulation model, and the input data required in order to make
them a realistic characterisation of a particular species. We also discuss
common pitfalls and major considerations in choosing this input data.
Further, we discuss how such information can be integrated into the
stdpopsim catalog to simplify future simulations of the same species, 
and some of the lessons learned from a
recent effort to expand the range of supported species.
Thus, this paper serves as a tutorial in both how to
assemble the data that is required in order to simulate
a species, and how this information can be incorporated
into the stdpopsim catalog in order to make it available
to everyone.


# Introduction

Dramatic reductions in sequencing costs are enabling unprecedented genomic data to be generated for a huge variety of species (@Ellegren2014). Ongoing efforts to systematically sequence a wide variety of species (eg. Vertebrate Genomes Project (@Rhie2021), 10KP (10,000 Plants) Genome Project (@Cheng2018)) are in turn facilitating enormous increases in population-level genomic data for new model and non-model species.
Correspondingly, methods for inferring demographic history and natural selection from such data are flourishing (@Beichman2018).
Past methods development has typically focused on model organisms such as *Drosophila* or, piggybacking on medical genomics, humans.
But new methods are being developed, and old methods enhanced, to model population characteristics that are key to many organisms but less important in models of common model organisms, such as inbreeding (@Blischak2020), skewed offspring distributions (@Montano2016), or selfing (eg. as implemented in Demes (@Gower2022)).
Models inferred from these tools are an important community resource, but reuse of such models can be arduous and error-prone (@Ragsdale2020).

Simulations from population genomic models have many uses, both for methods development and empirical research.
They provide training data for inference methods based on machine learning (@Schrider2018) or Approximate Bayesian Computation (@Csillery2010).
They can also serve as baselines for further analyses; for example, models incorporating demographic history serve as null models in selection analyses (@Hsieh2016a).
More recently, population genomic simulations have begun to be used to help guide conservation decisions for threatened species (@Teixeira2021).

In general, population genomic simulations become more useful the more realistically they represent the organism being simulated - that is, as they incorporate more features of the organism's biology.
The demographic history of a species, encompassing population sizes, divergences, and gene flow, can dramatically affect patterns of genetic variation (@Teshima2006), and recombination rate variation across the genome also strongly affects genetic variation and haplotype structure (@Nachman2002), particularly when linked selection is important (TODO: cite linked selection?). 
Thus estimates of these parameters are fundamentally important to the development of simulations of species of interest. This presents challenges not only in the coding of the simulations themselves, but in the choice of parameter estimates to be used to shape the simulation model.

Stdpopsim is a community resource recently developed to provide easy access to detailed population genomic simulations (@Adrion2020).
This resource lowers the technical barriers to performing such simulations and reduces the possibility of erroneous implementation of simulations for species with published models.
But so far stdpopsim has been primarily restricted to well-characterized model organisms.
Feedback from workshops for users of stdpopsim emphasized the need for better understanding among the empirical population genomic community 
of when it is practical to create a realistic simulation of a species of interest, and the community desire to expand the variety of organisms 
incorporated into stdpopsim.

Thus, the choice of whether and how to develop population genomic simulations for a species of interest is affected by the genomic resources and 
knowledge available for the species. These choices have a major impact on the resulting patterns of genomic variation generated by the simulation. The  fundamental importance of these components of realistic population genomic simulations 
is not always well understood, and the necessary choices can be challenging. While stdpopsim provides a framework for standardizing simulations 
of some species, the broader population genetics community would benefit from additional guidance in putting together such simulations.

Therefore this paper is intended as a resource for both methods developers and empirical researchers to develop simulations of their 
own species of interest, with the potential to submit the simulation framework for inclusion in the stdpopsim catalog for peer review
and future use. In the **Tutorial**, 
we discuss the elements of a population genomic simulation model that realistically characterizes a species, including required input data 
(genome assembly, mutation and recombination rates, demographic model) and its quality, common pitfalls in choosing appropriate parameters, 
and considerations for how to approach species that are missing some necessary elements. This paper is not intended as a tutorial for 
implementing simulations in any particular simulator, rather to provide guidance for what information is sufficient for a realistic 
simulation using any simulator. We also discuss the **Application** of these principles to modeling a species new to the stdpopsim catalog, 
and how species models may be integrated into the stdpopsim catalog, including briefly presenting the current method for adding species, 
clarifying the required genomic resources, and describing the quality control process that reflects the peer review of a species model.

# Tutorial

Simulation is one of the key tools in population genetics, but can be unexpectedly challenging and has many hidden pitfalls for the unwary population geneticist. 
Its broad use and usefulness makes it imperative that simulations are implemented correctly at the most basic level - the parameters describing the species.
The following tutorial presents the rationales for 
1) when whole-genome simulations meant to realistically model a species of interest add utility beyond simple simulations representing a few generic loci; 
2) the necessary input data with respect to the goal of the analysis; and 
3) choosing what input data to use, and when it is of sufficient quality.

##  Whole-genome simulations: when do we need them?

When whole genome simulation is discussed, it can refer to simulating
one or a few chromosomes of particular interest in their entirety, or
indeed simulating all chromosomes of a species. These present different issues,
the most important of which come into play in simulating *whole chromosomes*.

It certainly seems "more realistic" to simulate a chromosome that matches the real one,
but strict agreement is not always desirable.
For instance, we should not ask that a simulation have polymorphic sites
at precisely the same genomic positions observed in a real dataset,
since it is these patterns of polymorphism themselves that we want to compare to the real data.
Similarly, most simulations today do not use a reference sequence,
since most population-level summaries of genetic variation do not take into account nucleotide identity.
(However, this may change in the future.)

In any simulation, even neutral ones,
linkage induces correlations between nearby parts of a chromosome. This has multiple important consequences for simulations. First, 
linkage (correlations in transmission and inheritance between adjacent parts of the chromosome) decreases the amount of 
variation in a chromosome simulated as a single continuous stretch, compared to simulating 
multiple smaller fragments that add up to the same length. That is, treating a 100Mb chromosome as 100 independent 1Mb chunks of chromosome
artificially increases the amount of independence in the data. This may be misleading if the scale of linkage is long:
for instance, results on simulated human chromosome 22 are often very noisy due to a long stretch of near-zero recombination (TODO: CITE - @petrelharp?).
The effect of natural selection on patterns of inheritance would not have been evident if the chromosome had been broken into many independent pieces for simulation. 

Second, linked selection (the effect that natural selection has on patterns of inheritance, and hence genetic diversity,
at nearby locations on the genome) strongly affects patterns of genetic variation. 
For instance, since many types of selection reduce diversity nearby,
one might expect chromosome ends to have increased diversity as they have less flanking sequence
on which selection might act (though other factors are in play as well). Without using a genetic map,
we can't look at the effect of linked selection on the correlation between recombination rate
and genetic diversity that is commonly observed in practice (CITE).
The scale over which linked selection has an effect in practice
can differ greatly depending on the species and the context,
and the actual extent is unknown.
Even in species with large population sizes,
recent selective sweeps (e.g., insecticide resistance TODO:CITE)
can cause large haplotypes to reach high frequency.

Third, linkage has the potential to affect demographic realism:
the genetic load in a simulation of a small segment of chromosome with deleterious mutations
will necessarily be less than that in whole chromosome;
this makes it easy to simulate with unrealistically high levels of load
without realizing it if small segments are used.

However it is much faster to simulate many small chunks of genome, in part because each chunk can be run concurrently, effectively parallelizing the simulation.
It's probably safe to say that independently simulating small segments
will not introduce serious problems in some situations, but could cause serious biases in others.
The degree to which it is important to include linked selection in whole-chromosome simulations
is still a major open question in the field.

Finally, what about *whole genome* simulations?
Chromosomes segregate independently,
so between-chromosome correlations are possible but can only be induced by fairly extreme situations.
For this reason, we tend to simulate chromosomes independently, and few (TODO:any? if so, find them)
simulators have mechanisms to simulate multiple chromosomes simultaneously.

## Making a population genomic simulation

Purposes of generating population genetic simulations include
testing and benchmarking inference methods,
creating data for Approximate Bayesian Computation and for training machine learning methods,
and providing comparative data for hypothesis testing, such as null models in selection analyses.
These applications are more reliable and robust
the more aspects of realism can be incorporated into the simulations,
including linkage, recombination rate variation, demographic changes, and natural selection.
So when choosing to generate realistic population genetic simulations for a species of interest, certain population and species genetic parameters should be known.
To run a population genetics simulation with the current standard of realism, 
regardless of the simulation program used, we would ideally have for the species:

1. a chromosome-level **genome assembly**,
2. an estimate of **mutation rate**,
3. an estimate of **recombination rate** (ideally, a genetic map),
4. a **generation time** estimate,
5. at least one fitted **demographic model** (at least, the effective population size of a single-population model),
6. a **genome annotation** showing at least coding/noncoding regions, and
7. a **distribution of fitness effects** for mutations occurring in various annotated regions.

Any simulation requires *some* choice for 1-5,
although values may come from another closely-related species (though this must be an informed, not arbitrary, choice);
clearly, a fully neutral simulation does not require the last two.
Furthermore, these parameters should be documented and citeable.

Here we discuss all of these in more detail:

1. A **genome assembly**,
with contigs assembled at the chromosome level or nearly so.
By using chromosome level information to simulate genomes, we indirectly simulate the effect of linked selection,
as discussed above. Briefly, this includes reduced diversity around sites of selective sweeps, but the
length of the resulting haplotypes and effects on chromosome ends can vary. 

Although few species currently have truly chromosome-level assemblies,
we hope that many more will be available in the near future, 
thanks to the advent of long-read sequencing technologies (@Amarasinghe2020) and initiatives such as the 
Vertebrate Genomes Project (@Rhie2021) and the 10KP Genome Project (@Cheng2018))
that are making the effort to generate assemblies for all vertebrate species and 10,000 plant species.

2. It is also required that the species has a plausible and citeable **mutation rate** estimate.
Phylogenetic mutation rate [TODO: ref], germline *de novo* mutations,
or mutation rate estimates based on mutation accumulation studies [TODO: ref] are useful.
Lacking one of these,
it is common to use an estimate from another (hopefully closely related) species.

3. Since both mutation and recombination shape the genetic diversity of genomes,
simulations also require a **recombination rate** estimate.
Ideally, this should be a chromosome level recombination map,
which allows more precise inference of the effect of selective interference.
At minimum, a citeable single recombination rate estimate for the whole genome is needed.
Lacking this from the species of interest,
it is common to use an estimate from another (hopefully closely related) species.

4. A **generation time** estimate is not in fact required for the simulations themselves,
(these usually work with units of generations),
but is an important part of natural history
that is required to translate results (particularly, of historical demographic models)
into real time units.

5. Ideally, the species will have at least one citeable **demographic model**
(or more than one because the appropriate demographic model to compare to a given dataset
usually depends on the sampling location(s) of the data). 
A simulation of a population requires a specification of that population,
which is a primary determinant of the levels of diversity in a given population.
Misspecification of a demographic model
can generate highly unrealistic patterns of genetic variation. (TODO: citation) At a minimum,
simulations require a
a plausible and citeable effective population size estimate,
as a single-population simulation with a reasonable (effective) size
should at least give comparable levels of overall genetic diversity.

The above factors are sufficient for modeling neutral variation in populations,
for example to infer past migration events or population size changes
under an assumption of neutrality.
However, the goal of much population genetics work 
is to understand the action or consequences of natural selection.
Although analytical models, and indeed many simulations,
tend to study the effect of single loci under selection, in isolation,
it has been demonstrated that the effects of linked selection
can vary substantially along the genome in many species (TODO: CITE),
although even the general strength and nature of this natural selection is still unknown.
To generate realistic amounts of natural selection
at many locations on the genome, the simulator needs to know
where the selected sites occur,
and what is the nature of selection on them.

6. The location of these sites is conveyed by
a **genome annotation**, such as a GFF3/GFF format [TODO: CITE] containing information about the coordinates of coding and noncoding regions, 
and the position of specific genes. 

7. A **distribution of fitness effects** describes the relative frequencies of
deleterious, neutral, and beneficial mutations. It is important for understanding the rate of adaptive evolution.
Not all simulators are able to incorporate this information, those that do include SLiM (@Haller2019), (TODO: more).
This, too, should be citeable and drawn from the species of interest or one that is closely related.

## Considerations

A commonly-encountered thorny issue
is that estimates of some of these quantities are interrelated with others.
For instance,
a published demographic model may have been estimated assuming a generation time and mutation rate
that differ from today's understanding of the best guess at those values.
In such cases, what should be done?
Naively using the demographic model with a new estimate of mutation rate
may lead to unrealistic levels of genetic diversity.
In some situations the difference may come down to only a time scaling,
so that in principle a fitted demographic model
may be translated to an equivalent one that uses a different generation time or mutation rate.
However, that process would be opaque and fraught with potential for error.

When possible, all rate, generation time, and demographic models should be drawn
from the same study. Mixing sources is not ideal, but sometimes necessary and should be
approached with deliberation. (TODO: more?

### What if we don't know everything?

In our experience, the most commonly encountered missing ingredient
for both neutral and non-neutral simulations is a chromosome-level assembly:
many species' genome assemblies are composed of many relatively small contigs
whose relation to each other is unknown. There are two main ways to deal with this.

One option would be to effectively treat these contigs as chromosomes,
simulating them either together (unlinked) or separately.
This feels "realistic", as the simulated chromosomes exactly match (in length, at least)
the real data.
The alternative is to leave aside such strict matching,
instead simulating an anonymous chromosome from which patterns of genetic variation
can be extracted (if important, in chunks of size similar to the contigs).
The latter is in fact usually more realistic,
since this includes linkage between the contigs
(although they may each be statistically unlinked,
the correlations induced by linkage may have substantial effects
on downstream analyses),
and perhaps more crucially, linked selection.
For this reason, the question of "realism" is most relevant
for those organisms having chromosome-level assemblies. 
At least in our experience it is uncommon that a species have widely-used demographic models
but not a chromosome-level assembly.

Nonetheless,
it some of these ingredients will likely be missing for many non-model species.
Table 1 displays some considerations and solutions
For example, if all the parameters above are available,
except for a chromosome level assembly, then one might choose to include only the larger contigs. 

Table of "what if one of the features above required are missing" **IZABEL**

| missing parameter 	| options 	| considerations 	|
|---	|---	|---	|
| A good assembly 	| select the most contiguous contigs	| consider just simulating a locus of appropriate length	|
| Mutation rate 	| borrow from closest relative<sup>*</sup>: with a citeable mutation rate 	| will affect levels of polymorphism 	|
| Recombination rate 	| borrow from closest relative with citeable rate	| will affect patterns of selection, linkage, and background selection 	|
| Demographic model 	| At least N<sub>e</sub> is required	| the demographic history (e.g. bottlenecks, expansions, admixture) affects patterns of variation substantially [ref], a constant Ne is not ideal |
| N<sub>e</sub> 	| always estimable from mutation rate and genetic data | may vary along the chromosome |


# Application/Discussion   

In April 2021, the popsim consortium held a "Growing the Zoo" hackathon alongside the 2021 ProbGen conference. This hackathon was intended to facilitate community-based expansion of the number and variety of species included in the stdpopsim catalog. When first published, the stdpopsim catalog included 6 species: *Homo sapiens*, *Pongo abelii*, *Canis familiaris*, *Drosophila melanogaster*, *Arabidopsis thaliana*, and *Escherichia coli.* Since then, an additional 12 (TODO: check this) species have been added, as well as multiple demographic scenarios for *Homo sapiens*, *Pongo abelii*, *Drosophila melanogaster*, and *Arabidopsis thaliana.* (TODO: find out if there are other species with more than one demographic scenario) 

The hackathon was developed as a response to participants in a series of Introduction to stdpopsim workshops held in December 2020 and February 2021. These workshops had a total of X (TODO: count) participants, many of whom expressed a wish to add their own species of interest to stdpopsim. These workshops were followed by a "Growing the Zoo" workshop in March, 2021, to prepare interested participants for the hackathon. Any member of the population genetic community who was familiar with the procedure for adding species to stdpopsim, either from attending the "Growing the Zoo" workshop or their own previous work, was invited to the hackathon. The hackathon ultimately had Y (TODO: count) participants, and Z (TODO: figure out which started during hackathon were ultimately added) species models added to the stdpopsim catalog as a result. However not all species models that were started at the hackathon were ultimately added, as we learned that there is a disconnect between what species community members wish to simulate, and those species that have sufficient resources for a realistic simulation. 

We use species worked on during the hackathon to illustrate the process of choosing a species to simulate, and finding and deciding among the required resources. We also use the lessons from the hackathon about which species are impractical to simulate to further discuss the limitations of population genomic simulations to realistically model species of interest when these species have inadequate genomic resources, and what it means for genomic resources to be inadequate in this context.may be less clear

# 5.  Examples from "Zoo" hackathon

    -   A species that was fully added (Bos taurus?) **GREGOR**

        -   resources available
        -   reasons for adding

            - ag species, hence important for breeding and genetic simulations of applied problems
            - Ne inferred to very recent times using a specific haplotype method (cite https://academic.oup.com/mbe/article/30/9/2209/1002512?login=true)
            - decreasing Ne due to domestication and recent intense selection, this scenario is quite different to many other cases (stuff like GWAS is very limited due to long-range LD, but genomic prediction works really well withing populations, ... cite https://pubmed.ncbi.nlm.nih.gov/11290733/, https://academic.oup.com/genetics/article-abstract/198/4/1671/5935952, https://royalsocietypublishing.org/doi/abs/10.1098/rspb.2016.0569)

        -   can be used for methods development and inference

## What about species lacking chromosome-level assemblies?
When we set out to cast a wide net and add a wide variety of species to the catalogue,
we quickly ran into species that people were enthusiastic to add,
but lacked many (or most) of the ingredients discussed above.
The utility of stdpopsim is to make tricky data easily available for simulation;
such data might be genetic maps, annotations, and/or demographic models.
We have not yet encountered a species with widely-used demographic models but no chromosome-level assembly,
so the main issue in practice seems to be around chromosome-level assemblies.
If there is not a chromosome-level assembly,
then we need to either just simulate many, small chunks of genome,
or simulate an anonymous chromosome, not specific to the species.
We could treat each of the many contigs of an assembly as a "chromosome" in stdpopsim.
However, this omits linkage between them (as discussed above),
but more crucially, it would be a significant amount of effort for stdpopsim developers
that wouldn't lower barriers for downstream users much at all.
With a great many contigs,
there wouldn't be much difference between a stdpopsim script
and a python script that does many msprime simulations with contig lengths drawn from some list.
Contig-level assemblies are sometimes annotated, and simulations of regions around specific genes or genomic features (eg. exons) may be of interest.
stdpopsim might make it relatively easy to simulate selection on the genic regions of such contigs,
but it is our opinion that using the precise location of genes on many, unlinked contigs is false precision:
users would be better off comparing results to simulations of anonymous genomes
chosen to be comparable in some way.
However, there is no clear line for what level of assembly quality is required to be "useful" -
most telling indication is whether there is a community of users eager to use it.



Table of species/demographic scenarios added/worked on by community since original pub

+----------------+----------------+------------------------------+----------------------------------------------------------+
| Species        | Phylum         | New species or demog. model? | Outcome??? (added, abandoned, in QC, chosen not to add?) |
+================+================+==============================+==========================================================+
| Bos taurus     | Chordata       | Both                         | Added                                                    |
+----------------+----------------+------------------------------+----------------------------------------------------------+
| ...            | ...            | ...                          | ...                                                      |
+----------------+----------------+------------------------------+----------------------------------------------------------+

# 6.  Steps to add a species to stdpopsim catalog


    -   catalog is the place where simulation frameworks get peer-reviewed through the QC system (see below)
    -   adding to the catalog is important

        - feedback from 2020/2021 workshops made it clear that the prospective community included empiricists who are especially concerned with using stdpopsim for inference for individual species that mostly not already in stdpopsim catalog
        - Current gaps in types of species in catalog

            -   7 chordates, 2 plants (1 vascular, 1 algae), 2 bacteria, 6 arthropods, 1 nematode
            -   lots of potential for supporting methods development for other types of organisms (that aren't vertebrates and insects)

                -   eg. yeast
                -   eg. more plants because plants have goofy genomes

    -   steps to add:

        -   find required resources and citations (chromosome-level assembly, mutation rate, recombination rate or map, Ne or demog. model, annotations)

            -   including an actual human being(s) willing to put in the time and effort
            -   find and evaluate the necessary information and citations
            -   add code - detailed steps, reference workshop materials on github https://github.com/popsim-consortium/workshops/blob/main/adding_species/contributing.ipynb

        -   QC - detailed steps
        -   update catalog documentation?

    -   emphasize that anything that ends up in the catalog has the potential to be updated (because science)
    
# 7. Conclusion/take-aways

    - we present the basics for 

        - 1) determining if a species-specific population genomic simulation is appropriate for the species/question
        - 2) getting the required data
        - 3) creating a population genomic simulation of that species in your simulator of choice
        - 4) adding that species to the stdpopsim catalog
        - we *do not* present tutorials for implementation in any particular simulator (there are lots of those)

    - For many species we need better genomic resources: assemblies and annotations would be community resources
    - there is a definite need for more and more species-specific population genomic simulations

        - but gaps in practitioners' understandings of when and how to implement them for a given species
        - stdpopsim is a community-maintained resource intended to provide easy access to simulation frameworks, adding species expands the types of methods development and inference it is useful for

            -   we learned from the hackathon that people are willing to put in the time and effort to add species, when given clear guidance for how to do it
            -   not all species that people want to add have appropriate genomic resources yet, but many will soon!
            -   so this paper provides the population genomics community with more clarity in what resources are necessary and how to use them to simulate your favorite species


