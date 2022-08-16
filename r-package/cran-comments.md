## -- R CMD check results -------------------------------------- geobr 1.6.599909 ----
Duration: 3m 49.4s

> checking data for non-ASCII characters ... NOTE
    Note: found 58 marked UTF-8 strings

0 errors v | 0 warnings v | 1 note x

* This is a submission to get the geobr package back on CRAN.

The geobr package was suspended on CRAN on January 2022 because it continuously failed CRAN's policy to "fail gracefully" when there are any internet connection problems.

We have scrutinized the package, which has now gone through structural changes to address this issue. Here are the main changes:
1. New internal function `check_connection()` and tests that cover cases when users have no internet connection, whem url links are offline, time out or work normally.
2. All functions that require internet connection now use `check_connection()` and return informative messages when url links are offline or timeout.
3. The data used in the package is now simultaneously stored in two independent servers, where one of them is used as a backup link. In other words, the geobr will download the data from server 1. If, for some reason, the download fails because of internet connection problems, then geobr tries to download the data from server 2. If this second attempt fails, then the package returns `invisible(NULL)` with an informative message.

We believe these changes and the redundancy in data storage have made the geobr package substantially more robust and in line with CRAN's policies.

