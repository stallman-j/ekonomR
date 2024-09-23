

# Palettes ----
if (!require(dichromat)) install.packages("dichromat")

library(dichromat) # to get colors between a group


yale_lblue  <- "#63aaff"
  yale_medblue   <- "#286dc0"
    yale_blue   <- "#00356b"
      
    
    yale_palette <- colorRampPalette(color = c("white", yale_lblue, yale_medblue, yale_blue))(10)
    yale_exag_palette <- yale_palette[c(1,2,4,6,8,10)]
    
    yale_scheme <- c(yale_palette[c(3,6,4,2,5,3,6,4,2,5)])
    
  my_green <- "#228B22"
  
  
  terrain_palette <- colorRampPalette(color = c("#fff7bc","#fec44f","#d95f0e"))(5)
  