# techStandards

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable-1)
<!-- badges: end -->

Download and parse technical standard documents


## Introduction

This repository contains functions to download standard documents from the [ETSI website](https://www.etsi.org/standards) and parse standard documents. For related functions (e.g., accessing ITU-T standard documents), see [here](https://github.com/lorenzbr/pystandards).

## Installation

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lorenzbr/techStandards")
```


## Example


```r
library(techStandards)

## Examples

# Download ETSI standard documents
data("etsi_standards_meta")
download_etsi_standards(etsi_standards_meta, path = "")

# Get file names
files <- list.files(system.file("extdata/etsi_examples", package = "techStandards"), 
                    pattern = "pdf", full.names = TRUE)
file <- files[1]

# Set paths
input.path <- "inst/extdata/etsi_examples"
output.path <- input.path

# Parse a single standard document
parse_standard_doc(file, output.path, sso = "ETSI", overwrite = TRUE)

# Parse all standard documents
parse_standard_docs(input.path, output.path, sso = "ETSI", overwrite = TRUE)
```


## What does the standard document parser do?

Technical standards are often described in extremely large documents comprising hundreds and sometimes thousands of pages. This can lead to huge challenges for NLP and ML models dealing with such large texts. Thus, it is helpful to consider smaller parts of a standard and apply your model of choice to those. To select specific chapters, sections or paragraphs of a technical standard, this parser identifies the table of contents of a standard document and searches for the corresponding text using the title of the section and the page number as specified in the table of contents. The output are csv files with the structured text data (full text for each paragraph as outlined in the table of contents). Currently, the text data is also aggregated on chapter level and is stored in a separate txt file. The algorithm is based on regular expressions and excact as well as string similarity matches. While it works very well for most standard, for some, the parsing may fail or may not be that accurate. A log file with further details and messages is also outputted.

The two following pictures show an excerpt of a standard document. Exemplarily, the red boxes highlight some information which is used by the standard document parser.

![toc_example](./inst/figures/toc_example.png)

![fulltext_example](./inst/figures/fulltext_example.png)


## Potential use cases

* Standard essentiality/relevance assessments: fine-grained comparisons of patents with specific technical aspects of a standard
* Track changes of standard documents over time: how does the text change relative to associated declared standard-essential patents?
* Identify which sections of a technical standard have become void
* Find technically similar implementations in other technical standards (e.g., from other standard-setting organizations)
* Identify undisclosed standard-essential patents (e.g., patents filed through blanket declarations or potentially undeclared patents)


## License

This R package is licensed under the MIT license.

See [here](https://github.com/lorenzbr/techStandards/blob/master/LICENSE) for further information.
