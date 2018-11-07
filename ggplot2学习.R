#第二章 从qplot开始入门
library(ggplot2)
data(diamonds)
nrow(diamonds)
dsmall = diamonds[sample(nrow(diamonds), 100),]
head(dsmall)

#2.3基本用法
qplot(carat, price, data = diamonds)
qplot(log(carat), log(price), data = diamonds)
qplot(carat, x * y * z, data = diamonds)

#2.4颜色、大小、形状和其他图形属性

#qplot对图形中的点元素的属性设定时候可以更方便的展示取值与图形属性之间的对应关系，可以轻易的将表中的其他属性应用在点的属性上
qplot(carat, price, data = dsmall, colour = color) #将color变量映射到点的颜色
qplot(carat, price, data = dsmall, shape = cut) #将shape变量映射到点的形状
#alpha用来设置透明度，一般可以用I(1/n),表示当这个点被n次覆盖后它的透明度（取值区间[0,1]）变为1，即不再透明
#使用半透明的颜色可以有效减轻图元重叠现象
qplot(carat, price, data = diamonds, alpha = I(1 / 10))
qplot(carat, price, data = diamonds, alpha = I(1 / 100))
qplot(carat, price, data = diamonds, alpha = I(1 / 200)) #设置不同的重叠级数可以表明大部分点在哪里重叠
#不同类型的变量适用于不同的图形属性，颜色和形状适用于分类变量，而大小适合于连续变量
#数据量大小影响图形，如果数据量很大不同组别的数据很难区分，可能就需要利用分面来解决

#2.5 几何对象

#2.5.1 向图中添加平滑曲线
#qplot并非只能画散点图，通过改变几何对象（geom）他几乎可以画任何图形
#几何对象描述了应该用何种对象来对数据进行展示，其中有些几何对象关联了相应的统计变换
#例如 直方图就是用 条形的几何对象描述 分组计数后的 数据集
qplot(carat, price, data = diamonds, geom = c("point", "smooth"))
qplot(carat, price, data = diamonds, geom = c("smooth", "point"))
#可以用c()将多个几何对象组成一个向量传递给geom，几何对象的堆叠顺序就有这个向量传递的排列顺序进行堆叠，看看上边的代码的区别
qplot(carat, price, data = dsmall, geom = c("point", "smooth"))
#曲线周围的灰色部分表示逐点置信区间的宽度，可以看到超过3克拉的钻石很少，超过后拟合关系的不确定性增加，置信区间变大
#可以用se =false来关闭标准误
qplot(carat, price, data = dsmall, geom = c("point", "smooth"), se = F)
#曲线的平滑程度由参数span控制,其取值范围由[0,1]表示不平滑到平滑
qplot(carat, price, data = dsmall, geom = c("point", "smooth"), span = 0.2)
qplot(carat, price, data = dsmall, geom = c("point", "smooth"), span = 1)
#小数据用的method是loess算法，大数据n>1000时默认采用另一种算法gam
#method用来表示产生平滑曲线所用的算法，可以是 loess gam lm等 formula用来说明拟合数据的公式 y~x 直线拟合

#2.5.2箱线图和扰动点图
#如果一个数据集中包含了一个分类变量和多个或一个连续变量，那么我们可能想知道连续变量如何随着分类变量水平的变化而变化
#显示了每克拉钻石的价位在颜色上的分布
qplot(color, price / carat, data = diamonds, geom = "jitter")
qplot(color, price / carat, data = diamonds, geom = "boxplot")
#增加透明度
qplot(color, price / carat, data = diamonds, geom = "jitter", alpha = I(1 / 5))
qplot(color, price / carat, data = diamonds, geom = "jitter", alpha = I(1 / 50))
qplot(color, price / carat, data = diamonds, geom = "jitter", alpha = I(1 / 200))
#扰动点图： size shape colour
#箱线图：colour fill size

#2.5.3 直方图和密度曲线
#可以展示单个变量的分布信息
qplot(carat, data = diamonds, geom = "histogram")
qplot(carat, data = diamonds, geom = "density")
#直方图可以用 binwidth来设置值组距，用breaks来显式指定切分位置
#密度曲线可以用adjust来调整平滑度，取值越大越平滑
#不管是密度曲线还是直方图，对平滑程度的试验都很重要
#在直方图中，不同的组距体现的数据特征是不一样的，应当尝试多种组距
qplot(carat, data = diamonds, geom = "histogram", binwidth = 1, xlim = c(0, 3))
qplot(carat, data = diamonds, geom = "histogram", binwidth = 0.1, xlim = c(0, 3))
qplot(carat, data = diamonds, geom = "histogram", binwidth = 0.01, xlim = c(0, 3))

#要在不同的组之间进行分布对比，只需要加上一个图形映射，在qplot中当一个分类变量被映射到某个图形属性上是，它对应的几何对象会自动按这个变量进行拆分
qplot(carat, data = diamonds, geom = "density", colour = color)
qplot(carat, data = diamonds, geom = "histogram", colour = color)
qplot(carat, data = diamonds, geom = "histogram", fill = color)
#注意上面代码的区别

#2.5.4 条形图（离散变量）
#geom="bar",条形图几何对象会计算每一个水平下观测的数量
#如果数据已经进行了汇总，或者想用其他方式对数据进行分组处理（例如 对连续变量进行分组求和），可以使用weight几何对象
qplot(color, data = diamonds, geom = "bar")
qplot(color, data = diamonds, geom = "bar", weight = carat) + scale_y_continuous("carat")#后面代码修改了y坐标的标签，该图统计了不同颜色钻石的总重量
qplot(color, data = diamonds, geom = "bar", weight = carat, ylab = "carat") #与上面的写法有什么区别？

#2.5.5 时间序列中的线条图和路径图
#线条图：从左往右进行连接
#路径图：按照点在数据集中的顺序进行连接
data(economics, package = "ggplot2")
class(economics)
#线条图：数据按照时间顺序排列，然后连线成图，几何对象是 线
qplot(date, unemploy / pop, data = economics, geom = "line")
qplot(date, uempmed, data = economics, geom = "line")

#如果两个变量交汇，想要再增加时间因素，那么就需要画路径图，途中点之间的连线描述了先后，存在时间的概念，几何对象是 点和路径
qplot(unemploy / pop, uempmed, data = economics, geom = c("point", "path"))
#上一张图时间变化的方向不明显，我们在第二张图上将年份映射到colour属性上，让我们更容易看清时间的行进方向
year=function(x) as.POSIXlt(x)$year+1900#把date数据转换为numeric
qplot(unemploy / pop, uempmed, data = economics, geom = "path", colour = year(date))


#2.6 分面(是在同一个坐标系统中)
#将数据分割为若干子集，然后创建一个图形矩阵，语法 facets=row_var~col_var,如果要只指定一个单独的变量来进行分面，可以用.作为占位符
#下面绘制以颜色为分面条件，将重量作为自变量进行直方图(几何对象)的绘制
qplot(carat, data = diamonds, facets = color ~ ., geom = "histogram", binwidth = 0.1, xlim = c(0, 3))
#下面的绘制 使用了新的语法..density..它告诉ggplot2将密度而不是统计的频数映射（作为y的值）到y轴上
qplot(carat, ..density.., data = diamonds, facets = color ~ ., geom = "histogram", binwidth = 0.1, xlim = c(0, 3), fill = color)

#2.7 qplot中的其他参数
#xlim ylim：设置x，y轴的显示区间，用一个长度为2的向量来赋值
#log：用来说明哪个坐标轴取对数，为字符向量，"x","y","xy",成为对数坐标系，并不是把数据取对数然后投在笛卡尔坐标系内
#main：图形的主题（标题），放置在图形的顶端中部，以大字号显示，可以是个字符串"Title",也可以是表达式 expression(),用？plotmath来查看更多数学表达式
#xlab，ylab：用来设置x轴和y轴的标签文字，也可以是字符串或者表达式
qplot(carat, price, data = dsmall, main = "Price-weight relationship", geom = "point", ylab = "Price($)", xlab = "Weight(carats)",facets = color~.,colour=color)
#通过xlim我们只看重量在0.2-1之间的小钻石的分布，注意ylab的区别
qplot(carat, price / carat, data = dsmall, main = "Small diamonds", xlab = "Weight(carats)", ylab = expression(price / carat), xlim = c(.2, 1))
qplot(carat, price / carat, data = dsmall, main = "Small diamonds", xlab = "Weight(carats)", ylab = expression(frac(price,carat)), xlim = c(.2, 1))
#对数坐标系 注意下面两种写法的区别
qplot(carat, price, data = dsmall, log = "xy")
qplot(log(carat),log(price),data=dsmall)







