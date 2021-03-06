# This is a shiny app for exploring data in mupexi files with screened neoepitope responses
#' exploring data with shiny
#'
#' This function takes in data and axplore in ashiny app
#' @param Plotting_data data to plot
#' @export

# The app is en Beta version
# The app is only for exploring data
Exploring_data_shiny <- function(Plotting_data = my_clean_augment_data ) {
# Define UI for application
  Plotting_data <- Plotting_data %>%
    # convert Mut_MHCrank_EL and Expression level to numeric so we can join both files
    mutate(mut_mhcrank_el = as.numeric(mut_mhcrank_el),
           mut_mhcrank_ba = as.numeric(mut_mhcrank_ba),
           expression_level = as.numeric(expression_level),
           norm_mhcrank_el = as.numeric(norm_mhcrank_el),
           norm_mhcrank_ba = as.numeric(norm_mhcrank_ba),
           self_similarity = as.numeric(self_similarity)) %>%
    arrange(response) %>%
    group_by(response) %>%
    distinct(identifier, .keep_all = T)

  selections <- Plotting_data %>%
    select(response,expression_level,mut_mhcrank_el,norm_mhcrank_el,
           norm_mhcrank_ba, mut_mhcrank_ba, self_similarity,
            hla,mutation_consequence,cell_line,
            treatment,estimated_frequency_norm) %>%
    colnames()
ui <- fluidPage(
  titlePanel("Barcc  - exploring data"),
  # checkboxes for log scale
  checkboxInput("logarithmicX", "show x-axis in log10", FALSE),
  checkboxInput("logarithmicY", "show y-axis in log10", FALSE),

  # check boxes for plotting with ONLY responses
  checkboxInput("selected_dat", "Plot only responses", FALSE),
  br(),
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    # Inputs
    sidebarPanel(
      # Select choices to put in the x-axis
      selectInput(inputId = "x", label = "X-axis:",
                  choices = selections ,
                  selected = "mut_mhcrank_el"
      ),
      # Select choices to put in the y-axis
      selectInput(inputId = "y", label = "Y-axis:",
                  choices = selections,
                  selected = "norm_mhcrank_el"
                  ),
      # Select choices to put in the x-axis
      selectInput(inputId = "size", label = "size:",
                  choices = selections ,
                  selected = "estimated_frequency_norm"
      ),

      # select choices to color stuff
      selectInput(inputId = "ColorVar", label = "Color stuff",
                  choices = selections ,
                  selected = "response"
                  ),
     # select choises for the alpha scale
      selectInput(inputId = "alpha", label = "alpha",
                  choices = selections,
                  selected = "response"
                  ),
      # select choises for facet
      selectInput(inputId = "facet", label = "facet",
                  choices = c("none", selections ) ,
                   selected = "none"),
     # select choises for plot type
      selectInput("plot.type","Plot Type:",
                  list(boxplot = "boxplot", dotplot = "dotplot"),
                       selected = "dotplot"
      ),

      width = 6
    ),

    # Output:
    mainPanel(
      # Create a container for tab panels
      tabsetPanel(

        tabPanel(
          title = "Explore the Data",
          # Show scatterplot
          plotOutput(outputId = "plots")
        )

      ),

      width = 6
    )
  )
)
# Define server function required to create the scatterplot
server <- function(input, output) {

  # Create scatterplot object the plotOutput function is expecting
  output$plots <- renderPlot({

    # if statement for plotting only responses
    if(input$selected_dat)
      Plotting_data <- Plotting_data %>% filter(response=="yes")

    # switch for plot type
    renderText({
      switch(input$plot.type,
             "boxplot" 	= 	"Boxplot",
             "dotplot" =	"dotplot")
    })

    # if statement for duing facet or not
    if(input$facet=="none")
      plot.type<-switch(input$plot.type,
                        "boxplot" 	= Plotting_data %>%
                          ggplot(mapping = aes_string(x = input$x, y = input$y)) +
                          geom_quasirandom(aes_string(color = input$ColorVar),size = 2) +
                          geom_boxplot(aes_string(fill = input$ColorVar),
                                       alpha = .5, outlier.shape = NA, colour = '#525252') +
                          theme_bw() ,

                        "dotplot" = Plotting_data %>%
                          ggplot(mapping = aes_string(x = input$x, y = input$y)) +
                          geom_point(aes_string(color = input$ColorVar, alpha= input$alpha, size = input$size)) +
                          theme_bw() )
    if(input$facet!="none")
    plot.type<-switch(input$plot.type,
                      "boxplot" 	= Plotting_data %>%
                        ggplot(mapping = aes_string(x = input$x, y = input$y)) +
                        geom_quasirandom(aes_string(color = input$ColorVar),size = 2) +
                        geom_boxplot(aes_string(fill = input$ColorVar),
                                     alpha = .5, outlier.shape = NA, colour = '#525252') +
                        theme_bw() +
                        facet_grid(~get(input$facet)),

                      "dotplot" = Plotting_data %>%
                        ggplot(mapping = aes_string(x = input$x, y = input$y)) +
                        geom_point(aes_string(color = input$ColorVar, alpha= input$alpha, size = input$size)) +
                        theme_bw() +
      facet_grid(~get(input$facet)))


    # if statement for making log scales
    if(input$logarithmicX)
      plot.type <- plot.type + scale_x_log10(breaks = c(0.01, 0.10, 1.00, 2.00, 10))

    if(input$logarithmicY)
      plot.type <- plot.type + scale_y_log10(breaks = c(0.01, 0.10, 1.00, 2.00, 10))

    return(plot.type)
  })

}

# Run the app
shinyApp(ui = ui, server = server)
}
###########################################







