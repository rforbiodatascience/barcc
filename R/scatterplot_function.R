#' Scatter Plot Function
#'
#' This function takes in data, x, and y, and creates a scatter plot.
#' @param data data to plot
#' @param x x variable
#' @param y y variable
#' @export

scatterplot_function <- function(data = my_clean_augment_data,
                                 x = 'mut_mhcrank_el',
                                 y = 'expression_level') {
p <- data  %>%
    group_by(response) %>%
    distinct(identifier, .keep_all = T) %>%
    ggplot(mapping = aes_string(x = x, y = y)) +
    geom_point(aes(color=response, alpha = response, size  = estimated_frequency_norm))+
    scale_y_log10(breaks = c(0.01, 0.10, 0.5, 1.00, 2.00, 10))+
    scale_x_log10(breaks = c(0.01, 0.10, 0.5, 1.00, 2.00, 10))+
    theme_bw() +
    scale_alpha_manual(breaks = c("no","yes"),labels = c("no","yes"),values = c(0.3,0.9))+
    scale_color_manual(values = c("#91bfdb","#ef8a62")) +
    guides(color = guide_legend(override.aes = list(size = 5))) +
    facet_grid(vars(cell_line), scales = "free") +
    theme(plot.title = element_text(hjust = 0.5))+
    labs(size = "Estimated frequency normalized",
         color = "Response",
         alpha = "Response")
return(p)

}
