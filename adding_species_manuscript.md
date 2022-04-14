---
title: 'Adding species to the standard population genetics simulator - stdpopsim'
author:
- name: null
  affiliation: null
- name: Gregor Gorjanc
  affiliation: The Roslin Institute and Royal (Dick) School of Veterinary Studies, University of Edinburgh, Edinburgh EH25 9RG, UK
- name: null
  affiliation: null
output:
  html_document:
    df_print: paged
  word_document: default
  pdf_document:
    fig_caption: yes
    keep_tex: yes
    number_sections: yes
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

Simulation is one of the key tools in population genetics. It
is useful for both methods development and empirical research, including
providing training data and null models for hypothesis testing.
As more and more information about many species genomes becomes available
and more detailed population genetic models estimated,
the need for more detailed simulations of a wide range
of scenarios becomes more acute. Population genetic data is being generated
faster than ever before with efforts like the Earth Biogenome and its affiliated
project networks. These efforts will generate an avalanche of population genetic
data in model and non-model species. 
The recently developed stdpopsim tool makes it easy to simulate
complex population genetic models using up to date information for a number of
well characterised model species such as humans, chimpanzees, and *Arabidopsis*,
but provides little help in enabling simulations for less
well characterised species.
Many users wish to simulate their study species, but do not
know what information is required in order to do this and
where this information might be found.
In this paper we discuss the elements of a population genetic
simulation model, including the required input data to make
them a realistic characterisation of a particular species. We also discuss
common pitfalls and major considerations in choosing this input data.
Further, we discuss how such information can be integrated into the
stdpopsim catalog to simplify future simulations of the same species, 
and some of the lessons learned from a
recent effort to expand the range of supported species.
Thus, this paper serves as a tutorial in both how to
assemble the data that is required to simulate
a species, and how this information can be incorporated
into the stdpopsim catalog to make it available
to everyone.


# Introduction

Dramatic reductions in sequencing costs are enabling unprecedented genomic data to be generated for a huge variety of species (@Ellegren2014).
Ongoing efforts to systematically sequence the life on Earth with efforts like the Earth Biogenome (@Lewin2022) and its affiliated project networks
(for example, Vertebrate Genomes (@Rhie2021), 10,000 Plants (@Cheng2018) and others, see https://www.earthbiogenome.org/affiliated-project-networks) 
are facilitating enormous increases in population-level genomic data for model and non-model species.
Correspondingly, methods for inferring demographic history and natural selection from such data are flourishing (@Beichman2018).
Past methods development has justifiably focused on the human genome as a model system, or a few key species such as *Drosophila*,
yet more recently attention has been paid to generalize methods to include important population dynamics not present in these models 
such as inbreeding (@Blischak2020), skewed offspring distributions (@Montano2016), selfing (eg. as implemented in Demes (@Gower2022)), 
and intense artificial selection (@MacLeod2013, @MacLeod2014).

Simulations from population genomic models have many uses, both for methods development and empirical research.
They provide training data for inference methods based on machine learning (@Schrider2018) or Approximate Bayesian Computation (@Csillery2010).
They can also serve as baselines for further analyses; for example, models incorporating demographic history serve as null models in selection analyses (@Hsieh2016a) or to seed downstream breeding program simulations (@Gaynor2020).
More recently, population genomic simulations have begun to be used to help guide conservation decisions for threatened species (@Teixeira2021).

In general, population genomic simulations become more useful the more realistically they represent the species being simulated - that is, as they incorporate more features of the species' biology.
Genome features such as mutation and recombination rates strongly affect genetic variation and haplotype structure (@Nachman2002), particularly when linked selection is important (TODO: cite linked selection?). Furthermore, the demographic history of a species, encompassing population sizes, divergences, and gene flow, can dramatically affect patterns of genetic variation (@Teshima2006). 
Thus estimates of these parameters are fundamentally important to the development of simulations of species of interest. This presents challenges not only in the coding of the simulations themselves, but in the choice of parameter estimates to be used to shape the simulation model.

Stdpopsim is a community resource recently developed to provide easy access to detailed population genomic simulations (@Adrion2020).
This resource lowers the technical barriers to performing such simulations and reduces the possibility of erroneous implementation of simulations for species with published models.
But so far stdpopsim has been primarily restricted to well-characterized model species.
Feedback from stdpopsim workshops emphasized the need for a better understanding among the empirical population genomic community 
of when it is practical to create a realistic simulation of a species of interest, and the community desires to expand the variety of species in stdpopsim.

Thus, the choice of whether and how to develop population genomic simulations for a species of interest is affected by the genomic resources and 
knowledge available for the species. These choices have a major impact on the resulting patterns of genomic variation generated by the simulation. The fundamental importance of these components of realistic population genomic simulations 
is not always well understood, and the necessary choices can be challenging. While stdpopsim provides a framework for standardizing simulations 
of some species, the broader population genetics community would benefit from additional guidance in putting together such simulations.

Therefore this paper is intended as a resource for both methods developers and empirical researchers to develop simulations of their 
own species of interest, with the potential to submit the simulation framework for inclusion in the stdpopsim catalog for peer review
and future use. In the **Tutorial**, 
we discuss the elements of a population genomic simulation model that realistically characterizes a species, including required input data 
(genome assembly, mutation and recombination rates, and demographic model) and its quality, common pitfalls in choosing appropriate parameters, 
and considerations for how to approach species that are missing some necessary inputs. This paper is not intended as a tutorial for 
implementing simulations in any particular simulator, rather to provide guidance for what information is sufficient for a realistic 
simulation using any simulator. We also discuss the **Application** of these principles to modeling a species new to the stdpopsim catalog, 
and how species models may be integrated into the stdpopsim catalog, including briefly presenting the current method for adding species, 
clarifying the required genomic resources, and describing the quality control process that reflects the peer review of a species model.

# Tutorial

Simulation is one of the key tools in population genetics, but can be unexpectedly challenging and has many hidden pitfalls for the unwary population geneticist. 
Its broad use and usefulness makes it imperative that simulations are implemented correctly at the most basic level - the parameters describing the species.
The following tutorial presents the rationales for:
1) when whole-genome simulations meant to realistically model a species of interest add utility beyond simple simulations representing a few generic loci; 
2) the necessary input data with respect to the goal of the analysis; and 
3) choosing what input data to use, and when it is of sufficient quality.

##  Whole-genome simulations: when do we need them?

When a whole-genome simulation is discussed, it can refer to simulating
one or a few chromosomes of particular interest in their entirety, or
indeed simulating all chromosomes of a species. These present different issues,
the most important of which come into play in simulating *whole chromosomes*.

It certainly seems "more realistic" to simulate a chromosome that matches the real one,
but strict agreement is not always attainable, sometimes even not desirable.
For instance, we should not ask that a simulation have polymorphic sites
at precisely the same genomic positions observed in a real dataset,
since it is these patterns of polymorphism themselves that we want to compare to the real data.
Similarly, most simulations today do not use a reference genome sequence,
since most population-level summaries of genetic variation do not take into account nucleotide identity.
(However, this may change in the future.)

In any simulation, even neutral ones,
linkage induces correlations between nearby parts of a chromosome. This has multiple important consequences for simulations. First, 
linkage decreases the amount of 
variation in a chromosome simulated as a single continuous stretch, compared to simulating 
multiple smaller fragments that add up to the same length. That is, treating a 100Mb chromosome as 100 independent 1Mb chunks of chromosome
artificially increases the amount of independence in the data. This may be misleading if the scale of linkage is long:
for instance, results on simulated human chromosome 22 are often very noisy due to a long stretch of near-zero recombination (TODO: CITE).
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
can drive long haplotypes to high frequencies.

Third, linkage has the potential to affect demographic realism:
the genetic load in a simulation of a small segment of chromosome with deleterious mutations
will necessarily be less than that in whole chromosome.
This situation makes it easy to simulate unrealistically high levels of load
without realizing it if small segments are used.

However it is much faster to simulate many small chunks of genome, in part because each chunk can be run concurrently, effectively parallelizing the simulation.
It's probably safe to say that independently simulating small segments
will not introduce serious problems in some situations, but could cause serious biases in others (e.g., @Nelson2020).
The degree to which it is important to include linked selection in whole-chromosome simulations
is still a major open question in the field.

Finally, what about *whole-genome* simulations?
Chromosomes segregate independently,
so between-chromosome correlations are possible but can only be induced by fairly extreme situations, such as intense directional or stabilising selection on multiple loci across chromosomes (@Bulmer1971, @Lara2022). However, this situation can be simulated in follow-up forward-in-time simulations (@Haller2018, @Gaynor2020).
For this reason, we tend to simulate chromosomes independently, and few (TODO:any? if so, find them)
simulators have mechanisms to simulate multiple chromosomes simultaneously.

## Making a population genomic simulation

Purposes of generating population genetic simulations include
testing and benchmarking inference methods,
creating data for Approximate Bayesian Computation and for training machine learning methods,
providing comparative data for hypothesis testing, such as null models in selection analyses, and so on.
These applications are more reliable and robust
the more aspects of realism can be incorporated into the simulations,
including linkage, recombination rate variation, demographic changes, and selection.
When choosing to generate realistic population genetic simulations for a species of interest, certain population and species genetic parameters should be known.
The current standard of realism, 
regardless of the simulation program used, would ideally include:

1. a chromosome-level **genome assembly**,
2. an estimate of **mutation rate**,
3. an estimate of **recombination rate** (ideally, a genetic map),
4. an estimate of **generation time**,
5. at least one **demographic model** (as a minimum, the effective population size of a single-population),
6. a **genome annotation** showing at least coding and non-coding regions, and
7. a **distribution of fitness effects** for mutations occurring in various annotated regions.

Any simulation requires *some* choice for 1-5,
although values may come from another closely-related species (though this must be an informed, not arbitrary, choice). Clearly, a fully neutral simulation does not require the last two.
Furthermore, these parameters should be documented and citeable.

Here we discuss all of these in more detail:

1. A **genome assembly**,
with contigs assembled at the chromosome level or nearly so.
By using chromosome level information to simulate genomes, we can indirectly simulate the effect of linkage and linked selection,
as discussed above. Briefly, this includes more variation in simulation outcomes and reduced diversity around sites of selective sweeps, but the
length of the resulting haplotypes and effects on chromosome ends can vary. 

Although few species currently have truly chromosome-level assemblies,
we hope that many more will be available in the near future, 
thanks to the advent of long-read sequencing technologies (@Amarasinghe2020) and genome initiatives like the Earth Biogenome (@Lewin2022) and its affiliated project networks (for example, Vertebrate Genomes (@Rhie2021), 10,000 Plants (@Cheng2018) and others, see https://www.earthbiogenome.org/affiliated-project-networks).

2. It is also required that the species has a plausible and citeable **mutation rate** estimate.
Phylogenetic mutation rate [TODO: ref], germline *de-novo* mutation rate,
or mutation rate estimates based on mutation accumulation studies [TODO: ref] are useful.
Lacking one of these,
it is common to use an estimate from another species, hopefully closely related.

3. Since both mutation and recombination shape the genetic diversity of genomes,
simulations also require a **recombination rate** estimate.
Ideally, this should be a chromosome level recombination map,
which allows more precise simulation of the effect of recombination interference.
At minimum, a citeable single recombination rate estimate for the whole genome is needed.
Lacking this from the species of interest,
it is common to use an estimate from another species, hopefully closely related.

4. A **generation time** estimate is not in fact required for the simulations themselves because these usually work in units of generations,
but is an important part of natural history
that is required to translate results into real time units, particularly for historical demographic models.

5. The simulated species should have at least one citeable **demographic model**
(or more than one because the appropriate demographic model to compare to a given dataset
usually depends on the sampling location(s) of the data). 
A simulation of a population requires a specification of that population,
which is a primary determinant of the levels of diversity in a given population.
Misspecification of a demographic model
can generate highly unrealistic patterns of genetic variation. (TODO: citation) At a minimum,
simulations require a
a plausible and citeable effective population size estimate.
A single-population simulation with a reasonable effective size
should at least give comparable levels of overall genetic diversity. However, if
there were sizable changes in effective population over time (e.g., @MacLeod2013),
this dynamics will have to be incorporated to generate meaningful level and kind
of genetic diversity.

The above factors are sufficient for modeling neutral variation in populations,
for example to infer past migration events or population size changes
under an assumption of neutrality.
However, the goal of much population genetics work 
is to understand the action or consequences of selection.
Although analytical models, and indeed many simulations,
tend to study the effect of single loci under selection, in isolation,
it has been demonstrated that the effects of linked selection
can vary substantially along the genome in many species (TODO: CITE),
although even the general strength and nature of this selection is still unknown.
To generate realistic amounts of selection
at many locations on the genome, the simulator needs to know
where the selected sites occur,
and what is the nature of selection on them.

6. The location of these sites is conveyed by
a **genome annotation**, such as a GFF3/GFF format [TODO: CITE] containing information about the coordinates of coding and non-coding regions, 
and the position of specific genes.

7. A **distribution of fitness effects** describes the relative frequencies of
deleterious, neutral, and beneficial mutations. This distribution is important for understanding the rate of adaptive evolution.
Not all simulators are able to incorporate this information, those that do include a general purpose forward-in-time population genetics simulator SLiM (@Haller2019), (TODO: more).
This, too, should be citeable and drawn from the species of interest or one that is closely related.

## Considerations

A commonly-encountered thorny issue
is that estimates of some of these parameters are interrelated with others.
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
approached with deliberation. (TODO: more?)

### What if we don't know everything?

In our experience, a commonly encountered missing ingredient for a population genetic
simulations (neutral and non-neutral) in non-model species is a chromosome-level assembly.
Many species' genome assemblies are composed of many relatively small contigs
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
for those species having chromosome-level assemblies. 
At least in our experience it is uncommon that a species have widely-used demographic models
but not a chromosome-level assembly.

Nonetheless,
some of these ingredients will likely be missing for many non-model species.
Table 1 displays some considerations and solutions
For example, if all the parameters above are available,
except for a chromosome level assembly, then one might choose to include only the larger contigs. 

Table of "what if one of the features above required are missing" **IZABEL**

| Missing parameter 	| Options 	| Considerations 	|
|---	|---	|---	|
| A good assembly 	| select the most contiguous contigs	| consider just simulating a locus of appropriate length	|
| Mutation rate 	| borrow from closest relative<sup>*</sup> with a citeable mutation rate 	| will affect levels of polymorphism 	|
| Recombination rate 	| borrow from closest relative with a citeable rate	| will affect patterns of selection, linkage, and linked selection 	|
| Demographic model 	| At least N<sub>e</sub> is required	| the demographic history (e.g. bottlenecks, expansions, admixture) affects patterns of variation substantially [CITE], a constant Ne is not ideal |
| N<sub>e</sub> 	| always estimable from mutation rate and genetic data | may vary along the chromosome and over time |
(Gregor: Isn't N<sub>e</sub> in the last line part of the demographic model (the line before)?)


# Application/Discussion   

In April 2021, the popsim consortium held a "Growing the Zoo" hackathon alongside the 2021 ProbGen conference. This hackathon was intended to facilitate community-based expansion of the number and variety of species included in the stdpopsim catalog. When first published, the stdpopsim catalog included 6 species: *Homo sapiens*, *Pongo abelii*, *Canis familiaris*, *Drosophila melanogaster*, *Arabidopsis thaliana*, and *Escherichia coli.* Since then, an additional 12 (TODO: check this) species have been added, as well as multiple demographic scenarios for *Homo sapiens*, *Pongo abelii*, *Drosophila melanogaster*, and *Arabidopsis thaliana.* (TODO: find out if there are other species with more than one demographic scenario).

The hackathon was developed as a response to participants in a series of Introduction to stdpopsim workshops held in December 2020 and February 2021. These workshops had a total of X (TODO: count) participants, many of whom expressed a wish to add their own species of interest to stdpopsim. These workshops were followed by a "Growing the Zoo" workshop in March, 2021, to prepare interested participants for the hackathon. Any member of the population genetic community who was familiar with the procedure for adding species to stdpopsim, either from attending the "Growing the Zoo" workshop or their own previous work, was invited to the hackathon. The hackathon ultimately had Y (TODO: count) participants, and Z (TODO: figure out which started during hackathon were ultimately added) species models added to the stdpopsim catalog as a result. However not all species models that were started at the hackathon were ultimately added, as we learned that there is a disconnect between what species community members wish to simulate, and those species that have sufficient resources for a realistic simulation. 

We use species worked on during the hackathon to illustrate the process of choosing a species to simulate, and finding and deciding among the required resources. We also use the lessons from the hackathon about which species are impractical to simulate to further discuss the limitations of population genomic simulations to realistically model species of interest when these species have inadequate genomic resources, and what it means for genomic resources to be inadequate in this context may be less clear

# Examples from "Zoo" hackathon

    -   A species that was fully added (Bos taurus?) **GREGOR**
    
We have added Bos taurus (cattle) as an example of an agricultural species.
These species have generally experienced strong reduction in effective
population size over time due to selection caused by past domestication and
recent selective breeding. Both of these processes have occurred over a
relatively short period (~10,000 years or less) and are increasingly intensified
to improve food production (@Gaut2018, @MacLeod2013).  In cattle, high quality
genome assemblies are now available for several breeds (e.g., @Rosen2020,
@Heaton2021, @Talenti2022) and population genomic analyses have become widely
used to improve selective breeding and genomic prediction
@Meuwissen2001, @MacLeod2014, @Obsteter2021). Their small effective population
size (~90 around 1980, and continuing to decline due to intense selective
breeding (@MacLeod2013, @VanRaden2020, @Makanjouloa2020) is challenging
demographic and selection inference (@MacLeod2013, @Hartfield2022), as well as
genome-wide association and prediction (@MacLeod2014), For these reasons, it was
useful to develop a standardized population genomic cattle model for stdpopsim.

With respect to the parameters chosen in the stdpopsim
implementation, for the basic genome simulation we used the most recent assembly
(@Rosen2020), mutation rate of 1.2*10^-8 (@Harland2017), recombination rate of
0.926*10^-8 (@Ma2015), base population effective population of 90 (@MacLeod2013),
and generation interval of 5 years (@MacLeod2013). The chosen effective population
size is specific to the Holstein breed, but is likely also representative of a
small effective population size in other breeds. Critically, this low effective
population size will generate very low level of overall genetic diversity, which
is not in line with the actually observed variation (e.g., @Rosen2020). To remedy
this, the basic genome simulation must be complemented with a demographic model.
We implemented the @MacLeod2013 demographic model for the Holstein breed, which
was inferred from runs of homozygosity in the whole-genome sequence of two iconic
bulls. The estimated effective population size in this demography spans from
the deep past to about 1980, after which further breeding simulations with
intense selective breeding are needed to (e.g., @MacLeod2014, @Gaynor2020,
@Obsteter2021). @MacLeod2013 assumed recombination and mutation rates of 1*10^-8
in inferring their demographic model, but revised the mutation rate to 0.94*10^-8
by taking sequence errors into account. In line with the advice given in previous
sections, we implemented these mutation and recombination rates for the @MacLeod2013
demographic model, even though we have implemented more recent estimates in the base
genome model, though they are very similar. When a simulation with this demographic
model is requested, the recent estimates are replaced with the estimates assumed
in the demographic model. (Gregor: THIS IS TRUE FOR MUTATION RATE, BUT NOT FOR RECOMBINATION RATE - SHOULD YOU CHANGE THE IMPLEMENTATION?)

## What about species lacking chromosome-level assemblies?

When we set out to cast a wide net and add a wide variety of species to the catalogue,
we quickly ran into species that people were enthusiastic to add,
but lacked many (or most) of the parameters discussed above.
The utility of stdpopsim is to make tricky data easily available for simulation;
such data might be genetic maps, annotations, and/or demographic models.
We have not yet encountered a species with widely-used demographic models but no chromosome-level assembly,
so the main issue in practice seems to be around chromosome-level assemblies and
around matching genome parameters to demographic models.
If chromosome-level assembly is not available,
then we need to either just simulate many, small chunks of genome,
or simulate an anonymous chromosome, not specific to the species.
We could treat each of the many contigs of an assembly as a "chromosome" in stdpopsim.
However, this omits linkage between them (as discussed above),
but more crucially, it would be a significant amount of effort for stdpopsim developers
that wouldn't lower barriers for downstream users much at all. (Gregor: I don't follow the meaning of the above sentence.)
With a great many contigs,
there wouldn't be much difference between a stdpopsim script
and a python script that does many msprime simulations with contig lengths drawn from some list. (Gregor: up to now we have not mentioned msprime at all - should we change this - say, by stating at least a little bit on how stdpopsim works at the start of the tutorial?)
Contig-level assemblies are sometimes annotated, and simulations of regions around specific genes or genomic features (eg. exons) may be of interest.
stdpopsim might make it relatively easy to simulate selection on the genic regions of such contigs,
but it is our opinion that using the precise location of genes on many, unlinked contigs is a false precision:
users would be better off comparing results to simulations of anonymous genomes
chosen to be comparable in some way to their species of interest.
However, there is no clear line for what level of assembly quality is required to be "useful" -
most telling indication is whether there is a community of users eager to use it.

Table of species/demographic scenarios added/worked on by community since original pub

+----------------+----------------+------------------------------+----------------------------------------------------------+
| Species        | Phylum         | New species or demog. model? | Outcome??? (added, abandoned, in quality control, chosen not to add?) |
+================+================+==============================+==========================================================+
| Bos taurus     | Chordata       | Both                         | Added                                                    |
+----------------+----------------+------------------------------+----------------------------------------------------------+
| ...            | ...            | ...                          | ...                                                      |
+----------------+----------------+------------------------------+----------------------------------------------------------+

# Steps to add a species to stdpopsim catalog

In stdpopsim, once all the necessary data (Table 1) for a given species is collected, then its inclusion is dependent upon a peer-reviewed quality control process. If all quality control conditions are met, the species and its simulation framework are added to the catalog. Adding a species to the stdpopsim catalog is beneficial in many ways: (1) it increases the visibility of the species model, (2) it drastically improves the reproducibility of the given model framework, and (3) it allows other researchers to test different model simulations with that particular species. 

The feedback on “Growing the Zoo” hackathon workshops (2020-2021) made it clear that many prospective users of stdpopsim would want to use the stdpopsim for simulating species that are not already in the stdpopsim catalog. Currently there are multiple gaps in the species catalog (Figure XXX, phylogenetic tree or something, 7 chordates, 2 plants (1 vascular, 1 algae), 2 bacteria, 6 arthropods, 1 nematode), and having a greater representation of the tree of life (e.g., by adding plants, yeast, ....) would benefit the stdpopsim community as a whole. 

The steps to successfully add a species to the catalog are as follow:

- Find citeable resources describing the required population and species genetic parameters as detailed in Section XXXX: Making a population genomic simulation."
- Open a GitHub [CITE] account, fork the stdpopsim GitHub repository, and start a pull request by following the steps provided in the "Adding a new species" section of the Development chapter in the stdpopsim docs, currently at https://popsim-consortium.github.io/stdpopsim-docs/stable/development.html?highlight=adding%20species%20catalog#adding-a-new-species"
- Clone your fork locally. This can be done at the commandline using git as:
```
git clone https://github.com/<your_username>/stdpopsim.git
```
using your actual GitHub username in place of ```<your_username>```.

Next, set up a new conda virtual environment [see CITE, for details on how to install], and install the stdpopsim development requirements onto this environment using pip:

```
cd stdpopsim
conda create -n stdpopsim python=3.9 --yes
conda activate stdpopsim
pip install -r requirements/development.txt
```

Further documentation on installation can be found in the "Installation" section of the Development chapter of the stdpopsim docs at https://popsim-consortium.github.io/stdpopsim-docs/stable/development.html#installation.

- Setup the automated code checking/error correction by typing:

```
pre-commit install
```

To demonstrate the steps that it would take to add a species, here we use the species *Anopheles gambiae* (mosquito) as an example.

Our workflow starts with considerations of git as the version control system used by stdpopsim. Our first step will be to create an upstream link to the version of the repository owned by ```popsim-consortium```, then we will create a new branch of stdpopsim using git which will effectively keep track of the new features we will be adding:

```
git remote add upstream https://github.com/popsim-consortium/stdpopsim.git
git fetch upstream
git checkout upstream/main # navigate to the main stdpopsim branch
git checkout -b mosquito # create a new branch for your work, called "mosquito," and navigate to it
```

now any changes that you commit, will be committed to the branch called ```mosquito```.

stdpopsim has a few utilities that play well with Ensembl (@ensembl2021), including one that we will use to create some code templates for us to buildout a new species. This utility lives on the "maintenance" side of stdpopsim, which houses utilities that are not user facing.

To add our species we will hand the maintenance command line interface an Ensembl species ID and it will retrieve some essential information about the genome:

```
python -m maintenance add-species Anopheles_gambiae
```

A partial list of the genomes housed on Ensembl can be found at https://metazoa.ensembl.org/species.html.

The next steps will flesh out the templates that the maintenance code just wrote for us in our ```mosquito``` branch.

The function call above has created a few new files in the directory structure of stdpopsim, in particular at the level of ```stdpopsim/catalog```, including a new directory. This utility has created a new directory called AnoGam, which contains three files. The naming scheme for this directory (and all following references in stdpopsim) is automatically parsed by the maintenance script:

```bash
├── catalog
│   ├── AnoGam
│   │   ├── __init__.py
│   │   ├── genome_data.py
│   │   └── species.py
```

* The script ```__init__.py``` contains information to call the species description (below)
* The script ```genome_data.py``` contains a data dictionary which has slots for the assembly accession number, the assembly name, and a dict representing the chromosome names and their associated lengths.
* The script ```species.py``` file is what we need to edit with our species specific information. The basics that we will need here include:
  * 1) *chromosome-specific* recombination rates (could also be single rate),
  * 2) a genome-wide average *mutation rate*,
  * 3) a *generation time* estimate (in years),  
  * 4) a default *effective population size*, and
  * 5) literature citations that one can point to for the above and the assembly.
  
- Test the code while building the files

```stdpopsim``` in part guarantees code quality through the use of unit testing. Basic sanity tests for this new species will be completed through quality control over in the ```tests/test_AnoGam.py``` file created by the command ```python -m maintenance add-species Anopheles_gambiae``` above.

These tests use the ```pytest``` module. We will quickly run the tests that our maintenance function has set up and expect it to give us an error because we have not yet filled out ```species.py``` with the necessary species information:

```
python -m pytest tests/test_AnoGam.py
```

The test will tell us that the required information entered into this species definition is missing.
Let's add it.

### 1) Recombination rates

As a reference for recombination rates in *Anopheles gambiae* we use a recombination map based on a study from (TODO: add to BibTex file) Pombi et al. (2006). In that manuscript the authors cite rates around 1cM/Mb, with a bit of variation among arms. In particular let's edit the following block of code in ```species.py``` that defines the recombination rate in the simulation:

```
_recombination_rate = {
    "2L": 0, #setting to zero because of inversion 
    "2R": 1.3e-8, 
    "3L": 1.6e-8, 
    "3R": 1.3e-8, 
    "X": 1e-8,
    "Mt": 0
}
```

Every piece of information requires a citable reference. To do that we can create a ```stdpopsim.Citation``` object to the same ```species.py``` file. That object looks like this:

```
_PombiEtAl = stdpopsim.Citation(
    doi="https://doi.org/10.4269/ajtmh.2006.75.901",
    year=2006,
    author="Pombi et al.",
    reasons={stdpopsim.CiteReason.REC_RATE},
)
```

To verify if we have progressed on the tests units, we can type again:

```
python -m pytest tests/test_AnoGam.py
```

### 2) Mutation rates

Editing the species.py file concerning the mutation rate is very similar to the recombination rate. It turns out that there are no great estimates for mutation rate in *Anopheles*, but a recent population genomics effort by the AG1000G consortium (cite) relied on *Drosophila* estimates from (TODO: add to BibTex file) Schrider et al. (2013) that set u=5.49e-9. We'll go with that:

```
_overall_rate = 5.49e-9
_mutation_rate = {
    "2L": _overall_rate,
    "2R": _overall_rate,
    "3L": _overall_rate,
    "3R": _overall_rate,
    "X": _overall_rate,
    "Mt": _overall_rate
}
```

We should also add a citation for the mutation rate:

```
_Ag1000G = stdpopsim.Citation(
    doi="https://doi.org/10.1038/nature24995",
    year=2017,
    author="Ag1000G Consortium",
    reasons={stdpopsim.CiteReason.MUT_RATE, stdpopsim.CiteReason.GEN_TIME, stdpopsim.CiteReason.POP_SIZE},
)
```

### 3) Assembly

We need to add a citation for the assembly. Ensembl points us to this publication for their current assembly by (TODO: add to BibTex file) Sharakhova et al. (2006):

```
_SharakhovaEtAl = stdpopsim.Citation(
    doi="https://doi.org/10.1186/gb-2007-8-1-r5",
    year=2006,
    author="Sharakhova et al.",
    reasons={stdpopsim.CiteReason.ASSEMBLY},
)
```

and all this information is put it together to create the genome object as:

```
_genome = stdpopsim.Genome.from_data(
    genome_data.data,
    recombination_rate=_recombination_rate,
    mutation_rate=_mutation_rate,
    citations=[
        _SharakhovaEtAl,
        _Ag1000G,
        _PombiEtAl,
    ],
)
```

### 4) Population size and generation time

Finally we can edit the species definition in ```species.py``` to include a default population size and generation time:

```
_species = stdpopsim.Species(
    id="AnoGam",
    ensembl_id="anopheles_gambiae",
    name="Anopheles gambiae",
    common_name="Anopheles gambiae",
    genome=_genome,
    generation_time=1/11,
    population_size=6e6, #Ghana population
    citations=[_Ag1000G]
)
```

To test if it works we can type at the command line:

```
python -m stdpopsim AnoGam --help
```

If successfully set, the command above returns a description of the species with details of the species parameters.

To ensure that all is set it is required that all unit tests pass, so test again:

```
python -m pytest tests/test_AnoGam.py
```

If all pass, then it is possible to start a pull request for this species.

### Initiating a Pull Request for your species

Once all the information for the species is included and all unit tests pass, the next step is to commit all changes to the online repository branch and start a pull request on GitHub. 

First we double check we are on our ```mosquito``` branch and things are as they should be:

```
git status
```

and if all good, it is possible to commit with:

```
git add stdpopsim/catalog/AnoGam/*.py
git add tests/test_AnoGam.py
git commit -am "added mosquito genome woot"
```

Having done that, the next step is to push your code to your fork on Github, from which you can start the pull request:

```
git push --set-upstream origin mosquito
```

If successful this will return some output including an URL address to a GitHub page that will allow you to immediately open a new pull request, asking the maintainers of stdpopsim to look over your code.

- Finally, start a new issue using the species quality control template found at https://github.com/popsim-consortium/stdpopsim/issues/new/choose
- Find another stdpopsim contributor (reviewer) to conduct the quality control process
- The quality control process is fully described  at https://popsim-consortium.github.io/stdpopsim-docs/stable/development.html?highlight=adding%20species%20catalog#demographic-model-review-process. In summary:
    - The reviewer creates a creates a blind implementation of the model and species to be added. 
    - The reviewer runs the units tests to verify the equivalence of the catalog and quality control model implementations.
    - The reviewer then creates a pull request, and all being good, this pull request is merged and the quality control issue is closed.
  
It is important to note that the catalog is mutable, if more accurate estimates for a given species are published, then chances are that the catalog will be updated upon a new quality control review process.
    
# Conclusion/take-aways

As our ability to sequence genomes continues to advance, the need for population genomic simulation of new, non-model organism
genomes is becoming more and more acute. 
stdpopsim, as a resource, is uniquely poised to fill this gap as it provides easy access to simulation which 
conditions on species-specific information, easy inclusion of new species genomes, and community-maintained accuracy and correctness. 
Moreover one of our goals is to leverage stdpopsim itself as a springboard for education and inclusion of new communities into
computational biology and software development. 

In this manuscript we present the basic steps required for adding a new species into stdpopsim and then using
that information for simulation. This includes determining if a species-specific population genomic simulation is appropriate for the species and question,
how to get the data required by stdpopsim, how to include that species into the stdpopsim catalog, and how the QC process 
for species inclusion works. Currently large-scale projects such as the Darwin Tree of Life (CITE) project are generating tens of thousands
of genome assemblies-- each of these, with some prior knowledge of mutation and recombination rates, would then be a candidate for
inclusion into the stdpopsim catalog following the steps we have outlined above. As annotation of genome assemblies approve over time
those too can easily be added to the stdpopsim catalog as well. 

We are keen to use outreach, for instance in the form of workshops and hackathons, as a way to democratize development of population
genetic simulation as well as grow the stdpopsim catalog and library generally. 
By enabling non-model researchers with simulation platforms that traditionally have been quite narrowly focused with 
respect to organism, we hope to raise the quality of research across a large number of systems, 
while simultanousely expanding the community of software developers at work in the population and evolutionary genetics world.
Our experience with such outreach over the past two years is that people are indeed keen to to in the time and effort to 
include their favority study species, but that simple, clear guidance was the key-- our intention with this paper is in part to 
provide another learning modality to meet that need. 


# Acknowledgements

TODO Workshop and hachaton attendes?

# Funding

Gregor Gorjanc was supported by the University of Edinburgh and the UK Biotechnology and Biological Sciences Research Council grant to The Roslin Institute (BBS/E/D/30002275).
Andrew D. Kern and Peter L. Ralph were supported by NIH award R01HG010774.
