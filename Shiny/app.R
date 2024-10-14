library(shiny)
library(DT)

# Define UI
ui <- fluidPage(
  titlePanel("Smoking Behaviour in Five British Cohort Studies"),
  
  tabsetPanel(
    # First tab - Introduction
    tabPanel("Introduction",
             br(),
             includeMarkdown("introduction.md"),
             br(),
             downloadButton("downloadFile1", "Download Database as Excel file")
    ),
    
    # Second tab - Interactive Table
    tabPanel("Database",
             br(),
             downloadButton("downloadFile2", "Download Database as Excel file"),
             br(), br(),
             
             # Interactive searchable table
             DTOutput("table"),
             # Modal to display full row content
             uiOutput("modal")
    )
  )
)

# Define Server logic
server <- function(input, output, session) {
  
  # Load data from the RDS file
  df <- readRDS("smoking_items.Rds")
  
  # Create a modal dialog to show full row content
  observeEvent(input$table_rows_selected, {
    req(input$table_rows_selected)
    
    # Get the selected row (only one row can be selected)
    selected_row <- df[input$table_rows_selected[1], , drop = FALSE]
    
    # Create content for the modal dialog with line breaks
    modal_content <- lapply(names(selected_row), function(col) {
      paste0("<strong>", col, ":</strong><br>", selected_row[[col]], "<br><br>")
    })
    
    showModal(modalDialog(
      title = "Full Item Details",
      HTML(paste(modal_content, collapse = "")),  # Display row as a paragraph with line breaks
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  output$table <- renderDT({
    datatable(df, 
              escape = FALSE, 
              filter = 'top',
              options = list(
                pageLength = nrow(df),
                searchHighlight = TRUE,
                scrollX = TRUE, 
                autoWidth = TRUE,
                dom = 'Bfrtip',
                selection = 'single'
              )
    )
  })
  
  output$downloadFile1 <- downloadHandler(
    filename = function() { "smoking_items.xlsx" },
    content = function(file) {
      file.copy("smoking_items.xlsx", file)
    }
  )
  
  output$downloadFile2 <- downloadHandler(
    filename = function() { "smoking_items.xlsx" },
    content = function(file) {
      file.copy("smoking_items.xlsx", file)
    }
  )
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
