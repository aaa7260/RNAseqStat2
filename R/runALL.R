#' run all workflow
#'
#' runALL include runCheck runDEG runHyper runGSEA runMSigDB
#'
#' @param object a DEGContainer
#' @param dir a directory to store results
#' @param top top for enrich result filter
#' @param parallel use parallel in DESeq2
#' @param GO logic, run GO in enrich step
#' @param KEGG logic, run KEGG in enrich step
#'
#' @return a DEGContainer
#'
#' @export
runALL <- function(object,dir = "output",top = 10,parallel = T,GO = FALSE,KEGG = TRUE) {

  tryCatch(
    expr = {
      runCheck(object = object,dir = dir)
    },
    error = function(e){
      usethis::ui_oops("Something wrong occured in Check.
                       try again later by {ui_code('runCheck')}.")
    }
  )

  tryCatch(
    expr = {
      object_g <- runDEG(obj = object,dir =dir, parallel = parallel)
    },
    error = function(e){
      usethis::ui_oops("Something wrong occured in DEG analysis.
                       Can't continue....")
    }
  )

  object_h <-tryCatch(
    expr = {
      object_h <- runHyper(obj = object_g,dir = dir,top = top,GO = GO,KEGG = KEGG)
      return(object_h)
    },
    error = function(e){
      usethis::ui_oops("Something wrong occured in Hyper analysis. Skip it now.
                       Try again later by {ui_code('runHyper')}")
      return(object_g)
    }
  )

  object_gs <- tryCatch(
    expr = {
      object_gs <- runGSEA(obj = object_h,dir = dir,top = top,GO = GO,KEGG= KEGG)
      return(object_gs)
    },
    error = function(e){
      usethis::ui_oops("Something wrong occured in GSEA analysis. Skip it now.
                       Try again later by {ui_code('runGSEA')}")
      return(object_h)
    }
  )

  object_va <- tryCatch(
    expr = {
      object_va <- runMSigDB(obj = object_gs,dir = dir,top = top)
      return(object_va)
    },
    error = function(e){
      usethis::ui_oops("Something wrong occured in runMSigDB analysis. Skip it now.
                       Try again later by {ui_code('runMSigDB')}")
      return(object_gs)
    }
  )

  return(object_va)

}