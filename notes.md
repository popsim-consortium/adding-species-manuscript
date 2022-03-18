            
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

