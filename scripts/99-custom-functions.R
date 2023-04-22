# Scrape Article Content --------------------------------------------------
scrape_article <- function(session_link = session, article, element = elements) {
  
  message(paste("Scraping at ", article))
  
  map_df(element,
         ~{session_link |> 
             nod(article) |> 
             scrape() |> 
             html_elements(.x) |> 
             html_text() |> 
             paste0(collapse = ";")})
  
}

