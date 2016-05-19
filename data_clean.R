library(dplyr)

# loading the data
sent <- read.csv('sentinel_test_data.csv', header = TRUE)
res <- read.csv('residential_test_data.csv', header = TRUE)

# Renaming date submitted the same for both datasets
colnames(res)[2] <-"Date_Submitted"
colnames(sent)[2] <-"Date_Submitted"

# finding intersecting columns between residentials and sentinal data
sent_colnam <- colnames(sent)
res_colnam <- colnames(res)
join_colname <- intersect(sent_colnam, res_colnam)

# concatenating overlapping residential & sentinal dataframes
sent_intersect <- sent[join_colname]
res_intersect <- res[join_colname]
sent_intersect['source'] = "Sentinel"
res_intersect['source'] = "Residential"

res_sent <- rbind(sent_intersect, res_intersect)

# adding lead 15 bpp criteria factor
res_sent <- res_sent %>% mutate(LeadLevel = ifelse(res_sent$Lead..ppb. < 15, "Safe", "unSafe"))

# adding back NA latitude longitude
NAindex <- which(is.na(res_sent[, "Latitude"]))
res_sent[NAindex, "Property.Address"]   # Both at 1222 KENSINGTON AVE, flint, mi
res_sent[NAindex[1], c("Latitude", "Longitude")] <- c(43.01383, -83.66655)
res_sent[NAindex[2], c("Latitude", "Longitude")] <- c(43.01383, -83.66655)
res_sent[NAindex, c("Latitude", "Longitude")]
