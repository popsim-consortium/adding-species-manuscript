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
is useful for [all sorts of things].
As more and more information about many species becomes available
and more detailed models estimated,
the need for more and more detailed simulations of a wide range
of species becomes more acute.
The recently developed stdpopsim tool makes it easy to simulate
complex models using up to date information for a number of
well characterised and model organisms such as humans, etc,
but provides little help in enabling simulations for less
well characterised organisms.
Many users wish to simulate their study organism, but do not
know what information is required in order to do this and
where this information might be found.
In this paper we discuss the elements of a population genetic
simulation model, and the input data required in order to make
them a realistic characterisation of a particular species.
We discuss how such information is integrated into the
stdpopsim catalog, and some of the lessons learned from a
recent effort to expand the range of supported species.
Thus, this paper serves as a tutorial in both how to
assemble the data that is required in order to simulate
a species, and how this information can be incorporated
into the stdpopsim catalog in order to make it available
to everyone.


Outline

# Introduction
1.  Simulation is important for population genomics, both methods development and inference
    - there is a building avalanche of genomic data for a variety of species @Ellegren2014, and a complementary flourishing of methods for population genomic inference @Loog2021
        - so the number and variety of species requiring detailed and accurate simulation models is increasing quickly
    -   coding population genetic simulation models can be arduous and error-prone @Ragsdale2020, but important
        -   provide training data for machine learning @Schrider2018, ABC @Csillery2010
        -   for both methods development and empirical research
        - "accurate" includes realistic demographic models @Teshima2006 (maybe not the best citation) and genetic maps @Nachman2002 as both can strongly impact the patterns of variation and haplotype/linkage
        -   baseline for further analyses, demography as null model in selection analyses @Hsieh2016a. (This self-cite might not be the best reference here...)
        -   Predictive modeling for conservation @Teixeira2021
    - stdpopsim is a tool recently developed to provide easy access to simulation frameworks @Adrion2020

        -   avoid re-making common models
        -   provide standard benchmarks for methods development and testing @Adrion2021
        -   improves reproducibility
        - lower the barrier to technical coding skills
        - but so far stdpopsim has been mainly restricted to well-characterised model organisms, limiting utility for non-model organisms or model organisms in the early stages of development

    - many potential users want to simulate their study organism, or develop inference methods for non-model organisms

        -   feedback from 2020/2021 stdpopsim workshops emphasized the need for simulations of a wide variety of model and non-model species

Dramatic reductions in sequencing costs are enabling unprecedented genomic data  to be collected for a huge variety of species @Ellegren2014.
Correspondingly, methods for inferring demographic history and natural selection from such data are flourishing @Beichman2018.
Past methods development has often focused on model organisms such as *Drosophila* or, piggybacking on medical genomics, humans.
But new methods are being developed, or old methods enhanced, to model population characteristics that are key to many organisms but less important in these traditional models, such as inbreeding @Blischak2020 or skewed offspring distributions @Montano2016.
(RNG: Any models include these features in the catalog?)
Models inferred from these tools are an important community resource, but reuse of such models can be arduous and error-prone @Ragsdale 2020.

Simulations from population genomic models have many uses, both for methods development and empirical research.
They provide training data for inference methods based on machine learning @Schrider2018 or Approximate Bayesian Computation @Csillery2010.
They can also serve as baselines for further analyses; for example, models incorporating demographic history servce as null models in selection analyses @Hsieh2016a.
(RNG: This self-cite might not be the best reference.)
Population genomic simulations can also help guide conservation decisions for threatened species @Teixeira2021.

In general, population genomic simulations become more useful as they incorporate more features of the organism's biology.
The demographic history of a species, encompassing population sizes, divergences, and gene flow, can dramatically affect patterns of genetic variation @Teshima2006.
(RNG: Maybe not the best citation for this.)
Recombination rate variation across the genome also strongly affects genetic variation and haplotype structure @Nachman2002, particularly when linked selection is important.

Stdpopsim is a community resource recently developed to provide easy access to detailed population genomic simulations @Adrion2020.
This resource lowers the technical barriers to performing such simulations and reduces the possiblity of erroneous implementation of established models.
But so far stdpopsim has been primarily restricted to well-characterized model organisms.
Feedback from workshops for users of the stdpopsim emphasized the need to expand the variety of organims incorporated into stdpopsim.

2.  **ELISE** Therefore this paper is intended as a resource for both methods developers and empirical researchers to develop simulations of their own species of interest, with the potential to submit the simulation framework for inclusion in the stdpopsim catalog

    - we discuss the elements of a population genomic simulation model that realistically characterizes a species, including:
        - input data
        - reasonable data quality
        - simulation frameworks (coalescent and forward?)
    - in addition, we discuss 
        - limitations of available data and when a species-specific simulation may be impractical or unnecessary for the intended task
    - lastly, we discuss how these models may be integrated into the stdpopsim catalog
        -   we present the current method for adding species and demographic scenarios to the catalog 
        -   and clarify the required genomic resources and QC process

# Tutorial

TODO: general introduction to this section

##  Whole-genome simulations: when do we need them?

The stdpopsim framework aims to make it easy to simulate *whole chromosomes*,
with realistic chromosome structure (i.e., with recombination maps and annotations).
However, it is much faster to simulate many small chunks of genome,
in part because it effectively parallelizes the simulation.
Indeed, such simulations have been used for many applications,
e.g., to train machine learning methods to identify regions of the genome under selection (CITE).
It certainly seems "more realistic" to simulate a chromosome that matches the real one,
but strict agreement is not always desirable.
For instance, we should not ask that a simulation have polymorphic sites
at precisely the same genomic positions observed in a real dataset,
since it is these patterns of polymorphism themselves that we want to compare to the real data.
Similarly, most simulations today do not use a reference sequence,
since most population-level summaries of genetic variation do not take into account nucleotide identity.
(However, this may change in the future.)
The differences between one whole-chromosome simulation and many independent simulations of smaller pieces of genome
are due to linkage, i.e., correlations in transmission and inheritance between adjacent parts of the genome.
In any simulation, even neutral ones,
linkage induces correlations between nearby parts of the genome,
and so treating, say, a 100Mb chromosome as 100 independent 1Mb chunks of genome
artificially increases the amount of independence in the data.
This may be misleading if the scale of LD is long:
for instance, in our own work, results on simulated human chromosome 22 are often very noisy
due to a long stretch of near-zero recombination.
We would not have seen these effects if we'd broken the chromosome into many independent pieces.
Of course, any study using the incidence of long, shared haplotypes
must simulate regions of genome substantially longer than that.

A more serious motivation for providing the ability to do whole-genome simulations
is to model the effects of linked selection.
"Linked selection" refers to the effect that natural selection has
on patterns of inheritance, and hence genetic diversity,
at nearby locations on the genome.
For instance, since many types of selection reduce diversity nearby,
one might expect chromosome ends to have increased diversity as they have less flanking sequence
on which selection might act.
(In practice, other factors are at play as well.)
Without using a genetic map,
we can't look at the effect of linked selection on the correlation between recombination rate
and genetic diversity, that is commonly observed in practice (CITE).
The scale over which linked selection has an effect in practice
can differ greatly depending on the species and the context,
and the actual extent is unknown.
Even in large-population-size species,
recent selective sweeps (e.g., insecticide resistance XXX)
can cause large haplotypes to reach high frequency.
Another practical consideration is demographic realism:
the genetic load in a simulation of a small segment of genome with deleterious mutations
will necessarily be less than that in whole chromosome;
this makes it easy to simulate with unrealistically high levels of load
without realizing it if small segments are used.
It's probably safe to say that independently simulating small segments
will not introduce serious problems in some situations, but could cause serious biases in others.
The degree to which it is important to include linked selection in whole-chromosome simulations
is, we think, still a major open question in the field.

Finally, what about whole *genome* simulations?
Chromosomes segregate independently,
so between-chromosome correlations are possible but can only be induced by fairly extreme situations.
For this reason, we tend to simulate chromosomes independently,
and do not have an easy mechanism to simulate multiple chromosomes simultaneously
with stdpopsim.


## Making a popgen simulation

Purposes of generating population genetic simulations include
testing and benchmarking inference methods,
creating data for Approximate Bayesian Computation and for training machine learning methods,
and (TODO: should complement the introduction).
These applications are more reliable and robust
the more aspects of realism can be incorporated into the simulations,
including linkage, recombination rate variation, demographic changes, and natural selection.
So when choosing to generate realistic population genetic simulations for a species of interest, certain elements should be known.
Regardless of the simulation program used,
to run a population genetics simulation
with the current standard of realism,
we would ideally have for the species:

1. a chromosome-level **genome assembly**,
2. an estimate of **mutation rate**,
3. an estimate of **recombination rate** (ideally, a genetic map),
4. a **generation time** estimate,
5. at least one fitted **demographic model** (at least, the effective population size of a single-population model),
6. a **genome annotation** showing at least coding/noncoding regions, and
7. **distributions of fitness effects** for mutations occurring in various annotated regions.

Any simulation requires *some* choice for 1-5,
although values may come from another speicies;
clearly, a neutral simulation does not require the last two.
Furthermore, we require all ingredients added to stdpopsim
to be documented, and citeable.
Processes for quality control are discussed in more detail in (CITE first paper),
but in brief (TODO: summarise).
Here we discuss all these in more detail:

A **genome assembly**,
with contigs being assembled at the chromosome level or nearly so.
By using chromosome level information to simulate genomes, stdpopsim indirectly simulates the effect of linked selection,
as discussed above.
*(move that discussion here?)*
Although few species currently have truly chromosome-level assemblies,
we hope that many more will be available in the near future,
thanks to the advent of long-read sequencing technologies [ref]
and initiatives such as B10K, XXXX, and G10K near XXX [Rhie et al, 2021, REF, REF],
that plan to generate assemblies for XXX vertebrate species.

It is also required that the species has a plausible and citeable **mutation rate** estimate.
Both phylogenetic mutation rate [ref], germline *de novo* mutations,
or mutation rate estimates based on mutation accumulation studies [ref] are welcomed.
Lacking one of these,
it is common to use an estimate from another (hopefully closely related) species.


Since both mutation and recombination shape the genetic diversity of genomes,
stdpopsim also requires a **recombination rate** estimate.
Ideally, this should be a chromosome level recombination map,
which allows more precise inference of the effect of selective interference.
At minimum, a citeable single recombination rate estimate for the whole genome is needed.

A generation time estimate, (in years), is also required.
This is not in fact required for the simulations themselves (that usually work with units of generations),
but is an important part of natural history
that is required to translate results (particularly, of historical demographic models)
into real time units.


A simulation of a population requires a specification of that population,
which is a primary determinant of the levels of diversity in a given population.
Misspecification of a demographic model
can generate highly unrealistic patterns of genetic variation,
and so making published, quality-controlled demographic models easily available
is one of the most important roles of stdpopsim.
Ideally, each species will have at least one citeable **demographic model**
(more than one because the appropriate demographic model to compare to a given dataset
usually depends on the sampling location(s) of the data),
although at minimum, stdpopsim requires a
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
can vary substantially along the genome in many species,
although even the general strength and nature of this natural selection is still unknown.
To generate realistic amounts of natural selection
at many locations on the genome, stdpopsim needs to know
where the selected sites occur,
and what is the nature of selection on them.
The location of these sites is conveyed by
a **genome annotation**, such as a GFF3/GFF format [ref] containing information about the coordinates of coding and noncoding regions;
and the position of specific genes. 
At present, stdpopsim allows only multiplicative fitness effects,
as specified by a **distribution of fitness effects** (DFE, REF) for the species,
which should be citeable.

## Considerations

A commonly-encountered thorny issue
is when estimates of some of these quantities are interrelated with others.
For instance,
a published demographic model may have been estimated assuming a generation time and mutation rate
that differ from today's understanding of the best guess at those values.
In such cases, what should be done?
Naively using the demographic model with a more recent estimate of mutation rate
may lead to unrealistic levels of genetic diversity.
In some situations the difference may come down to only a time scaling,
so that in principle a fitted demographic model
may be translated to an equivalent one that uses a different generation time or mutation rate.
However, that process would be opaque and fraught with potential for error.
So, we XXX
(AARON, GREGOR, want to have a go at this?)

    - eg. "often reported parameter values are tied to a model and its other parameters, so mixing values from different sources has its own caveats"
    (https://github.com/popsim-consortium/adding-species-manuscript/issues/7)


## What if we don't know everything?

In our experience, the most commonly encountered missing ingredient
is a chromosome-level assembly:
many species' genome assemblies are composed of many relatively small contigs
whose relation to each other is unknown.
One option would be to effectively treat these contigs as chromsomes,
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
for those organisms having chromosome-level assemblies:
at least, in our experience it is uncommon that a species have widely-used demographic models
but not a chromosome-level assembly.

Nonetheless,
it some of these ingredients will likely be missing for many non-model species
that we want in the catalogue.
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

## 4. **ELISE** Lessons from "Growing the Zoo" hackathon, held along side probgen in April 2021

    - Community-based expansion of the number and variety of species and their demographic scenarios included in the stdpopsim catalog
    
      -   when first published, the stdpopsim catalog included 6 species: *Homo sapiens*, *Pongo abelii*, *Canis familiaris*, *Drosophila melanogaster*, *Arabidopsis thaliana*, and *Escherichia coli.*
      
        -   when did additional demographic scenarios start getting added?
        -   the catalog now includes an additional **12** species (note: is this correct, number is from those on main branch)? the catalog doc still only includes the original 6? - MEL), as well as multiple demographic scenarios for *Homo sapiens*, *Pongo abelii*, *Drosophila melanogaster*, and *Arabidopsis thaliana.* (others?)
        -   however there were some species that were not ideal for inclusion in the catalog, because they don't yet have the necessary genomic resources

    -   We had *X* participants in the introduction to stdpopsim workshops, many of whom expressed a wish to add their own species for empirical work

        - further *Y* participants in the hackathon
        - stdpopsim has become a popular resource and there is clearly a desire/need for adding additional species for both goals of methods development and empirical inference
        - Only *Z* species ultimately got added, why?

            -   choosing species/demographic scenarios to add is potentially challenging
            -   for methods development, they have to be appropriate for the goals of the method
            -   for empirical studies, the species is obvious, but whether it is appropriate for inclusion in the catalog or even to use stdpopsim may be less clear

## 5.  Examples from "Zoo" hackathon

    -   A species that was fully added (Bos taurus?) **GREGOR**

        -   resources available
        -   reasons for adding

            - ag species, hence important for breeding and genetic simulations of applied problems
            - Ne inferred to very recent times using a specific haplotype method (cite https://academic.oup.com/mbe/article/30/9/2209/1002512?login=true)
            - decreasing Ne due to domestication and recent intense selection, this scenario is quite different to many other cases (stuff like GWAS is very limited due to long-range LD, but genomic prediction works really well withing populations, ... cite https://pubmed.ncbi.nlm.nih.gov/11290733/, https://academic.oup.com/genetics/article-abstract/198/4/1671/5935952, https://royalsocietypublishing.org/doi/abs/10.1098/rspb.2016.0569)

        -   can be used for methods development and inference

    -   A demographic model that was fully added (note: not sure there were any? we worked on Canis familiaris but it hasn't finished QC - MEL)

        -   resources available (already had species in catalog, but not a demographic model, just Ne)
        -   reasons for adding

    -   A species that was purposefully not added (Myotis lucifugus)

        -   resources available (everything except chromosome-level genome)
        -   why wasn't it added? (see above re: contigs and just using msprime directly)

**(MOVED FROM ABOVE)**
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
What about annotations with many contigs, but that are annotated?
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

## 6.  Steps to add a species to stdpopsim catalog


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
    
# Conclusion

7.  Take-aways

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
