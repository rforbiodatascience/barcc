
# function with clean data
clean_data <- function(data) {
  # Wrangle data
  # ------------------------------------------------------------------------------
  my_data_clean <- data %>%
    # Remove "...17" column (useless - added from excel import); "HLA_allele" (same as HLA); identifier
    select(-`...17`, -HLA_allele, -identifier) %>%
    # replace dots and ( with underscore
    rename_all(funs(str_replace_all(., "\\.|[(]", "_"))) %>%
    # replace spaces and ) with nothing
    rename_all(funs(str_replace_all(., " |[)]", ""))) %>%
    # replace - with minus
    # replace spaces and ) with nothing
    rename_all(funs(str_replace_all(., "-", "minus_"))) %>%
    # make all lowescases
    rename_all(funs(str_to_lower(.))) %>%
    # remove control peptides that has introduced all NAs (present in barracoda file but not in Mupexi file)
    drop_na(norm_peptide) %>%
    # rename variables to ease reproducibility from now on
    rename(count = count_1,
           masked_p_value =`masked_p_p=1iflogfc<0`,
           p_value = p,
           neoepitope_sequence = sequence)
}

