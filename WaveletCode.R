library(ggplot2)
library(dplyr)
library(xts)
library(zoo)
library(wavethresh)
library(locits)


#Labels for FTSE

myLabel <- c("Feb 2016","Feb 2017", "Feb 2018", "Feb 2019", "Feb 2020", "Feb 2021", "Feb 2022", "Feb 2023", "Feb 2024")
InitialDate = 7
numberOfTradingDaysYear = 252
myDates <- seq(numberOfTradingDaysYear, by = numberOfTradingDaysYear, length.out = 8)

#FTSE
ft <- read.csv("UKFTSE100.csv", header = TRUE)
ft <- ft[1:2048,]
ft <- ft[nrow(ft):1, ]

head(ft)
tail(ft)

plot (ft$Close, main = "FTSE 100 Closing Stock Prices", xlab = "Date", ylab = "Closing Price", xaxt = "n", type = 'l', col = "black")
axis(1, at = c(7, myDates + 7), labels = myLabel)

dft <- diff(ft$Close)
dft <- c(0,dft)
plot(dft, type = "l", xlab = "Date", ylab = "Differenced Closing Prices", main = "Differenced FTSE 100", xaxt = "n", col = "red")
axis(1, at = c(7, myDates + 7), labels = myLabel)

# Perform the wavelet transform
dftwd <- wd(dft, filter.number = 4, family = "DaubExPhase")
plot(dftwd, main = "Wavelet Transform of FTSE 100 Closing Prices", scaling = "by.level")

#Evolutionary Wavelet Spectrum
specft <- ewspec3(dft, binwidth = 100)$S
plot(specft, main="Evolutionary Wavelet Spectrum (FTSE 100)", sub="",
     ylab="Scale", xlab="Date", scaling = "by.level", xlabvals = c(7, myDates + 7), xlabchars = myLabel)


#----------------------------------------------
#snp

snp <- read.csv("SnP500.csv", header = TRUE)
snp <- snp[1:2048,]

head(snp)
tail(snp)

plot(snp$Close, main = "SnP 500 Monthly Closing Stock Prices", xlab = "Date", ylab = "Closing Price", xaxt = "n", type = 'l', col = "red")
axis(1, at = c(7, myDates + 7), labels = myLabel)

#Operate on data so that there is zero mean
dsnp <- diff(snp$Close)
plot(dsnp, type = "l", xlab = "Date", ylab = "Differenced Closing Prices", xaxt = "n", col = "red")
axis(1, at = c(7, myDates + 7), labels = myLabel)
mean(dsnp)
dsnp <- c(0,dsnp)

# Perform the wavelet transform
SnPwd <- wd(dsnp, filter.number = 4, family = "DaubExPhase")
plot(SnPwd, main = "Wavelet Transform of SnP 500 Closing Prices", scaling = "by.level")

#Evolutionary Wavelet Spectrum
specSnP <- ewspec3(dsnp, binwidth = 100)$S
plot(specSnP, main="Evolutionary Wavelet Spectrum (SnP 500)", sub="",
     ylab="Scale", xlab="Date", scaling = "by.level", xlabvals = c(7, myDates + 7), xlabchars = myLabel)

#--------------------------------------
#Localised Autocovariance

L_snp <- lacf(dsnp, binwidth = 100)

# Define lags for the entire range
lags <- seq(from = 0, to = length(L_snp$lacf[2,]) - 1)
# Filter to label only every fifth lag
label_lags <- lags[seq(1, length(lags), by = 5)]

# Define the time points to inspect
time_points <- c(500, 1000, 1500, 2000)

# Loop through each time point and generate the plot
for (t in time_points) {
  # Extract the autocovariance values at time point t
  autocor_values <- L_snp$lacr[t,]
  
  # Plot the autocovariance values
  plot.ts(autocor_values, main = paste("S&P 500 Autocorrelation at Different Lags at time t =", t),
          xlab = "Lag", ylab = "Autocorrelation", xaxt = "n", type = "o", col = "blue")
  axis(1, at = label_lags + 1, labels = label_lags)
  
  # Calculate absolute values of autocovariance
  abs_autocor_values <- abs(autocor_values)
  
  # Find the most significant lags (e.g., top 5 significant lags)
  significant_lags <- order(abs_autocor_values, decreasing = TRUE)[2:4]
  significant_autocor_values <- autocor_values[significant_lags]
  
  # Highlight the most significant lags on the plot
  points(significant_lags, significant_autocor_values, col = "red", pch = 19)
}

#------------------

#SnP

#calculate variance
plot(L_snp$lacf[,1], type = "l", main = "Variance Snp 500", ylab = expression(Var(X[t])), xlab = "Date", xaxt = "n")#variance
axis(1, at = c(7, myDates + 7), labels = myLabel)
lags_to_inspectSnP = c(1,2,3,4,10,30)

#Autocorrelation at fixed lag some time
for (lag in lags_to_inspectSnP) {
  plot(L_snp$lacr[,1+ lag], type = "l", 
       main = paste("Autocorrelation at lag", lag, "S&P 500"),
       ylab = "Autocorrelation", 
       xlab = "Date", xaxt = "n") # Autocorrelation at specified lag
  axis(1, at = c(7, myDates + 7), labels = myLabel)
}


#--------------------------------------
#--------------------------------------------------------------------
#FTSE
L_ft <- lacf(dft, binwidth = 100)

#Variance
plot(L_ft$lacf[,1], type = "l", main = "Variance FTSE", ylab = expression(Var(X[t])), xlab = "Date", xaxt = "n")#variance
axis(1, at = c(7, myDates + 7), labels = myLabel)

# Loop through each time point and generate the plot
for (t in time_points) {
  # Extract the autocovariance values at time point t
  autocor_values <- L_ft$lacr[t,]
  
  # Plot the autocovariance values
  plot.ts(autocor_values, main = paste("FTSE 100 Autocorrelation at Different Lags at time t =", t),
          xlab = "Lag", ylab = "Autocorrelation", type = "o", col = "blue", xaxt = "n")
  axis(1, at = label_lags + 1, labels = label_lags)
  
  # Calculate absolute values of autocovariance
  abs_autocor_values <- abs(autocor_values)
  
  # Find the most significant lags (e.g., top 5 significant lags)
  significant_lags <- order(abs_autocor_values, decreasing = TRUE)[2:4]
  significant_autocor_values <- autocor_values[significant_lags]
  
  # Highlight the most significant lags on the plot
  points(significant_lags, significant_autocor_values, col = "red", pch = 19)
}

#----
#FTSE find autocovariance const lag
lags_to_inspectFTSE = c(1,2,3,5, 30)
#Autocovariance at fixed lag some time
for (lag in lags_to_inspectFTSE) {
  plot(L_ft$lacr[,1+ lag], type = "l", 
       main = paste("Autocorrelation at lag", lag, "FTSE 100"),
       ylab = "Autocorrelation", 
       xlab = "Date", xaxt = "n") # autocovariance at specified lag
  axis(1, at = c(7, myDates + 7), labels = myLabel)
}

#-------------------