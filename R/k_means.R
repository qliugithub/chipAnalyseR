#' Order the entries in each matrix according to the order returned by the "kmeans"-function of the selected reference matrix (refmat = ).
#' @description Clusters data of selected matrix in the list in k clusters. Order the entries of all matrices according to the ordered reference matrix. Called by "plot_hm"-function.
#' @param mat A list with matrices and additional information about the selected region. mat generated by "get_matrix"-function. Default value is NULL.
#' @param refmat Integer which specifies the reference matrix to which all matrices will be ordered according to kmeans clustering of ference matrix. Default value is NULL.
#' @param k Integer which specifies the number of clusters which should be build by "kmeans"-function. Default value is NULL.
#' @return list with ordered matrix entries, splitted matrices according to the clusters with column Means for profile plotting and additional information about the clusters and the region entered in "get_matrix"-function. Will be used of "plot_hm"-function

k_means = function(mat = NULL, refmat= NULL,  k = NULL){
  ########## check mat input (got from "get_matrix" function) ##########
  if(is.null(mat)){
    stop("no mat available")
  }
  
  nmats = length(mat)-5 ### number of matrices/ inserted bw-files
  cmats = length(mat[[1]]) ### number of columns in matrices
  info = mat[(length(mat)-4) : length(mat)] ### store information from get_matrix function 
  
  ########## set reference matrix to 1 if only one matrix is entered ##########
  if(nmats ==1){
    refmat=1
  }
  
  refmat = mat[[refmat]]
  matc = refmat[,7:cmats, with  = FALSE]
  set.seed(seed = 12)
  k2 = kmeans(matc, centers = k, nstart = 10)

  mat.ordered = c()
  for ( i in (1:nmats)){
    x = mat[[i]]
    x$clust = k2$cluster
    x= x[order(clust)]
    x = x[, 7:length(x)]
    mat.ordered[[i]] = x
  }
  names(mat.ordered) = names(mat)[1:nmats]

  ########## split matrices according to the cluster ##########
  mat_sp = list()
  for(i in 1:nmats){
    sp = split(mat.ordered[[i]][,1:(length(x)-1)], mat.ordered[[i]]$clust)
    mat_sp[[i]] = sp
  }
  
  names(mat_sp) = names(mat)[1:nmats]
  cut.pos = cumsum(unlist(lapply(mat_sp[[1]], nrow)))
  cut.sum = sum(unlist(lapply(mat_sp[[1]], nrow)))
  mat_ssum = lapply(mat_sp, function(x){
    lapply(x, function(y){
      colMeans(y, na.rm = TRUE)
    })
  })
  return(list(plot_data = mat.ordered, k_avg = mat_ssum, k_cuts = cut.pos, cut_sum = cut.sum, info = info))
}
