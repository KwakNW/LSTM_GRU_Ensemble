setwd("C:/Users/K.N.W/Desktop/곽내원/4학년 1학기/LSTM-GRU")

#install.packages("RSelenium")
library(RSelenium)

remDr <- remoteDriver(remoteServerAddr = "localhost", port = 7458L, browserName = "chrome")

remDr$open()

remDr$navigate("https://finance.naver.com/marketindex/exchangeDetail.nhn?marketindexCd=FX_USDKRW")

iFrame = remDr$findElements(using = "id", value = 'exchangeDailyQuote') 
print(iFrame) 
class(iFrame)

#iFrame 안으로 이동 
remDr$switchToFrame(iFrame[[1]])

df_KOSPI <- data.frame()

for (j in c(1:401)){
	if (j < 1000){
		Sys.sleep(2)
		remDr$findElement(using = 'link text', value = as.character(j))$clickElement()
		Sys.sleep(2)
	}
	else{
		Sys.sleep(2)
		remDr$findElement(using = 'link text', value = paste0(substr(as.character(j),1,1),',',substr(as.character(j),2,4)))$clickElement()
		Sys.sleep(2)
	}

	for (i in c(1:10)){
		Date <- remDr$findElement(using = 'xpath',value =paste0('/html/body/div/table[1]/tbody/tr[',as.character(i),']'))
		Dateout <- c(Date$getElementText())

		txt <- strsplit(Dateout[[1]], split=' ')

		new <- data.frame(txt[[1]][1],txt[[1]][2])
		names(new) <- c("Date", "Cost")

		df_KOSPI <- rbind(df_KOSPI, new)
	}
}

library(dplyr)

df_KOSPI <- arrange(df_KOSPI, desc(Date)) #날짜순으로 정렬
df_KOSPI[] <- lapply(df_KOSPI, gsub, pattern=',', replacement='') #콤마(,)제거



write.csv(df_KOSPI, file="USDExchange.csv", row.names=FALSE) 
