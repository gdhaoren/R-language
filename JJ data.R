#read data
jj=AirPassengers
objects()
jj[1]
head(jj)
jj[1:4]
jj[-(1:80)]
length(jj)
dim(jj)
nrow(jj)
ncol(jj)
jj = as.matrix(jj)
dim(jj)
nrow(jj)
ncol(jj)
library(zoo)
jj = ts(jj, start = 1949, frequency = 12)
AP = ts(AirPassengers, start = 1949, frequency = 12)
objects()
time(jj)
plot(jj, ylab = "Person per Month", main = "AirPerson")
library(ggplot2)
search()
plot(jj, type = 'o', col = "red", lty = "dashed")
plot(diff(log(jj)), main = "logged and diffed")

x = -5:5
y = 5 * cos(x)
par(mfrow = c(3, 2))

plot(x, main = "plot(x)")
plot(x, y, main = "plot(x,y)")

plot.ts(x, main = "plot.ts(x)")
plot.ts(x, y, main = "plot.ts(x,y)")

ts.plot(x, main = "ts.plot(x)")
ts.plot(ts(x), ts(y), col = 1:2, main = "ts.plot(x,y)")

a=rep(0,5)
a <- a[2 * 1:5]
mode(a)
length(a)
a
a[1]
length(a) = 1

dim(a)
attr(a,"dim")=c(1,5)

dim(a)
attributes(a)

sx = state.abb
sx
dim(sx)
statef = factor(sx)
statef

incomes <- c(60, 49, 40, 61, 64, 60, 59, 54, 62, 69, 70, 42, 56,
61, 61, 61, 58, 51, 48, 65, 49, 49, 41, 48, 52, 46,
59, 46, 58, 43)
incomes
objects()
rm(x, y)

incmeans = tapply(incomes, statef, mean)
length(incomes)