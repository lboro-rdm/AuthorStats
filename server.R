server <- function(input, output, session) {
  
  results <- reactiveVal(NULL)
  status  <- reactiveVal("")
  
  observeEvent(input$search_btn, {
    req(input$batch_csv,
        !is.na(input$author_id),
        nzchar(trimws(input$institution_id)),
        nzchar(trimws(input$repo_slug)),
        nzchar(trimws(input$fs_username)),
        nzchar(trimws(input$fs_password)))
    
    results(NULL)
    status("Reading CSV…")
    
    author_id  <- input$author_id
    repo_slug  <- trimws(input$repo_slug)
    username   <- trimws(input$fs_username)
    password   <- input$fs_password
    csv_path   <- input$batch_csv$datapath
    
    withProgress(message = "Fetching data…", value = 0, {
      
      # 1. Filter CSV for rows matching the author ID
      incProgress(0.05, detail = "Scanning CSV…")
      matched <- find_articles_for_author(csv_path, author_id)
      
      if (is.null(matched)) {
        status("Could not read CSV — check it has 'article_id' and 'authors' columns.")
        return()
      }
      if (nrow(matched) == 0) {
        status(paste0("No articles found for author ID ", author_id, "."))
        return()
      }
      
      ids <- matched$article_id
      n   <- length(ids)
      status(paste0("Found ", n, " article(s). Fetching details and stats…"))
      
      rows <- vector("list", n)
      
      # 2. Fetch full metadata + stats for each article
      for (i in seq_along(ids)) {
        incProgress(0.95 / n, detail = paste0("Article ", i, " of ", n, "…"))
        
        id     <- ids[[i]]
        detail <- get_article_detail(id)
        views  <- get_stats(id, "views",     repo_slug, username, password)
        dls    <- get_stats(id, "downloads", repo_slug, username, password)
        
        rows[[i]] <- data.frame(
          Citation  = detail[["citation"]],
          Views     = views,
          Downloads = dls,
          stringsAsFactors = FALSE
        )
      }
      
      df <- do.call(rbind, rows)
      results(df)
      status(paste0("Done — ", nrow(df), " article(s) retrieved."))
    })
  })
  
  # ---- Outputs ----------------------------------------------------------------
  
  output$status_msg <- renderUI({
    msg <- status()
    if (nzchar(msg)) p(msg, class = "status-msg") else NULL
  })
  
  output$results_table <- renderDT({
    df <- results()
    req(!is.null(df))
    
    filename <- paste0(input$author_id, "-", format(Sys.Date(), "%Y-%m-%d"))
    
    datatable(
      df,
      escape     = FALSE,
      rownames   = FALSE,
      filter     = "top",
      extensions = "Buttons",
      options    = list(
        dom        = "Bfrtip",
        buttons    = list(
          list(extend = "csv",   filename = filename),
          list(extend = "excel", filename = filename, title = "")
        ),
        pageLength = 25,
        columnDefs = list(
          list(width = "70%", targets = 0),
          list(className = "dt-center", targets = c(1, 2))
        ),
        autoWidth = TRUE
      )
    )
  }, server = FALSE)
}