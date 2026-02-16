# LIGHTHOUSE CODEBOOK
# Author: Casey Sarapas
# Copyright (c) 2026 Chestnut Health Systems
# License: MIT

install_lighthouse_codebook <- function() {
  cat(
    "",
    "********************************************************************************",
    "",
    "  Installing lighthouse.codebook and dependencies, including:",
    "    - lighthouse.codebook (https://github.com/ccsarapas/lighthouse.codebook)",
    "    - lighthouse (https://github.com/ccsarapas/lighthouse)",
    "",
    "********************************************************************************",
    "",
    sep = "\n"
  )
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", repos = "https://cloud.r-project.org")
  }
  remotes::install_github("ccsarapas/lighthouse.codebook", upgrade = TRUE)
}


vars_to_tidyselect <- function(x, vars, subc) {
  tokens <- strsplit(x, "\\s+")[[1]]
  if (any(tolower(tokens) == "all")) {
    cli::cli_abort(
      "The ALL keyword is allowed in {subc} only if no other variables are specified."
    )
  }
  to_locs <- which(tolower(tokens) == "to")
  not_found <- setdiff(tokens[-to_locs], vars)
  if (length(not_found)) {
    msg <- c(
      "!" = "The following {cli::qty(length(not_found))} variable{?s} {?was/were} not found in the dataset:",
      "*" = toString(not_found)
    )
    wrong_case <- vars[tolower(vars) %in% tolower(not_found)]
    if (length(wrong_case)) {
      msg <- c(
        msg,
        "*" = "Note that variable names are case sensitive. Did you mean:",
        "*" = toString(wrong_case)
      )
    }
    cli::cli_abort(msg)
  }
  if (length(to_locs)) {
    if (
      any(to_locs %in% c(1, length(tokens))) || # TO at beginning or end
        any(diff(to_locs) < 3) # `a TO b TO c` or `a TO TO b`
    ) {
      cli::cli_abort("Invalid use of TO keyword in {subc}.")
    }
    tokens <- to_locs |>
      lapply(\(loc) {
        vars[seq(match(tokens[loc - 1], vars), match(tokens[loc + 1], vars))]
      }) |>
      unlist() |>
      union(tokens[-to_locs])
  }
  rlang::expr(tidyselect::all_of(!!tokens))
}

var_grps_to_tidyselect <- function(x, vars, subc) {
  if (length(x) == 1 && tolower(x) == "all") {
    list(rlang::expr(tidyselect::everything()))
  } else {
    lapply(x, vars_to_tidyselect, vars = vars, subc = subc)
  }
}

join_tokens <- function(x, sep = " ", replace_whitespace = NULL) {
  x <- unlist(x)
  if (!is.null(replace_whitespace)) {
    x <- stringr::str_replace_all(x, "\\s", replace_whitespace)
  }
  trimws(paste(x, collapse = sep))
}


parse_user_missing <- function(x, vars) {
  ws_placeholder <- "@WS@"
  tokens <- x
  x <- join_tokens(x, replace_whitespace = ws_placeholder)
  
  groups <- stringr::str_match_all(x, "([^()\\s].*?)\\s\\(\\s([^()\\s].*?)\\s\\)")[[1]]
  if (paste(groups[, 1], collapse = " ") != x) {
    stop("Invalid `/MISSINGVALS` specification.")
  }
  
  unsupported <- setdiff(c("thru", "hi", "lo", "highest", "lowest"), vars)
  unsupported <- paste(paste0("\\b", unsupported, "\\b"), collapse = "|")
  if (any(grepl(unsupported, tolower(groups[, 3])))) {
    cli::cli_abort(c(
      "!" = "Missing value ranges, and use of the `THRU`, `HIGHEST`, and `LOWEST` keywords, are not supported by the `/MISSINGVALS` subcommand.",
      "i" = "Instead, set missing value ranges using the SPSS `MISSING VALUES` command before executing `LIGHTHOUSE CODEBOOK`."
    ))
  }
  var_groups <- var_grps_to_tidyselect(
    groups[, 2],
    vars = vars, 
    subc = "MISSINGVALS"
  )
  val_groups <- stringr::str_match_all(
    groups[, 3],
    "(?:([^=\\s]+?)\\s=\\s)?([^=\\s]+)"
  )
  val_groups <- lapply(val_groups, \(grp) {
    vals <- grp[, 3]
    nms <- grp[, 2]
    if (!all(is.na(nms))) {
      nms[is.na(nms)] <- ""
      nms <- stringr::str_replace_all(nms, stringr::fixed(ws_placeholder), " ")
      names(vals) <- nms
    }
    vals
  })
  mapply(rlang::new_formula, var_groups, val_groups)
}
  
parse_split_labels <- function(x, vars) {
  x <- join_tokens(x)

  if (stringr::str_detect(x, "\\(|\\)")) {
    if (!stringr::str_detect(x, "^(?:\\([^()]*\\S[^()]*\\)\\s*)+$")) {
      stop(
        "If parens are used to group variables for SPLITLABELS, all variables ",
        "must be enclosed in parens."
      )
    }
    x <- stringr::str_match_all(x, "\\(\\s([^()]*\\S[^()]*)\\s\\)")[[1]][, 2]
  }
  out <- var_grps_to_tidyselect(x, vars = vars, subc = "SPLITLABELS")
  rlang::expr(list(!!!out))
}

tempfile_from_active <- function() {
  temp_name <- paste(
    sample(c(letters, LETTERS), 16, replace = TRUE),
    collapse = ""
  )
  temp_path <- tempfile(fileext = ".sav")
  commands <- lighthouse::glue_chr(
    "DATASET COPY {temp_name} WINDOW=HIDDEN.",
    "DATASET ACTIVATE {temp_name}.",
    "SAVE OUTFILE='{temp_path}' /COMPRESSED.",
    "DATASET CLOSE {temp_name}.",
    .sep = "\n"
  )
  spsspkg.Submit(commands)
  temp_path
}

cb_from_spss <- function(file = tempfile(fileext = ".xlsx"),
                         datafile = NULL,
                         open = c("yes", "no"),
                         split_var_labels = NULL,
                         dataset_name = NULL,
                         hyperlinks = c("yes", "no"),
                         group_by = NULL,
                         user_missing = NULL,
                         detail_missing = c("ifany", "yes", "no"),
                         n_text_vals = 5,
                         overwrite = c("yes", "no")) {
  open <- match.arg(open) == "yes"
  hyperlinks <- match.arg(hyperlinks) == "yes"
  detail_missing <- sub("ifany", "if_any", match.arg(detail_missing))
  overwrite <- match.arg(overwrite) == "yes"
  
  if (!requireNamespace("lighthouse.codebook", quietly = TRUE)) {
    stop(
      "\n",
      "********************************************************************************\n\n",
      "  The lighthouse.codebook package must be installed in SPSS's R environment \n",
      "  before this command can be used.\n\n",
      "  -> To install lighthouse.codebook from GitHub, run:\n\n",
      "      LIGHTHOUSE CODEBOOK /INSTALL.\n\n",
      "  -> You will only need to do this once.\n\n",
      "********************************************************************************\n\n"
    )
  }
  
  if (missing(file) && !open) stop("OUTFILE must be specified if OPEN=NO.")
  
  if (is.null(datafile)) {
    datafile <- tempfile_from_active()
    on.exit(unlink(datafile, force = TRUE))
  }
  
  dat <- haven::read_sav(datafile)
  
  if (!is.null(group_by)) {
    group_by <- rlang::expr(tidyselect::all_of(!!unlist(group_by)))
  }
  
  if (!is.null(split_var_labels)) {
    split_var_labels <- parse_split_labels(split_var_labels, vars = names(dat))
  }
  
  if (!is.null(user_missing)) {
    user_missing <- parse_user_missing(user_missing, vars = names(dat))
  }
  
  dat |> 
    lighthouse.codebook::cb_create_spss(
      .user_missing = user_missing,
      .split_var_labels = !!split_var_labels
    ) |>
    lighthouse.codebook::cb_write(
      file,
      dataset_name = dataset_name,
      group_by = !!group_by, 
      detail_missing = detail_missing,
      n_text_vals = n_text_vals,
      overwrite = overwrite
    )
  cat("Codebook written to", file, "\n")
  
  if (open) lighthouse::file.open(file)
}

Run <- function(args) {
  args <- args[[2]]
  if ("install" %in% tolower(names(args))) {
    install_lighthouse_codebook()
  } else {
    oobj <- spsspkg.Syntax(templ = list(
      spsspkg.Template(
        "OUTFILE", subc = "", ktype = "literal", var = "file"
      ),
      spsspkg.Template(
        "NAME", subc = "DATA", ktype = "literal", var = "dataset_name"
      ),
      spsspkg.Template(
        "FILE", subc = "DATA", ktype = "literal", var = "datafile"
      ),
      spsspkg.Template(
        "", subc = "BY", ktype = "existingvarlist", var = "group_by", 
        islist = TRUE
      ),
      spsspkg.Template(
        "", subc = "MISSINGVALS", ktype = "literal", var = "user_missing",
        islist = TRUE
      ),
      spsspkg.Template(
        "", subc = "SPLITLABELS", ktype = "literal", var = "split_var_labels",
        islist = TRUE
      ),
      spsspkg.Template(
        "OPEN", subc = "OPTIONS", ktype = "str", var = "open",
        vallist = list("yes", "no")
      ),
      spsspkg.Template(
        "HYPERLINKS", subc = "OPTIONS", ktype = "str", var = "hyperlinks",
        vallist = list("yes", "no")
      ),
      spsspkg.Template(
        "DETAILMISSING", subc = "OPTIONS", ktype = "str", var = "detail_missing",
        vallist = list("ifany", "yes", "no")
      ),
      spsspkg.Template(
        "NTEXTVALS", subc = "OPTIONS", ktype = "int", var = "n_text_vals",
        vallist = list(0)
      ),
      spsspkg.Template(
        "OVERWRITE", subc = "OPTIONS", ktype = "str", var = "overwrite",
        vallist = list("yes", "no")
      )
    ))

    spsspkg.processcmd(oobj, args, "cb_from_spss")
  }
}
