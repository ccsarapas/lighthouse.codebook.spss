# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-02-05

<!-- 
Added for new features.
Changed for changes in existing functionality.
Deprecated for soon-to-be removed features.
Removed for now removed features.
Fixed for any bug fixes.
Security in case of vulnerabilities.
-->
### Added

- `/MISSINGVALS` subcommand to specify user missing values. This offers greater
    flexibility than SPSS's native user missing value handling. Specifically, it 
    allows:
    - More than three discrete user missing values.
    - Labels for user missing values.
    - Setting the same user missing values across numeric and string variables.

### Changed

- Improved `/SPLITLABELS` documentation and added a walkthrough.

## [0.1.0] - 2026-01-07

- Initial release.