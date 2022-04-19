            
Meeting notes:

19 April 2022:
Update on the "adding species" manuscript (Elise):
- Andy has added conclusions
- Elise to do a first pass to "full document" this afternoon; after those are up, invites further edits
- timeline: depends how involved everyone wants to be!
- we will then need a final journal decision and cover letter
Andy: can we switch to LaTeX? There were issues with unicode characters.
Elise: no objections
Andy: i will switch it over.
Peter: Are we leaving in those code blocks? That is a big section with code for "how to add a species", but we're not saying in the paper that everyone should go add their own species, right now.
Elise: We were putting this in to show people where they put in the pieces they need to put in. It's a simple walk-through of what you want to include in more detail; hoping people can extrapolate from that stdpopsim code block to other contexts.
Ryan: One question is how quickly this will get outdated? In two years will it all be different?
Elise: Well, they might well, because we're proposing switching to YAML.
Andy: Maybe a good thing to do is to include it but as supplemental material, and say up front that this is our April 2022 tutorial, subject to drift.
  A nice thing would be to communicate with the journal and ask to update the document.
Elise: In theory, shouldn't the stdpopsim docs stay updated, so that'd be the place to go.
Andy: A slick thing to do would be to put the tutorial as markdown as a supp file, with a link at the top to the github docs; so we'd update only the docs.
Elise: We could in that section shorten it to "details in the supplement; here's what we do in general".
Peter: It'd be nice to have a few example code chunks, showing how easy it is to add; just doesn't need to be comprehensive.
Andy: Maybe a good heading could be "workflow".

Chris: I noticed that
----> the instructions in the docs for adding a species need to be updated!
Elise: Also, the 
-----> catalogue needs to be updated!
How? Just go through the open issues? If there's code in the `qc/` directory does it mean that it's resolved?
Ilan: There could be partially resolved species, e.g., BosTau, I think? The safest thing is to look at closed issues.
Elise: I will
---> dig through those and make a list of things that seem to be still hanging. Izabel maybe started this already.

Peter: input on "Whole-genome simulations: when do we need them?"
Ilan: is the point here "why do we need stdpopsim"
Peter: yep, that's right.
Elise: or more generally, why do you need to run whole-chromosome sims (with annotations, demographic histories, etcetera) versus anonymous 1Mb chunks.
Ilan: right; well, another benefit of stdpopsim is the curated demographic models. Do we want to broaden this section to highlight other benefits?
Elise: Maybe "How realistic do we need our simulations to be?" One question here is how much we need to steer this paper towards "utility of stdpopsim" versus "you've got a species that you wnat to simulate; when is it practical or necessary to do that".
Ilan: Demographic models are part of it, and has been a challenge.
Elise: That's not just a benefit of stdpopsim, it's a general good thing to do.
Ilan: But it is a benefit of a QC'ed, centralized place to get demographic models. We've seen in QC a number of times that issues have come up and been caught. All of these are benefits.
Ryan: This raises the question of "what's in stdpopsim"; e.g., what about the species with 20K contigs, or RADseq data; one of the hardest parts is having the assembly.
Peter: maybe this could be 
----> in a section titled "On the utility of working together"
Elise: How much do we want this paper to be justfying choices made for stdpopsim versus advocating for adding to stdpopsim? I like the idea of talking about 'working together', which applies to other efforts (even just encouraging people to do code review).
Ryan: The demes paper is getting close, and that problem will get a lot easier.
Elise: there's a mention of demes; hopefully we can cite it!
Elise: Are folks comfortable with the idea of adding a section on the importance of getting implementations correct?
(yes!)
Ryan: Another reason for why to to do whole-genome simulations: sometiemes you want to compare *directly* with the data, e.g., compare directly to genome features. Ex: in Shay 2016a we did that
---> TODO: add discussion of this to the "when do we need whole-genome simulations" section.
Andy: Murillo also has an example of this, but it's unpublished.

Elise: What journal are we going for again? In March we said: eLife (tools/resources), Mol Ecol or MER or MBE (protocols/letters)
Andy: with eLife the deal is that if you have "methods updates" then they'll let you publish? (looking for it now)
Peter: maybe eLife is more high-profile, but ME or MER is really natural?
Ryan: it doesn't matter for me, but for junior folks we should maybe go for the higher profile?
Ryan: eLife has a section about "research advances", a short article allowing folsk to publish something short building on the original one in an important way.
Andy: so the thing to do is to reach out to the editor (as first author) about a "research advance" connected to the original paper
Peter: what's "short"?
Ryan: actually they look normal length

TODO:
---> make list of and email potential co-authors (start on the slack channel)

Andy: authorship proposal is
- everyone who submitted a species (even un-QC'ed species)
- everyone who helped run workshops
- people who contributed in meetings talking about these thigns
- we err on the side of inclusion
Elise: we can also ask on Slack

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

