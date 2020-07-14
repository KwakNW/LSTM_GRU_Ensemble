setwd("C:/Users/K.N.W/Desktop/곽내원/4학년 1학기/LSTM-GRU")

#install.packages("RSelenium")
library(RSelenium)

remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L, browserName = "chrome")

remDr$open()

remDr$navigate("https://finance.naver.com/sise/sise_index.nhn?code=KOSPI")

iFrame = remDr$findElements(using = "name", value = 'day') 
print(iFrame) 
class(iFrame)

#iFrame 안으로 이동 
remDr$switchToFrame(iFrame[[1]])

df_KOSPI <- data.frame()

for (j in 1:1301){
	if (j < 1000){
		Sys.sleep(3)
		remDr$findElement(using = 'link text', value = as.character(j))$clickElement()
		Sys.sleep(3)
	}
	else{
		Sys.sleep(3)
		remDr$findElement(using = 'link text', value = paste0(substr(as.character(j),1,1),',',substr(as.character(j),2,4)))$clickElement()
		Sys.sleep(3)
	}

	for (i in c(3,4,5,10,11,12)){
		Date <- remDr$findElement(using = 'xpath',value =paste0('/html/body/div/table[1]/tbody/tr[',as.character(i),']'))
		Dateout <- c(Date$getElementText())

		txt <- strsplit(Dateout[[1]], split=' ')

		new <- data.frame(txt[[1]][1],txt[[1]][2],txt[[1]][3],txt[[1]][4],txt[[1]][5],txt[[1]][6])
		names(new) <- c("Date", "Cost", "Rate", "Percent", "Amount", "Money")

		df_KOSPI <- rbind(df_KOSPI, new)
	}

	if (j %% 10 == 0){
		remDr$findElement(using = 'link text', value = '다음')$clickElement()
		Sys.sleep(3)
	}

}

library(dplyr)

df_KOSPI <- arrange(df_KOSPI, desc(Date)) #날짜순으로 정렬
df_KOSPI[] <- lapply(df_KOSPI, gsub, pattern=',', replacement='') #콤마(,)제거



write.csv(df_KOSPI , file="KOSPI2.csv", row.names=FALSE) 
