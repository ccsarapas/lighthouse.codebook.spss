# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-02-16

### Added

- `/MISSINGVALS` subcommand to specify user missing values. This offers greater
    flexibility than SPSS's native user missing value handling. Specifically, it 
    allows:
    - More than three discrete user missing values.
    - Labels for user missing values.
    - Setting the same user missing values across numeric and string variables.

- Options to group numeric and/or categorical summary tabs by rows by using the 
    `/GROUP` subcommand with the `ROWS`, `ROWSNUM`, or `ROWSCAT` parameters.

- Check for minimum required version of lighthouse.codebook package.

### Changed

- `/BY` is no longer a subcommand; it is now a parameter for the `/GROUP` subcommand,
    along with the new `ROWS`, `ROWSNUM`, and `ROWSCAT` parameters.

- Improved `/SPLITLABELS` documentation and added a walkthrough.

## [0.1.0] - 2026-01-07

- Initial release.