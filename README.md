# qrisk3pexa

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

`qrisk3pexa` is the **server-side** package that hosts the **QRISK3**
cardiovascular risk model on the
[ModelsCloud](https://modelscloud.resp.core.ubc.ca/) cloud modelling platform.
It wraps the [`QRISK3`](https://cran.r-project.org/package=QRISK3) R package and
exposes it through the standard ModelsCloud API.


## Entry points

The functions the Pexa executor calls (the package's only exported surface):

| Function | `funcName` | Description |
|---|---|---|
| `get_sample_input()` | `get_sample_input` | An example patient dataset (runs through `model_run` directly) |
| `get_default_input()` | `get_default_input` | A single baseline patient you can modify |
| `model_run()` | `model_run` (default) | Run QRISK3 → 10-year cardiovascular risk per patient |

`model_run()` accepts either a **named list** (a single patient) or a **data
frame** (one row per patient); the result has one row per input patient, with
the QRISK3 score in the `QRISK3_2017` column.

QRISK3 uses a fixed set of predictors (e.g. `gender`, `age`,
`systolic_blood_pressure`, `cholesterol_HDL_ratio`, `smoke`, `townsend`,
plus a number of binary comorbidity flags) — all are required. The easiest way
to see the full structure is `get_sample_input()` or `get_default_input()`;
build your own inputs by modifying one of those.


## Using the model from R

End users interact with the hosted model through the
[`modelscloud`](https://github.com/resplab/modelscloud) client package. It
defaults to the ModelsCloud server
(`https://api.modelscloud.resp.core.ubc.ca/`), so you only need the model path
and an API key.

```r
# install.packages("remotes")
remotes::install_github("resplab/modelscloud")
library(modelscloud)

# Connect once per session (uses the default ModelsCloud server URL).
# Request an API key from the ModelsCloud team, or set MODELSCLOUD_ACCESS_KEY
# in your .Renviron instead of passing access_key here.
connect_to_model(
  model_path = "resplab/qrisk3",
  access_key = "YOUR_API_KEY"
)

# 1. Fetch a ready-to-run example dataset, then run the model.
input  <- get_sample_input()
result <- model_run(input)
head(result[, c("patid", "QRISK3_2017")])


# 2. Score the first few example patients only.
result <- model_run(get_sample_input(n = 3))

# 3. Run your own patient. Start from the default baseline and change fields.
patient <- get_default_input()
patient$age   <- 65
patient$smoke <- 2
result <- model_run(patient)
```

QRISK3 is a prediction model: every call is **synchronous** — `model_run()`
returns the predicted risks directly.


## Reference

If you use the QRISK3 model, please cite:

> Hippisley-Cox J, Coupland C, Brindle P. Development and validation of QRISK3
> risk prediction algorithms to estimate future risk of cardiovascular disease:
> prospective cohort study. *BMJ*. 2017;357:j2099.
> doi:[10.1136/bmj.j2099](https://doi.org/10.1136/bmj.j2099)

The underlying implementation is the
[`QRISK3`](https://cran.r-project.org/package=QRISK3) R package.


## License

GPL-3 © Mohsen Sadatsafavi
