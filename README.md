# LIGHTHOUSE CODEBOOK Extension Command

The `LIGHTHOUSE CODEBOOK` extension command provides an SPSS interface to the [lighthouse.codebook](https://github.com/ccsarapas/lighthouse.codebook) R package. The command generates an Excel 
workbook containing a codebook and variable summaries based on either the active 
dataset or a specified data file.

## Installation

Installation requires two steps. 

1. Install the `LIGHTHOUSE CODEBOOK` extention bundle:
    * Download the "LIGHTHOUSE_CODEBOOK.spe" extension bundle from the most recent release [here](https://github.com/ccsarapas/lighthouse.codebook.spss/releases/latest).
    
    * In SPSS Statistics, navigate to Extensions -> Install Local Extension Bundle...
    
    * Browse to and select the downloaded extension bundle.

2. Install the `lighthouse.codebook` package and other dependencies into SPSS's
R environment by running:
    ```stata
    LIGHTHOUSE CODEBOOK /INSTALL.
    ```
    You will only need to do this the first time you use the command, or when updating to a new version. You do _not_ have to do this every session.

## Usage

```stata
LIGHTHOUSE CODEBOOK
  OUTFILE = 'save/path.xlsx'
  /DATA
     NAME = 'dataset name'
     FILE = 'data/path.sav'
  /GROUP 
     BY = varlist
     ROWS = varlist
     ROWSNUM = varlist
     ROWSCAT = varlist
  /MISSINGVALS varlist ([label = ]value[, ...]) [varlist ...]
  /SPLITLABELS varlist
  /OPTIONS
     OPEN          = {YES**, NO}
     DETAILMISSING = {IFANY**, YES, NO}
     NTEXTVALS     = {5**, integer}
     RMVHTML       = {YES**, NO}
     RMVLINEBREAKS = {YES**, NO}
     HYPERLINKS    = {YES**, NO}
     OVERWRITE     = {YES**, NO}
  /INSTALL
```
All arguments are optional.

* **OUTFILE**: Path to write codebook to. May be omitted if `OPEN = YES` (which is 
the default), in which case the codebook will be written to a temporary file and 
immediately opened in Excel.

**/DATA Subcommand**

* **NAME**: Dataset name to include in codebook.

* **FILE**: Path to an SPSS data file to be summarized. If omitted, the active dataset
will be used. (With very large files, it can be faster to specify a data path instead 
of using the active dataset.)

**/GROUP Subcommand**

* **BY**: List of variables to group by. If specified, additional numeric and categorical 
summary tabs will be included with grouped summaries. Subgroups will be shown in 
columns by default. Some or all grouping variables can instead be shown in rows 
if specified using the `ROWS`, `ROWSNUM`, or `ROWSCAT` parameters. [_See walkthrough 
and examples._](#GROUP-Subcommand)

* **ROWS**: List of variables to group by in rows on grouped summary tabs. Note 
that all variables included in `ROWS` must also be included in `BY`. This will apply 
to both numeric and categorical summary tabs unless otherwise specified using the
`ROWSNUM` or `ROWSCAT` parameters.

* **ROWSNUM**: List of variables to group by in rows on grouped _numeric_ summary 
tabs. Note that all variables included in `ROWSNUM` must also be included in `BY`.

* **ROWSCAT**: List of variables to group by in rows on grouped _categorical_ summary 
tabs. Note that all variables included in `ROWSCAT` must also be included in `BY`.

**/MISSINGVALS Subcommand**

* Values, optionally with labels, to treat as user missing for specified variables. 
[_See walkthrough and examples._](#MISSINGVALS-Subcommand)

**/SPLITLABELS Subcommand**

* List of variables whose labels begin with a common stem that should be extracted 
into a separate column. (For example, 5 variables whose labels all begin with "Select 
all that apply: "). Multiple sets of variables whose labels begin with different 
stems can be specified by enclosing each set in parentheses. [_See walkthrough and 
examples._](#SPLITLABELS-Subcommand)

**/OPTIONS Subcommand**

* **OPEN**: Should the codebook be immediately opened in Excel?

* **DETAILMISSING**: Include detailed missing value information on categorical and 
text summary tabs?

* **NTEXTVALS**: On the text summary tab, how many unique non-missing values should 
be included for each variable? (Additional unique values will be collapsed.)

* **RMVHTML**: If `YES`, HTML tags (e.g., "&lt;i&gt;", "&lt;strong&gt;") will be removed from 
variable and value labels.

* **RMVLINEBREAKS**: If `YES`, line breaks in variable and value will be replaced 
with " / ".

* **HYPERLINKS**: If `YES`, variable names on the Overview sheet will link to 
corresponding rows on summary tabs and vice versa.

* **OVERWRITE**: Overwrite existing codebook file?

**/INSTALL Subcommand**

* If present, will install or update the `lighthouse.codebook` package and dependecies 
  into SPSS's R environment. No codebook will be generated and all other arguments
  will be ignored when `/INSTALL` is present.

## Examples and Walkthroughs

### Codebook Creation and Basic Options

```stata
* Create codebook with default settings and no grouping. Will be saved to temp
* directory and opened in Excel.
LIGHTHOUSE CODEBOOK.

* Create codebook with name and save to specified path.
LIGHTHOUSE CODEBOOK
  OUTFILE = 'C:/Users/username/My Folder/codebook.xlsx'
  /DATA NAME = 'Project Dataset'.

* Create codebook from existing file; don't include hyperlinks; change
* number of text values shown; don't open in Excel.
LIGHTHOUSE CODEBOOK
  OUTFILE = 'C:/Users/username/My Folder/codebook.xlsx'
  /DATA
    FILE = 'C:/Users/username/My Folder/data.sav'
    NAME = 'Project Dataset'
  /OPTIONS
    OPEN = NO
    HYPERLINKS = NO
    NTEXTVALS = 10.
```

### GROUP Subcommand

Numeric and categorical data summaries can be grouped by one or more variables by 
specifying them in the `GROUP` subcommand.

```stata
* use the BY parameter to specify grouping variables.
LIGHTHOUSE CODEBOOK
  /GROUP BY = treatment_group timepoint.
```

By default, values for each subgroup are shown in separate columns, with decked 
heads if more than one grouping variable is specified. However, some or all grouping 
variables can instead be shown in rows using the `ROWS` parameter.

```stata
* show `treatment_group` in columns and `timepoint` in rows.
* note all grouping variables must still be included in `BY`.
LIGHTHOUSE CODEBOOK
  /GROUP 
    BY = treatment_group timepoint
    ROWS = timepoint.
```

Different row grouping behavior can be specified for numeric versus categorical 
summary tabs using the `ROWSNUM` and `ROWSCAT` parameters.

```stata
* on numeric summary tab, show `treatment_group` in columns and `timepoint` in rows;
* but on categorical summary tab, show all grouping variables in columns.
LIGHTHOUSE CODEBOOK
  /GROUP 
    BY = treatment_group timepoint
    ROWSNUM = timepoint.

* for numeric summary, show all grouping variables in rows; 
* for categorical summary, show `treatment_group` in rows.
LIGHTHOUSE CODEBOOK
  /GROUP 
    BY = treatment_group timepoint
    ROWSNUM = treatment_group timepoint
    ROWSCAT = treatment_group.
```

### MISSINGVALS Subcommand

User missing values can be defined in the usual way (i.e., using the `MISSING VALUES` command or the Variable View tab) and will be appropriately handled by `LIGHTHOUSE CODEBOOK`. However, they can also be defined using the `MISSINGVALS` subcommand, which offers greater flexibility than SPSS's native user missing value handling. Specifically:
* An unlimited number of discrete missing values can be specified (whereas SPSS allows only three).
* Labels can be assigned to user missing values and will appear in codebook summaries. (e.g., `Confidential = -6, Refused = -7`.)
* The same user missing values can be set across numeric and string variables, with automatic conversion to the appropriate type. (e.g., if `-3` is specified, it will be applied to numeric variables as `-3` and to string variables as `"-3"`.) Variable types not compatible with user missing values (e.g., dates) will be ignored.

```stata
* basic usage.
LIGHTHOUSE CODEBOOK
  /MISSINGVALS numeric1 TO numeric5 (-9, -8, -7, -6, -5)
              /numeric9 string12 string18 (-8, -3, -2, -1).

* specifying user missings with labels.
LIGHTHOUSE CODEBOOK
  /MISSINGVALS IDScr1 TO CVScr5 ("Legitimate Skip" = -9,
                                 "Don't Know" = -8,
                                 "Refused" = -7,
                                 "Confidential" = -6,
                                 "Missing" = -4,
                                 "Not Asked" = -3).

* apply user missings to all compatible variables using `ALL` keyword.
LIGHTHOUSE CODEBOOK
  /MISSINGVALS ALL ("Legitimate Skip" = -9,
                    "Don't Know" = -8,
                    "Refused" = -7,
                    "Confidential" = -6,
                    "Missing" = -4,
                    "Not Asked" = -3).
```
Limitations:
* If a variable specified in `MISSINGVALS` already has user missings defined, they will be overwritten.
* Unlike the native `MISSING VALUES` command, `MISSINGVALS` does not support specifying ranges of missing values (e.g., `-9 THRU -1` or `99 THRU HI`).
* If either of these limitations becomes a problem, please [open an issue](https://github.com/ccsarapas/lighthouse.codebook.spss/issues) so we can consider improvements!

### SPLITLABELS Subcommand
Consider a dataset including variables with these labels:

| Name | Label |
|------|-------|
| id | Subject ID |
| food1 | What foods do you like? (Select all that apply) - Yams |
| food2 | What foods do you like? (Select all that apply) - Clams |
| food3 | What foods do you like? (Select all that apply) - Hams |
| age | How old are you? |
| color1 | What is your favorite color? - Off-White |
| color2 | What is your favorite color? - Eggshell |
| color3 | What is your favorite color? - Ecru |
| color4 | What is your favorite color? - Taupe |

The labels for `food1`, `food2`, and `food3` share a long common stem, making it 
harder to see the unique content of each variable at a glance. We can use the `SPLITLABELS` 
subcommand to extract the common stems into separate columns.
```stata
LIGHTHOUSE CODEBOOK
  /SPLITLABELS food1 TO food3.
```
The resulting codebook will include:

| Name | Label Stem | Label |
|------|------------|-------|
| id | | Subject ID |
| food1 | What foods do you like? (Select all that apply) -  | Yams |
| food2 | What foods do you like? (Select all that apply) -  | Clams |
| food3 | What foods do you like? (Select all that apply) -  | Hams |
| age | | How old are you? |
| color1 | | What is your favorite color? - Off-White |
| color2 | | What is your favorite color? - Eggshell |
| color3 | | What is your favorite color? - Cream |
| color4 | | What is your favorite color? - Taupe |

Multiple sets of variables whose labels have different common stems can be specified
by enclosing each set in parentheses.
```stata
LIGHTHOUSE CODEBOOK
  /SPLITLABELS (food1 TO food3) (color1 TO color4).
```
which yields:

| Name | Label Stem | Label |
|------|------------|-------|
| id | | Subject ID |
| food1 | What foods do you like? (Select all that apply) - | Yams |
| food2 | What foods do you like? (Select all that apply) - | Clams |
| food3 | What foods do you like? (Select all that apply) - | Hams |
| color1 | What is your favorite color? - | Off-White |
| color2 | What is your favorite color? - | Eggshell |
| color3 | What is your favorite color? - | Cream |
| color4 | What is your favorite color? - | Taupe |
