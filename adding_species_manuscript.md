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

Abstract

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
1.  Simulation is important for population genomics, both methods development and inference **PARTLY RYAN**
    - there is a building avalanche of genomic data for a variety of species, and a complementary flourishing of methods for population genomic inference
        - so the number and variety of species requiring detailed and accurate simulation models is increasing quickly
    -   coding population genetic simulation models can be arduous and error-prone, but important
        -   provide training data for machine learning, ABC
        -   for both methods development and empirical research
        - "accurate" includes realistic demographic models and genetic maps as both can strongly impact the patterns of variation and haplotype/linkage
    - stdpopsim is a tool recently developed to provide easy access to simulation frameworks
        -   avoid re-making common models
        -   provide standard benchmarks for methods development and testing (see Adrion et al.)
        -   improves reproducibility
        - lower the barrier to technical coding skills
        - but so far stdpopsim has been mainly restricted to well-characterised model organisms, limiting utility for non-model organisms or model organisms in the early stages of development
    - many potential users want to simulate their study organism, or develop inference methods for non-model organisms
        -   feedback from 2020/2021 stdpopsim workshops emphasized the need for simulations of a wide variety of model and non-model species

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
3.   Making a popgen simulation
    - what's important about whole genome sims, and when they're not important **PETER**
        - https://github.com/popsim-consortium/adding-species-manuscript/pull/6#discussion_r822738958
To include a species into the stdpopsim catalog it is required that the species has at least: 
- (1) a **genome assembly**, with contigs being assembled at the chromosome level or nearly so. By using chromosome level information to simulate genomes, stdpopsim indirectly simulates the effect of linked selection. [maybe discussion next text -> ] In the near future this won't be a problem for multiple species, since with (i) the advent of long-read sequencing technologies [ref] and because of (ii) initiatives such as B10K, XXXX, and G10K near XXX error-free reference genome assemblies [Rhie et al, 2021, REF, REF] spanning more than XXX vertebrate species are expected to be generated.  
- (2) It is also required that the species has a plausible and citeable **mutation rate** estimate. Both phylogenetic mutation rate [ref], germline *de novo* mutations, or mutation rates estimates based on mutation accumulation studies [ref] are welcomed. [commment: using the mutation rate of a closely related species is not a big deal, either??? I know you guys use the drosophila one for the anopheles].
- (3) Since both mutation and recombination shape the genetic diversity of genomes, stdpopsim also requires a **recombination rate** estimate for the species. Ideally, this should be a chromosome level recombination map, which allows more precise inference of the effect of selective interference. At minimum, a citeable single recombination rate estimate for the whole genome.
- (4) A generation time estimate (in years).
- (5) Population-size history also shapes the levels of diversity in a given population/genome. For this reason, to accurately simulate genomes, stdpopsim also expects that the species has a citeable **demographic model**, or at least a plausible and citeable **effective population size** (Ne).

Users can also add other attributes of a species to the simulation that are not strictly required but can be useful, such as:
- (6) **Genome annotation**, such as a GFF3/GFF format [ref] containing information about the coordinates of coding and noncoding regions; and the position of specific genes. 
- (7) A citeable **distribution of fitness effects** (DFE, REF) for the species. This feature is particularly useful when simulating genomes under non-neutral models. 
    - draw from https://github.com/popsim-consortium/workshops/blob/main/adding_species/contributing.ipynb without specifics for stdpopsim 
    - emphasize throughout that these features should be citeable and chosen with deliberation **PETER**
        - eg. "often reported parameter values are tied to a model and its other parameters, so mixing values from different sources has its own caveats" (https://github.com/popsim-consortium/adding-species-manuscript/issues/7)
    - what about species that don't have some of those resources? **PETER**
        - if everything is available except the genome is contig-level (and no recombination map):
            -   would want to choose just a few of the most important or longest contigs to simulate
            -   https://github.com/popsim-consortium/adding-species-manuscript/issues/1#issuecomment-1050081855
            -   might be more appropriate to just simulate a locus of appropriate length
Table of "what if one of the features above required are missing" **IZABEL**

| missing parameter 	| options 	| considations 	|
|---	|---	|---	|
| mutation rate 	| borrow from closest relative with citeable rate? 	| will affect estimates of (timing in years, ...) 	|
| recombination rate 	| borrow from closest relative with citeable rate? 	| will affect patterns of (selection/linkage, ...) 	|
| a good assembly 	| select the largest/most contiguous contigs, and/or those with genes/regions of interest if known 	| consider just simulating a locus of appropriate length if you don't somehow have a recombination map or a gene(s) or other loci of interest with known contig location 	|
| demographic model 	| need at least N<sub>e</sub> 	| bottlenecks/expansions/admixture can affect a lot of patterns of variation, etc. 	|
| N<sub>e</sub> 	| population genomic simulation not practical? 	| (I'm not sure there's much you can do here except pick something vaguely reasonable and pray, not exactly what we want to promote - MEL) 	|

# Application/Discussion   
4. **ELISE** Lessons from "Growing the Zoo" hackathon, held along side probgen in April 2021
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

5.  Examples from "Zoo" hackathon
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

Table of species/demographic scenarios added/worked on by community since original pub

+----------------+----------------+------------------------------+----------------------------------------------------------+
| Species        | Phylum         | New species or demog. model? | Outcome??? (added, abandoned, in QC, chosen not to add?) |
+================+================+==============================+==========================================================+
| Bos taurus     | Chordata       | Both                         | Added                                                    |
+----------------+----------------+------------------------------+----------------------------------------------------------+
| ...            | ...            | ...                          | ...                                                      |
+----------------+----------------+------------------------------+----------------------------------------------------------+

6.  Steps to add a species to stdpopsim catalog
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
            
Meeting notes:

08 March 2022:

-   there is discussion about "what if the species has lots of contigs; what if no mutation rate"; thought is to add a "what is required" section, then "what if they don't have those thing, what do we do?"
-    then, give an example of Bos taurus
-    and add description of checklist for adding a species (from workshop)
-    whatever has not been said in the pieces so far we can put in the Discussion, e.g.
    * this is important as it's a place where info gets peer reviewed
    * and other benefits of adding species
    * and future YAML idea
- question: where do the "typical use cases" go in? Maybe in the introduction?
  * refer to original paper
  * testing/benchmarking software
  * hypothesis generation
  * training ML methods
  * able to do simulation-based prediction (of e.g., bottlenecks in endangered species)
  * reproducibility
  * background demographic simulations for scans for sweeps
  * provide distribiution of stats under neutrality (ie null distribution)
    - --> note that it's important to have chromosome-scale genetic maps to provide appropriate null distribution, esp of haplotype statistics, with low recombination
    - --> good example is maybe the chr22 low recombination chunk
- what goes in "steps to add a species" bit? maybe "typical workflow"?
  - --> Peter to provide input to PR #6 on outline

Fall 2021:

-   recap goals and structure of stdpopsim
    -   two sets of goals:
        -   methods development/testing
        -   inference (this is perhaps the major goal this paper is addressing?)
        -   arguably adding species opens stdpopsim to the community whose primary concern is inference rather than methods development

-   discussion of resources necessary to simulate/add species
    -   recombination map
    -   annotation
    -   assembly
        -   not just contigs
    -   demographic model?
        -   at least reasonable Ne
-   discussion of types of species in terms of:
    -   available resources
    -   what goal adding the species would address
-   description of how to add a species to the catalog and/or write a yaml for a new species
    -   this will depend on how we're ultimately moving forward - using the current python-based method, or switching to a yaml-based method
