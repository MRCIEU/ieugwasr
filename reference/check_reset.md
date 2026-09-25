# Check if OpenGWAS allowance needs to be reset

This function checks if a recent query indicated that the OpenGWAS
allowance has been used up. To prevent the IP being blocked, it will
error if the new query is being submitted before the reset time. If the
allowance has been used up, it displays a message indicating the time
when the allowance will be reset. By default, the function will throw an
error if the allowance has been used up, but this behavior can be
overridden by setting `override_429` to `TRUE`.

## Usage

``` r
check_reset(override_429 = FALSE)
```

## Arguments

- override_429:

  Logical value indicating whether to override the allowance reset check
  (default: `FALSE`)
