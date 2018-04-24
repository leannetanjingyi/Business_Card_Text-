rm(list=ls())

#Input your image folder
imagelocation <- "C:/Users/Leanne/Desktop/BusinessCards/business_cards/business_cards/Reference"

#Input your export folder
exportlocation <- "C:/Users/Leanne/Desktop/BusinessCards"

#Code: Do not change anything from here

if (nchar(imagelocation) < 10){ 
      print("Image Location less than 10 characters, check for validity")
}


if (nchar(exportlocation) < 10){ 
      print("Export Location less than 10 characters, check for validity")
}

setwd(imagelocation)

if(!require(devtools)){
      install.packages("devtools")
      library(devtools)
}


if(!require(tesseract)){
      install.packages("tesseract")
      library(tesseract)
}

if(!require(magick)){
      install.packages("magick")
      library(magick)
      library(magrittr)
}

if(!require(dplyr)){
      install.packages("dplyr")
      library(dplyr)
}


table <- NULL
filenames <- NULL

for (imagetype in c("jpg", "png", "jpeg", "tiff")) {
      image <- paste("\\.", imagetype, sep = "")
      filenames1 <- list.files(pattern = image)
      filenames <- c(filenames, filenames1)
}

for (i in 1:length(filenames)) {
      text <- image_read(filenames[i]) %>%
            image_convert(colorspace = 'gray') %>%
            image_enhance() %>%
            image_contrast() %>%
            image_ocr()
      text2 <- as.character(text)
      if (is.null(text2) == FALSE) {
            row <- c(filenames[i], text2)
      }
      if (is.null(text2) == TRUE) {
            row <- c(filenames[i], "Not Recognisable")
      }
      table <- rbind(table, row)
      n <- i / length(filenames) * 100
      z <- length(filenames) - i 
      print(paste(n, "% Completed:" , z, "Files Remaining"))
}
      
table <- as.data.frame(table)
colnames(table) <- c("Image", "Text")
table$Image <- as.character(table$Image)
table$Text <- as.character(table$Text)

#Output Processing ------------------------------------------------------------
if(!require(data.table)){
      install.packages("data.table")
      library(data.table)
}

setwd(exportlocation)
exportname <- paste("Business_Card_Information_", Sys.Date(), sep = "")
fwrite(table, file = exportname)


if(!require(xlsx)){
      install.packages("xlsx")
      library(xlsx)
}

write.xlsx(table, file = paste(exportlocation,"/", 
                               exportname, ".xlsx", sep = "")
           , col.names = TRUE, row.names = FALSE, 
           sheetName = "Information")
