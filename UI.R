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
      .config-section { font-size: 12px; color: #888; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.05em; }
      .about-section h4 { color: #4a1942; margin-top: 20px; }
      .about-section p, .about-section li { font-size: 14px; line-height: 1.7; }
      .about-section code { background: #f0f0f0; padding: 1px 4px; border-radius: 3px; font-size: 13px; }
      .footer { background-color: #4a1942; padding: 14px 0; margin-top: 30px; text-align: center; width: 100%; }
      .footer a { color: #ffffff; font-size: 13px; text-decoration: none; }
      .footer a:hover { text-decoration: underline; }
    "))
  ),
  
  titlePanel(
    div(
      h2("Figshare Repository — Author Stats"),
      p("Search for an author's outputs and retrieve views & downloads.",
        style = "color:#666; font-size:14px; margin-top:-6px;")
    )
  ),
  
  tabsetPanel(
    
    # ---- Main tab ------------------------------------------------------------
    tabPanel("Search",
             br(),
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 
                 p("Repository settings", class = "config-section"),
                 textInput("institution_id", "Institution ID",
                           placeholder = "e.g. 2"),
                 textInput("repo_slug", "Repository slug",
                           placeholder = "e.g. lboro"),
                 textInput("fs_username", "Stats API username"),
                 passwordInput("fs_password", "Stats API password"),
                 hr(),
                 
                 p("Search", class = "config-section"),
                 fileInput("batch_csv", "Upload batch.csv",
                           accept      = c("text/csv", ".csv"),
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
    ),
    
    # ---- About tab -----------------------------------------------------------
    tabPanel("About",
             br(),
             div(class = "about-section", style = "max-width: 800px; padding: 10px 20px;",
                 
                 h4("Overview"),
                 p("This app retrieves views and downloads statistics for a researcher's outputs
          held in a Figshare-powered institutional repository. It is designed for use
          by repository administrators."),
                 
                 h4("How to use"),
                 tags$ol(
                   tags$li("Enter your repository's ", tags$strong("Institution ID"), " and ",
                           tags$strong("Repository slug"), " (the short identifier used in your
                  stats API URL, e.g. ", tags$code("lboro"), " for Loughborough University)."),
                   tags$li("Enter your ", tags$strong("Stats API credentials"),
                           " (the username and password for the Figshare stats endpoint)."),
                   tags$li("Upload your ", tags$code("batch.csv"), " file. This should contain at
                  minimum an ", tags$code("article_id"), " column and an ",
                           tags$code("authors"), " column."),
                   tags$li("Enter the numeric ", tags$strong("Author ID"), " for the researcher
                  you want to report on."),
                   tags$li("Click ", tags$strong("Get Stats"), ". The app will filter the CSV for
                  articles associated with that author, retrieve full metadata from the
                  Figshare API, and fetch total views and downloads from the stats API."),
                   tags$li("The resulting table can be exported using the CSV, or Excel buttons.")
                 ),
                 
                 h4("Data sources"),
                 p("Metadata (including citations) is retrieved from the ",
                   tags$a("Figshare REST API", href = "https://docs.figshare.com/", target = "_blank"),
                   ". Statistics are retrieved from the Figshare stats API, which requires
          institutional authentication."),
                 
                 h4("Package citations"),
                 p("This app was built in R using the following packages:"),
                 tags$ul(
                   tags$li(
                     "Chang W, Cheng J, Allaire J, Sievert C, Schloerke B, Aden-Buie G, Xie Y,
            Allen J, McPherson J, Dipert A, Borges B (2024). ",
                     tags$em("shiny: Web Application Framework for R."),
                     " R package version 1.9.1. ",
                     tags$a("https://CRAN.R-project.org/package=shiny",
                            href = "https://CRAN.R-project.org/package=shiny", target = "_blank")
                   ),
                   tags$li(
                     "Wickham H (2024). ",
                     tags$em("httr2: Perform HTTP Requests and Process the Responses."),
                     " R package version 1.0.7. ",
                     tags$a("https://CRAN.R-project.org/package=httr2",
                            href = "https://CRAN.R-project.org/package=httr2", target = "_blank")
                   ),
                   tags$li(
                     "Xie Y, Cheng J, Tan X, Aden-Buie G (2024). ",
                     tags$em("DT: A Wrapper of the JavaScript Library 'DataTables'."),
                     " R package version 0.33. ",
                     tags$a("https://CRAN.R-project.org/package=DT",
                            href = "https://CRAN.R-project.org/package=DT", target = "_blank")
                   )
                 ),
                 
                 h4("Notes"),
                 p("Credentials entered in this app are used only to authenticate against the
          Figshare stats API and are not stored or transmitted elsewhere. For security,
          avoid running this app on a publicly accessible server without additional
          access controls. This app uses no cookies and only usage data is collected."),
                 p("This app was created by Lara Skelly, for Loughborough University and other Figshare insitutions. Contact <RDM at lbroro.ac.uk> for any issues or questions."),
                 p("Last updated: 2026-06-26")
             )
    )
  ),
  tags$div(class = "footer", 
           fluidRow(
             column(12, 
                    tags$a(href = 'https://doi.org/10.17028/rd.lboro.28525481', 
                           "Accessibility Statement")
             )
           )
  )
)