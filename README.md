# R interface to the IEU GWAS database API

<!-- badges: start -->
<!-- badges: end -->

R interface to the IEU GWAS database API. Includes a wrapper to make generic calls to the API, plus convenience functions for specific queries.

## Installation

You can install the released version of ieugwasr from [CRAN](https://CRAN.R-project.org) with:

``` r
devtools::install_github("mricue/ieugwasr")
```

## Usage

### General API queries

The API has a number of endpoints documented [here](http://ieu-db-interface.epi.bris.ac.uk:8082/docs/). A general way to access them in R is using the `api_query` function. There are two types of endpoints - `GET` and `POST`. 

- `GET` - you provide a single URL which includes the endpoint and query. For example, for the `association` endpoint you can obtain some rsids in some studies, e.g.
    + `api_query("associations/IEU-a-2,IEU-a-7/rs234,rs123")`

- `POST` - Here you send a "payload" to the endpoint. So, the path specifies the endpoint and you add a list of query specifications. This is useful for long lists of rsids being queried, for example
    + `api_query("associations", query=list(rsid=c("rs234", "rs123"), id=c("IEU-a-2", "IEU-a-7")))`

### Authentication

Most datasets in the database are public and don't need authentication. But if you want to access a private dataset that is linked to your (gmail) email address, you need to authenticate the query using a method known as Google OAuth2.0.

Essentially - you run this command `get_access_token()` which will open up a web browser asking you to provide your google username and password, and upon doing so a file will be created in your working directory called `mrbase.oauth`. This file contains your access token, and it's like a convenient way to hold a randomly generated password.

If you are using a server which doesn’t have a graphic user interface then this method is not going to work. You need to generate the `mrbase.oauth` file on a computer that has a web browser, and then copy that file to your server (to the relevant work directory).

If you are using R in a working directory that does not have write permissions then this command will fail, please navigate to a directory that does have write permissions.

If you need to run this in a non-interactive script then you can generate the mrbase.oauth file on an interactive computer, copy that file to the working directory that R will be running from, and then run a batch (non-interactive).


### Convenient wrappers for `api_query`

It can be cumbersome to generate the query manually, so here are some convenient functions to run various operations

### Get API status

```r
api_status()
```

### Get list of all available studies

```r
gwas_info()
```

### Get list of a specific study

```r
gwas_info("IEU-a-2")
```

### Extract particular associations from particular studies

```r

```

proxies

### Get tophits from study

clumping


### Perform PheWAS


### LD clumping

Through API

Local

### LD matrix

Through API

Local

### Variant information

chrompos and rsid

gene

regions

