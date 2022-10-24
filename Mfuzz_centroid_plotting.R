#### -------------------------------
##### DRAWING THE MOTHERLINE OF THE CLUSTERS
mestimate<- function(df){
  N <-  dim(df)[[1]]
  D <- dim(df)[[2]]
  m.sj <- 1 + (1418/N + 22.05)*D^(-2) + (12.33/N +0.243)*D^(-0.0406*log(N) - 0.1134)
  return(m.sj)
}

m.sc <- mestimate(scaledata)
# 1.313199

# 3 clusters
clustering <- mfuzz(scaledata, centers=3, m=1.313199)

# import some data manipulation functions
library(reshape2)
library(tidyr)
library(dplyr)

#get the centroids into a long dataframe:
fcm_centroids <- clustering$centers
fcm_centroids_df <- data.frame(fcm_centroids)
fcm_centroids_df$cluster <- row.names(fcm_centroids_df)
centroids_long <- tidyr::gather(fcm_centroids_df,"sample",'value',1:13)

# ggplot(centroids_long, aes(x=sample,y=value, group=cluster, colour=as.factor(cluster))) + 
#   geom_line() +
#   xlab("Time") +
#   ylab("Expression") +
#   labs(title= "Cluster Expression by Time",color = "Cluster")

#start with the input data
fcm_plotting_df <- data.frame(z.mat.sc)
fcm_plotting_df <- t(fcm_plotting_df)
fcm_plotting_df <- as.data.frame(fcm_plotting_df)


#add genes
fcm_plotting_df$gene <- rownames(fcm_plotting_df)

#bind cluster assinment
fcm_plotting_df$cluster <- clustering.sc2$cluster
#fetch the membership for each gene/top scoring cluster
fcm_plotting_df$membership <- sapply(1:length(fcm_plotting_df$cluster),function(row){
  clust <- fcm_plotting_df$cluster[row]
  clustering.sc2$membership[row,clust]
})

k_to_plot = 1

#subset the dataframe by the cluster and get it into long form
#using a little tidyr action
cluster_plot_df <- dplyr::filter(fcm_plotting_df, cluster == k_to_plot) %>%
  dplyr::select(.,1:13,membership,gene) %>%
  tidyr::gather(.,"sample",'value',1:13)

#order the dataframe by score
cluster_plot_df <- cluster_plot_df[order(cluster_plot_df$membership),]
#set the order by setting the factors using forcats
cluster_plot_df$gene = forcats::fct_inorder(cluster_plot_df$gene)

#subset the cores by cluster
core <- dplyr::filter(centroids_long, cluster == k_to_plot)

ggplot(cluster_plot_df, aes(x=sample,y=value)) + 
    geom_line(aes(colour=membership, group=gene)) +
    # scale_colour_gradientn(colours=c('blue1','red2')) +
    scale_colour_gradient(low = "white", high = "gray80") +
    #this adds the core 
    geom_line(data=core, aes(sample,value, group=cluster), color="black",inherit.aes=FALSE) +
    xlab("Time") +
    ylab("Expression") +
    labs(title= paste0("Cluster ",k_to_plot," Expression by Time"),color = "Score") +
    theme_bw() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))