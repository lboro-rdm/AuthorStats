library(shiny)
library(httr2)
library(DT)

options(shiny.maxRequestSize = 500 * 1024^2)  # 500 MB

# ---- Null-coalescing operator -----------------------------------------------

`%||%` <- function(a, b) if (!is.null(a) && length(a) > 0 && !is.na(a[1])) a else b

# ---- CSV helper -------------------------------------------------------------

find_articles_for_author <- function(csv_path, author_id) {
  df <- tryCatch(
    read.csv(csv_path, stringsAsFactors = FALSE, check.names = FALSE),
    error = function(e) NULL
  )
  
  if (is.null(df)) return(NULL)
  
  names(df) <- tolower(trimws(names(df)))
  
  if (!all(c("article_id", "authors") %in% names(df))) return(NULL)
  
  matched <- grepl(
    pattern = paste0("\\b", as.character(author_id), "\\b"),
    x       = df$authors,
    perl    = TRUE
  )
  
  df[matched, , drop = FALSE]
}

# ---- API helpers ------------------------------------------------------------

get_article_detail <- function(article_id) {
  resp <- tryCatch(
    request("https://api.figshare.com/v2/articles") |>
      req_url_path_append(article_id) |>
      req_perform(),
    error = function(e) NULL
  )
  
  if (is.null(resp) || resp_is_error(resp)) return(NULL)
  resp_body_json(resp)
}

get_stats <- function(article_id, stat_type = c("views", "downloads"), repo_slug, username, password) {
  stat_type <- match.arg(stat_type)
  
  resp <- tryCatch(
    request(paste0("https://stats.figshare.com/", repo_slug, "/total")) |>
      req_url_path_append(stat_type, "article", article_id) |>
      req_auth_basic(username, password) |>
      req_perform(),
    error = function(e) NULL
  )
  
  if (is.null(resp) || resp_is_error(resp)) return(NA_integer_)
  as.integer(resp_body_json(resp)$totals)
}