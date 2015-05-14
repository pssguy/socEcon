shinyServer(function(input, output, session) {

  ## Pew Resarch code
  source("pew/code/pewMorality.R", local=TRUE)
  
  ## Good Country code
  source("GCI/code/gci.R", local=TRUE)
  
  ## WDI code
  source("WDI/code/wdi.R", local=TRUE)
 
}) 


