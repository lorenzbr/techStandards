# techStandards

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable-1)
<!-- badges: end -->

Repository of functions focusing on technical standards


## Installation

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lorenzbr/techStandards")
```


## Example


```
library(techStandards)

## Examples

# Download ETSI standard documents
data("etsi_standards_meta")
download_etsi_standards(etsi_standards_meta)

# Parse single standard document
files <- list.files(system.file("extdata/etsi_examples", package = "techStandards"), 
                    pattern = "pdf", full.names = TRUE)
file <- files[1]
parse_standard_doc(file, path = "inst/extdata/etsi_examples", sso = "ETSI", overwrite = TRUE)

# Parse all standard documents
parse_standard_docs(path = "inst/extdata/etsi_examples", sso = "ETSI", overwrite = TRUE)
```


## Contact

Please contact <lorenz.brachtendorf@gmx.de> if you want to contribute to this project.

You can also submit bug reports and suggestions via e-mail or <https://github.com/lorenzbr/cryptowatchR/issues> 


## License

This R package is licensed under the GNU General Public License v3.0.

See [here](https://github.com/lorenzbr/cryptowatchR/blob/main/LICENSE.md) for further information.
