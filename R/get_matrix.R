#' Create a matrix with extracted data from a bigWig file within a specified region around a peak.
#' @description Create a matrix with extracted data from bigWig files. Region around peak which should be observed can be specified. Returns a list with the matrix and the inserted parameters (region, binsize, reference position) and filenames (bed file andbigWig files).
#' @param bed A file in bed format. Default value is NULL.
#' @param bw_files One or a character vector with multiple files in bigWig format. Default value is NULL.
#' @param bw_path The path to directory where bwtool is installed on the computer. Default value is NULL.
#' @param op_dir The path to the operation directory currently used. Default value is NULL.
#' @param up Number of basepairs from peak to 5' end. Default value is 2500.
#' @param down Number of basepairs from peak to 3' end.Default value is 2500.
#' @param pos Reference position of the region around a peak. Possibilities: '-starts' and '-ends'. Default value is '' and means a centered reference position.
#' @param binsize Binsize of how many basepairs the avergae will be calculated. Default value is 25.
#' @param numcores Number of cores which should be used in parallelised process.Default value is NULL and will be defined as the number of available cores - 1.
#' @return result list with matrices and additional information about the input of the function 
#' @import parallel
#' @export


get_matrix = function(bed = NULL, bw_files = NULL, bw_path = NULL, op_dir = NULL, up = 2500, down = 2500, pos = '', binsize=25, numcores = NULL){

  #check for bwtools
  bw_path = check_bw(bw_path = bw_path)

  #check if bw files are inserted
  if(length(bw_files)<1){
    stop("no bw_files inserted")
  }

  #check if all bw files exists
  for(i in 1:length(bw_files)){
    if(!file.exists(bw_files[i])){
      stop(paste0(bw_files[i], ' does not exist!'))
    }
  }

  #make a proper bed file
  bed = make_bed(bed = bed, op_dir = op_dir)

  #check that up and down are >= binsize
  if(up < binsize | down < binsize){
    stop(paste("up and down input has to be greater-than-or-equal to binsize:", binsize))
  }

  #check pos input
  refPosOpts = c('', '-starts', '-ends')
  if(!pos %in% refPosOpts){
    stop(paste(pos, "is no option for pos input"))
  }

  if(is.null(op_dir)){
    op_dir = getwd()
  }

  #create cluster
  if(is.null(numcores)){
    ncores = parallel::detectCores()-1
  } else{
    ncores = numcores
  }
  cl = parallel::makeCluster(ncores)
  
  #create matrix
  mcmd = paste(bw_path,  'matrix -keep-bed -tiled-averages=')
  parLapply(cl, 1:length(bw_files), function(x){
    bn = paste0(basename(bw_files[x]), '.txt')
    mcmd2 = paste0(mcmd, binsize,' ', paste0(up, ":", down), ' ',pos,' ', bed, ' ', bw_files[x], ' ', bn)
    system(command = mcmd2, intern = TRUE)
  })

  #creating outputfiles
  output =  paste0(basename(bw_files), '.txt')
  tables = lapply(X = output, FUN = data.table::fread, header= FALSE)
  names(tables) = basename(bw_files)

  del = list.files(path = op_dir, pattern="bw.txt")
  file.remove(del, bed)
  stopCluster(cl)

  result = c(tables,
                list(region = c(up, down), binSize = binsize, ref_position = pos, bed_file =  bed, bw_files = bw_files))

  message("Done.")
  return(result)
}


