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

# Outline

1.  Overall goals and structure of stdpopsim

    -   stdpopsim is a community-maintained resource intended to provide easy access to simulation frameworks

        -   coding population genetic simulation models can be arduous and error-prone, so stdpopsim provides a way to:

            -   avoid re-making common models
            -   provide standard benchmarks for methods development and testing

        -   and a resource for empirical researchers, eg. power analyses or sanity checks (Adrion et al. 2020)

    -   feedback from 2020/2021 workshops made it clear that the prospective community included empiricists who are especially concerned with using stdpopsim for inference for individual species that mostly not already in stdpopsim catalog

2.  **ELISE** Community-based expansion of the number and variety of species and their demographic scenarios included in the stdpopsim catalog is useful for both of these major goals shared by the population genetics community, methods development and inference 

    -   when first published, the stdpopsim catalog included 6 species: *Homo sapiens*, *Pongo abelii*, *Canis familiaris*, *Drosophila melanogaster*, *Arabidopsis thaliana*, and *Escherichia coli.*

        -   when did additional demographic scenarios start getting added?

    -   in April 2021 we held a "Growing the Zoo" hackathon to involve the community in adding additional species and demographic scenarios of interest

        -   the catalog now includes an additional **12** species (note: is this correct, number is from those on main branch)? the catalog doc still only includes the original 6? - MEL), as well as multiple demographic scenarios for *Homo sapiens*, *Pongo abelii*, *Drosophila melanogaster*, and *Arabidopsis thaliana.* (others?)
        -   however there were some species that were not ideal for inclusion in the catalog, because they don't yet have the necessary genomic resources

    -   stdpopsim has become a popular resource and there is clearly a desire/need for adding additional species for both goals of methods development and empirical inference

        -   choosing species/demographic scenarios to add is potentially challenging
        -   for methods development, they have to be appropriate for the goals of the method
        -   for empirical studies, the species is obvious, but whether it is appropriate for inclusion in the catalog or even to use stdpopsim may be less clear

3.   **ELISE** Therefore this paper is intended as a resource for both methods developers and empirical researchers to choose and add appropriate species (and demographic scenarios) to the stdpopsim catalog

    -   builds off the "Growing the Zoo" hackathon, held along side probgen in April 2021

        -   what we learned from the hackathon (and workshops)?

            -   people want a lot of different species, yay! and a variety! but often for specific use cases, especially inference
            -   people are willing to put in the time and effort to add species, when given clear guidance for how to do it
            -   not all species that people want to add have appropriate genomic resources yet, and more clarity in what resources are necessary is needed for the community

    -   therefore in this paper we present the current method for adding species and demographic scenarios to the catalog and clarify the required genomic resources

4.  **Izabel**  Adding species/demographic scenarios to the catalog
 

To include a species into the stdpopsim catalog it is required that the species has at least: 
- (1) a **genome assembly**, with contigs being assembled at the chromosome level or nearly so. By using chromosome level information to simulate genomes,  stdpopsim indirectly simulates the effect of linked selection. [maybe discussion next text -> ] In the near future this won't be a problem for multiple species, since with (i) the advent of long-read sequencing technologies [ref] and because of (ii) initiatives such as B10K, XXXX, and G10K near XXX error-free reference genome assemblies [Rhie et al, 2021, REF, REF] spanning more than XXX vertebrate species are expected to be generated.  
- (2) It is also required that the species has a plausible and citeable **mutation rate** estimate. Both phylogenetic mutation rate [ref], germline *de novo* mutations, or mutation rates estimates based on mutation accumulation studies [ref] are welcomed. [commment: using the mutation rate of a closely related species is not a big deal, either??? I know you guys use the drosophila one for the anopheles].
- (4) Since both mutation and recombination shape the genetic diversity of genomes, stdpopsim also requests a **recombination rate** estimate for the species. Ideally, a chromosome level recombination map--e.g., allowing to more precisely infer the effect of selective interference--or at least a citeable single recombination rate estimate.
- (3) A generation time estimate (in years).
- (5) Population-size history also shapes the levels of diversity in a given population/genome. For this reason, to accurately simulate genomes, stdpopsim also expects that the species has a citeable **demographic model**, or at least a plausible and citeable **effective population size** (Ne).

Users can also add other attributes of a species to the catalog that are not strictly required but are useful when simulating genomes, such as:
- (6) **Genome annotation**, such as a GFF3/GFF format [ref] containing information about the coordinates of coding and noncoding regions; and the position of specific genes. 
- (7) A citeable **distribution of fitness effects** (DFE, REF) for the species. This feature is particularly useful when simulating genomes under non-neutral models. 

Extra: annotation and DFE
    -   necessary resources:

        -   genome assembly

            -   this needs to be chromosome level, or nearly so

            -   contigs are not sufficient because:

                -   lack of linkage information limits their use for inference
                -   current limitations to the Python API/command line (eg. it complicates displaying and choosing what chromosome (contig) to use)
                -   current limitations on how the catalog is deployed (eg. all species go with stdpopsim when installed, adding a million contigs would make that more difficult for people who don't need them)

        -   a plausible, citeable mutation rate

        -   recombination map - or at least a plausible, citeable, recombination rate

        -   a citeable demographic model, or at least a plausible, citeable, effective population size

        -   annotations (required if the use case involves coding/noncoding regions, specific genes, etc.)

        -   an actual human being(s) willing to put in the time and effort to

            -   find and evaluate the necessary information and citations
            -   code it (see description of the process below and "Adding Species" worshop materials on github)
            -   shepherd it through the QC process (see below)

    -   what about species that don't have some of those resources?

        -   if everything is available except the genome is contig-level:

            -   could potentially add the species locally for personal use, but it won't become part of the catalog or go through the QC process (note: this is something we had discussed in meetings, I don't know if we reached a final consensus - MEL)

                -   would want to choose just a few of the most important or longest contigs to simulate
                -   reviewers would need to understand that while the stdpopsim architecture is used, the species model itself has not passed the community review process

            -   might be more appropriate to just simulate a locus of appropriate length using one of the available simulation programs (msprime, SLiM) instead of using stdpopsim

5.  Examples from "Zoo" hackathon

    -   A species that was fully added (Bos taurus?)

        -   resources available
        -   reasons for adding
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

6.  Steps to add a species

    -   find required resources and citations (chromosome-level assembly, mutation rate, recombination rate or map, Ne or demog. model, annotations)
    -   add code - detailed steps, reference workshop materials on github as well
    -   QC - details steps
    -   update catalog documentation?

7.  Current gaps in types of species in catalog

    -   7 chordates, 2 plants (1 vascular, 1 algae), 2 bacteria, 6 arthropods, 1 nematode

    -   lots of potential for supporting methods development for other types of organisms (that aren't vertebrates and insects)

        -   eg. yeast
        -   eg. more plants because plants have goofy genomes

8.  Interest for inference for a wide variety of species

    -   there are lots of good assemblies out there these days and efforts to generate more (eg. Genome10K - this is just vertebrates)

    -   if this continues to be a major goal of the community/use case, could there be enough support to develop methods for individual users to add species locally?

        -   eg. proposed YAML process to make it easier to add species and choose contigs if necessary
        -   would need to emphasize that species that haven't gone through the QC process haven't been reviewed by the stdpopsim community and should be evaluated as such during peer review for publication

    -   but developing species models for inclusion needs to be community-driven and maintained

9.  Take-aways

    -   stdpopsim is a community-maintained resource intended to provide easy access to simulation frameworks, adding species expands the types of methods development and inference it is useful for
    -   potential to make stdpopsim more accessible for the part of the population genetics community that is more concerned with inference

# Meeting notes:

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
