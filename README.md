# LIGHTHOUSE CODEBOOK Extension Command

The `LIGHTHOUSE CODEBOOK` extension command provides an SPSS interface to the [lighthouse.codebook](https://github.com/ccsarapas/lighthouse.codebook) R package. The command generates an Excel 
workbook containing a codebook and variable summaries based on either the active 
dataset or a specified data file.

## Installation

Installation requies two steps. 

1. Install the `LIGHTHOUSE CODEBOOK` extention bundle:
    * Download the `LIGHTHOUSE CODEBOOK` extension bundle from [GitHub](https://github.com/ccsarapas/LIGHTHOUSE_CODEBOOK/releases).
    
    * In SPSS Statistics, navigate to Extensions -> Install Local Extension Bundle...
    
    * Browse to and select the downloaded extension bundle.

2. Install the `lighthouse.codebook` package and other dependencies into SPSS's
R environment by running:
    ```spss
    LIGHTHOUSE CODEBOOK /INSTALL.
    ```
    You will only need to do this once, or if updating to a later version.

## Usage

```
LIGHTHOUSE CODEBOOK
  OUTFILE = 'save/path.xlsx'
  /DATA
     NAME = 'dataset name'
     FILE = 'data/path.sav'
  /BY varlist
  /SPLITLABELS varlist
  /OPTIONS
     OPEN          = {YES**, NO}
     HYPERLINKS    = {YES**, NO}
     DETAILMISSING = {IFANY**, YES, NO}
     NTEXTVALS     = {5**, integer}
     OVERWRITE     = {YES**, NO}
  /INSTALL
```
All arguments are optional.

* **OUTFILE**: Path to write codebook to. May be omitted if **OPEN = YES` (which is 
the default), in which case the codebook will be written to a temporary file and 
immediately opened in Excel.

**/DATA Subcommand**

* **NAME**: Dataset name to include in codebook.

* **FILE**: Path to an SPSS data file to be summarized. If omitted, the active dataset
will be used. (With very large files, it can be faster to specify a data path instead 
of using the active dataset.)

**/BY Subcommand**

* List of variables to group by. If specified, additional numeric and categorical 
summary tabs will be included with decked heads grouped by variables specified in 
`BY`.

**/SPLITLABELS Subcommand**

* List of variables whose labels begin with a common stem that should be extracted 
into a separate column. (For example, 5 variables whose label all begin with "Select 
all that apply: ").

**/OPTIONS Subcommand**

* **OPEN**: Should the codebook be immediately opened in Excel?

* **HYPERLINKS**: If `YES`, variable names on the Overview sheet will link to 
corresponding rows on summary tabs and vice versa.

* **DETAILMISSING**: Include detailed missing value information on categorical and 
text summary tabs?

* **NTEXTVALS**: On the text summary tab, how many unique non-missing values should 
be included for each variable? (Additional unique values will be collapsed.)

* **OVERWRITE**: Overwrite existing codebook file?

## Examples

```
* Create codebook with default settings and no grouping. Will be saved to temp
* directory and opened in Excel.

LIGHTHOUSE CODEBOOK.

* Create codebook with name, grouped summaries and save to specified path.

LIGHTHOUSE CODEBOOK
  OUTFILE = 'C:/Users/username/My Folder/codebook.xlsx'
  /DATA NAME = 'Project Dataset'
  /BY XRA XOBS.

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
    
  