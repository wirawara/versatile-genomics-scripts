# small programming tricks
dplyr tip: Show the resulting data AND save it to file.
```
data %>% ... %>% {print(.); .} %>% write_csv("result.csv")
```


Or similarly, do some operation, save that result, keep operating, etc.

```
cars %>% {write_csv(., "data.csv"); .} %>% ... %>% write_csv(...)
```

Make a vector from dataframe.

```
# first column is names of the second one in a vector
sapply(split(tmp[,2], tmp[,1]), "[", 1)
```

Numbering the duplicates in the rownames

```
time_wt2KO_mouse_countDF_log$Metabolite <- ave(as.character(time_wt2KO_mouse_countDF_log$Metabolite), 
  time_wt2KO_mouse_countDF_log$Metabolite, FUN=function(x) if (length(x)>1) paste0(x[1], '(', seq_along(x), ')') else x[1])
```
