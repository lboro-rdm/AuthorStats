ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { font-family: 'Segoe UI', Arial, sans-serif; background: #f7f9fc; }
      .well { background: #ffffff; border: 1px solid #dee2e6; border-radius: 8px; }
      h2 { color: #4a1942; font-weight: 700; }
      .btn-primary { background-color: #4a1942; border-color: #4a1942; }
      .btn-primary:hover { background-color: #6b2860; border-color: #6b2860; }
      .status-msg { margin-top: 10px; font-style: italic; color: #555; }
      .dataTables_wrapper { background: #fff; padding: 12px; border-radius: 8px; }
    "))
  ),
  
  titlePanel(
    div(
      h2("Loughborough Research Repository — Author Stats"),
      p("Upload your batch CSV, enter an author ID, and retrieve views & downloads for their outputs.",
        style = "color:#666; font-size:14px; margin-top:-6px;")
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      fileInput("batch_csv", "Upload batch.csv",
                accept = c("text/csv", ".csv"),
                buttonLabel = "Browse…",
                placeholder = "No file selected"),
      numericInput("author_id", "Author ID",
                   value = NA, min = 1, step = 1),
      actionButton("search_btn", "Get Stats", class = "btn-primary btn-block"),
      hr(),
      uiOutput("status_msg")
    ),
    
    mainPanel(
      width = 9,
      DTOutput("results_table")
    )
  )
)