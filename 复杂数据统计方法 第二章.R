#共线性性数据
#例 2.3 糖尿病数据
library(lars)
data(diabetes)
w = diabetes
head(w)
ncol(w$x2)
is.matrix(w)
mode(w)
typeof(w)
length(w)
is.matrix(w$x)
ncol(w$x)
nrow(w$x)

#计算x2的VIF和条件数（分析是否可能存在共线性性）

#由于diabetes是list向量，因此不能按照列数进行访问，我们可以把它转换为按列排列的data.frame形式
w = read.csv("C:\\Users\\Jelly\\Desktop\\复杂数据统计方法 第二章_script_w.csv") #可以先把diabetes存为csv格式 然后读进来这样w就变成75列的数据
w = cbind(as.matrix(diabetes$x), as.matrix(diabetes$y), as.matrix(diabetes$x2)) #通过语句把diabetes下的3个list转换为matrix然后合并成为一个大表
#上边的变换会使得列名没有x，y，x2这样的标号，其他还好，y列没有命名，可以用fix()来进行修改,将某行或某列更名
fix(w)
mode(w)
#然后通过data.farme把w转换为data.frame形式
w = data.frame(w)
mode(w)
kappa(w[,12:75]) #计算x2的条件数,如果w是diabetes的形式则，w[,12:75]是无法正确表示x2的应该用w$x2才行
library(car)
sort(vif(lm(y ~ ., w[, 11:75]))) #如果w是diabetes的形式则，w[,11:75]是无法正确表示y，x2因此就没法使用11:75列进行vif的计算
#计算结果表明的w数据有很强烈的共线性性