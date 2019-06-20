#Version		: 	1.0
#Author			: 	jjg
#Last Update	: 	6/20/2019
#Purpose		: 	Take existing functions for str() and summary() to create a combined data profile function for use on a data frame
#Argument(s)	:	The function takes a data frame object and can be directed into  new object or output to the screen
#Input 			:	Data frame object
#Output			:	Data frame object
#External		:	Requires dplyr, stringr
#Example Syntax	: 	dataprofile(mtcars), prof<-dataprofile(mtcars)

dataprofile<-function(dta) {

		require(dplyr)
		require(stringr)
		
		#dta - Data Frame Object
		
		#A. Summary Statistics
			#1. Identify Characters 
				fac<-as.data.frame.matrix(summary.default(as.data.frame(dta)))
				fac<-rownames(fac[which(fac$Mode=="character"),])

			#2. Convert to Factors
				for (i in c(fac) ) { 
					dta[,c(i)]<-as.factor(dta[,c(i)])
				}

			#3. Create Summary object
				sm<-as.data.frame(summary(dta))
				sm$Var1<-NULL

			#4. Reshape Object to so the columns across the top are the summary stats by variable
				sm<-sm %>% group_by(Var2) %>% mutate(ord=row_number())
				sm<-as.data.frame(sm)
				
				sm_w<-reshape(sm, idvar=c("Var2"), timevar=c("ord"), direction="wide", sep="")
			
			#5. Clean up
				lst<-names(sm_w)[grepl("Freq", names(sm_w))==TRUE]
				for (i in c(lst) ) {
					sm_w[,c(i)]<-tolower(str_trim(sm_w[,c(i)]))
					j<-1
					while ( j < 20 ) {
						sm_w[,c(i)]<-gsub("  ", " ", sm_w[,c(i)])
						j <- j + 1
					}
				}
				sm_w$Var2<-str_trim(tolower(sm_w$Var2))
		
		#B. Structure 
			st1<-capture.output(str(dta))
			st1<-substr(st1,regexpr(":", st1),255)
			st1<-str_trim(tolower(gsub(":", "",st1)))
			st1<-as.data.frame(st1)
			st1<-st1[2:nrow(st1),]	
			st1<-as.data.frame(st1)
		
			st2<-as.data.frame.matrix(summary.default(dta))
			st2$Var<-rownames(st2)
			rownames(st2)<-1:nrow(st2)
			st2$Class<-as.character(st2$Class)
			st2$Class[st2$Class=="-none-"]<-as.character(st2[which(st2$Class=="-none-"),c("Mode")])
			st2$Var<-str_trim(tolower(st2$Var))
			st2<-st2[c("Var", "Class")]
			st2$Class<-gsub("factor", "character", st2$Class)
			
		#C. Add Summary Stats to Structure Object
			st2<-merge(st2, sm_w, by.x=c("Var"), by.y=c("Var2"), all=TRUE, sort=FALSE)					
			st<-cbind(st2,st1)
			st<-st[c(1:2,ncol(st),4:ncol(st)-1)]
			st
}
