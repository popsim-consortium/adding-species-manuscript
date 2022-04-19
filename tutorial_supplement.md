---
  title: 'Tutorial supplement'
---
  
Live link: https://popsim-consortium.github.io/stdpopsim-docs/stable/development.html?highlight=adding%20species%20catalog#adding-a-new-species

The steps to successfully add a species to the catalog are as follow:
  
Find citeable resources describing the required population and species genetic parameters as detailed in Section XXXX: Making a population genomic simulation."

Open a GitHub [CITE] account, fork the stdpopsim GitHub repository, and start a pull request by following the steps provided in the "Adding a new species" section of the Development chapter in the stdpopsim docs, currently at https://popsim-consortium.github.io/stdpopsim-docs/stable/development.html?highlight=adding%20species%20catalog#adding-a-new-species"
These steps as they stand in April 2022 are described in detail in the supplementary material, but are subject to change as the stdpopsim framework improves.

Clone your fork locally. This can be done at the commandline using git as:
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

Setup the automated code checking/error correction by typing:
  
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
  
  ```
├── catalog
│   ├── AnoGam
│   │   ├── __init__.py
│   │   ├── genome_data.py
│   │   └── species.py
```

* The script ```__init__.py``` contains information to call the species description (below)
* The script ```genome_data.py``` contains a data dictionary which has slots for the assembly accession number, the assembly name, and a dict representing the chromosome names and their associated lengths.
* The script ```species.py``` file is what we need to edit with our species specific information. The basics that we will need here include:
1) *chromosome-specific* recombination rates (could also be single rate),
2) a genome-wide average *mutation rate*,
3) a *generation time* estimate (in years),  
4) a default *effective population size*, and
5) literature citations that one can point to for the above and the assembly.

Test the code while building the files

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

Finally, start a new issue using the species quality control template found at https://github.com/popsim-consortium/stdpopsim/issues/new/choose
- Find another stdpopsim contributor (reviewer) to conduct the quality control process
- The quality control process is fully described  at https://popsim-consortium.github.io/stdpopsim-docs/stable/development.html?highlight=adding%20species%20catalog#demographic-model-review-process. In summary:
    - The reviewer creates a creates a blind implementation of the model and species to be added. 
    - The reviewer runs the units tests to verify the equivalence of the catalog and quality control model implementations.
    - The reviewer then creates a pull request, and all being good, this pull request is merged and the quality control issue is closed.
  
It is important to note that the catalog is mutable, if more accurate estimates for a given species are published, then chances are that the catalog will be updated upon a new quality control review process.
