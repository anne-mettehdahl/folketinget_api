# #df <- read.csv("/home/amhd/ft_data.csv")
# 
# 
# # # Assume your full dataframe is called df
# df_list <- split(df, df$samling_id)
# 
# dir.create("meeting_data_rds")
# # Gem hver split dataframe som .rds
# invisible(lapply(names(df_list), function(id) {
#   saveRDS(df_list[[id]], file = paste0("meeting_data_rds/meeting_data_", id, ".rds"))
# }))