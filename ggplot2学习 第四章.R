#第四章 用图层构建图像
#qplot的局限性在于他只能使用一个数据集和一组图形属性映射，解决这个问题的方法就是使用图层
library(ggplot2)
data(diamonds)
data(msleep)
head(msleep)
lengths(msleep)
sum(complete.cases(msleep))
#4.2 创建绘图对象
#一个图形对象使用ggplot函数来创建，他有两个主要的参数：数据(必须是数据框)和图形属性映射
p = ggplot(diamonds, aes(carat, price, colour = cut))
#图形对象在添加图层之前是无法显示的

#4.3 图层
#最简单的图层莫过于只设定一个几何对象
p = p + layer(geom = "point")
p = ggplot(diamonds, aes(x = carat))
p = p + layer(geom = "bar", geom_params = list(fill = "steelblue"), stat = "bin", stat_params = list(binwidth = 2))

#使用快捷函数，由于每一个几何对象都对应着一个默认的统计变换和位置参数，而每一个统计变换都对应着一个默认的几何对象参数
#几何对象和统计变换是存在对应关系的
#所以可以提炼出具有相同的形式的快捷函数： geom_XXXX(mapping,data,...,stat,position)或者stat_XXXX(mapping,data,...,stat,position)
p = ggplot(diamonds, aes(x = carat))
p = p + geom_histogram(binwidth = 2, fill = "steelblue")
#使用print()函数来显示存入变量中的图形
print(p)

#qplot和ggplot

ggplot(msleep, aes(sleep_rem / sleep_total, awake)) + geom_point()
#等价于
qplot(sleep_rem / sleep_total, awake, data = msleep)

#qplot也可以添加图层
qplot(sleep_rem / sleep_total, awake, data = msleep) + geom_smooth()
#等价于
qplot(sleep_rem / sleep_total, awake, data = msleep, geom = c("point", "smooth"))
#或者 前面是用ggplot设定图形属性映射关系形成图形对象，后面是增加图层
ggplot(msleep, aes(sleep_rem / sleep_total, awake)) + geom_point() + geom_smooth()

#图形对象是可以存入变量中的
p = ggplot(msleep, aes(sleep_rem / sleep_total, awake))
#可以使用summary函数来查看图形对象的结构而不用直接绘制出图形
#summary首先给出图形对象的默认设置，然后给出每个图层的信息
summary(p)
p = p + geom_point()
summary(p)

#图层是普通的r对象 是可以存入变量中，反复使用的，一组图形可以用不同数据初始化，然后加上相同的图层
library(scales)
bestfit = geom_smooth(method = "lm", se = F, colour = alpha("steelblue", 0.5), size = 2)
qplot(sleep_rem, sleep_total, data = msleep) + bestfit
qplot(awake, brainwt, data = msleep, log = "y") + bestfit
qplot(bodywt, brainwt, data = msleep, log = "xy") + bestfit


#4.4 数据
#ggplot2对数据的要求很简单，必须是数据框（data frame）
#数据变换可以参考 plyr和reshape2
#使用%+%符号来改变数据集
#r语言的对象是自含型的，数据以副本（而不是引用）的形式存储在图形对象，因此要想更改图形要更改图形中存储的数据，原数据集修改是不行的
library(ggplot2)
data(mtcars)
head(mtcars)
p = ggplot(mtcars, aes(mpg, wt, colour = cyl)) + geom_point()
p
nmtcars = transform(mtcars, mpg = mpg ^ 2)
p %+% nmtcars #更换数据集

#4.5图形属性映射
#aes()函数，在映射属性时使用的数据最好不要在指定数据集之外，这样无法将所用的数据封装到一个对象中
#一个图层里设定的图形属性映射只对该图层起作用，因此除非你修改默认标度（实际数据转换计算机能读懂的数据的过程），
#否则坐标标签以及图例标题都会根据图形对象的默认设置而生成，注意图形对象和图层的关系

#4.5.1图和图层
#可以在初始化时设定默认的图形属性映射，也可以在之后使用+来修改 添加 删除
p = ggplot(mtcars) #使用ggplot创建的是图形对象，使用geom_XXXX这类图层函数时在图形对象中添加图层
summary(p)
p = p + aes(wt, hp)
summary(p)

#图形对象中的默认映射，可以在新图层中进行扩充或者修改
p = ggplot(mtcars, aes(mpg, wt))
p + geom_point()
p + geom_point(aes(colour = factor(cyl))) #添加新的映射
p + geom_point(aes(y = disp)) #修改y的映射
p + geom_point(aes(y = NULL)) #删除映射

#4.5.2 设定和映射
#注意设定和映射的区别，当写在aes()函数中时，表示的是映射，而直接写在外面表示的是设定
p + geom_point(colour = "darkblue") #这是设定，我们将点的颜色在点图层中设定为深蓝色，此处颜色是一个渲染属性，数据中没有相对应的变量
p + geom_point(aes(colour = "darkblue")) #注意此处颜色被映射到"darkblue"时"darkblue"被看做一个普通的字符串，而不是颜色值
#这是映射，我们将点图层的颜色属性映射在只含有"darkblue"这个字符串的变量上，由于原来数据中没有这个变量，我们在新的数据集中
#创建了这个只含有"darkblue"字符的变量，然后将colour映射到这个变量，由于这个变量是离散的，因此默认的颜色标度将使用色轮上等间距的颜色，
#且在此处新的变量只有一个值，因此这个颜色就是桃红色

#在使用qplot时候，可以将某个值放到I()里来实现映射（colour=I("darkblue")）

#4.5.3 分组（形成群组对象）
#在ggplot2中几何对象大致可以分为：个体几何对象和群组几何对象
#个体几何对象对数据框的每一条数据绘制一个可以区别于其他个体的图形对象
#群组对象用来表示多条观测，他们可以是某个统计摘要的一个结果或者是几何对象的基础展示
#群组几何对象就是用一组观测来形成一个几何对象，例如连线，不同组的不同连线形成多个群组对象
#用group来控制哪些观测值（数据）使用哪种图形元素，一般可以使用离散型变量来分组，但是没有合适的能进行正确分组的离散变量时候，我们就需要自定义分组结构
#即 将group映射到在不同的组有不同的取值的变量
install.packages("nlme")
library(nlme)
data(Oxboys)

#多个分组与单个图形属性
#看看下面结果的区别：
wp = ggplot(Oxboys, aes(age, height)) + geom_line()
p = ggplot(Oxboys, aes(age, height, group = Subject)) + geom_line()
p
#很多时候我们都想将数据分成若干组，并用相同的方式对每一组进行渲染，我们通常希望区分每个个体，这一类含有多个个体的纵向数据成图 称为 “细面图”

#不同图层上的不同分组
#除了想看每个孩子的信息以外  我们还想看总体趋势，对整个数据进行拟合，此时我们可以添加一个图层
p + geom_smooth(aes(group = Subject), method = "lm", se = F) #这个图层我们使用了分组Subject使得拟合曲线按照每个Subject的数据进行拟合，而非整体拟合
p + geom_smooth(aes(group = 1), method = "lm", se = F) #这个新添加的图层，group=1绘制出的线条是基于整体数据的

#修改默认分组
boysbox=ggplot(Oxboys,aes(Occasion,height))+geom_boxplot()
boysbox
#上面的代码没有设置分组（group）属性因为Occasion本身就是个离散变量，因此默认的分组就是Occasion，在他的基础上我们想要添加个体轨迹
boysbox + geom_line(aes(group = Subject), colour = "#3366FF")
#上面的代码可以看到，boysbox使用ggplot形成图形对象，设定了默认的映射关系，并添加了一个箱型图的图层，箱型图层的映射关系使用图形对象中的默认映射关系
#而在后面添加的轨迹图层中，对图形对象中默认映射关系进行了修改变化，并没有修改箱型图中的映射关系
#每个图层都有自己的映射关系，对图形对象的映射关系的修改也仅仅在这个图层内有效，不能影响到其他图层

#4.5.4 匹配图形属性和图形对象
#如何将个体图形属性映射给整体图形属性
#线条和路径遵循差一原则，观测点比线段数目多一，第一条线段将使用第一条观测的图形属性
xgrid = with(df, seq(min(x), max(x), length = 50))
interp = data.frame(x = xgrid, y = approx(df$x, df$colour, xout = xgrid)$y, colour = approx(df$x, df$colour, xout = xgrid)$y)
qplot(x, y, data = df, colour = colour, size = I(5)) + geom_line(data = interp, size = 2)

#4.6 几何对象
#见书 p58，p59

#4.7 统计变换
#简称为stat 即对数据进行统计变换，他通常以某种方式对数据进行汇总
#统计变换可将输入数据集看做输入，将返回的数据集作为输出，因此统计变换可以向原数据集中插入新的变量（统计变换量）
#这些统计变换生成变量可以直接调用，调用时要使用..围起来，还记得直方图在产生的y坐标上使用density时的语法..density..

#每个几何对象都对应有一种默认的统计变换（可以去更改），每种统计变换也都有对应的几何对象,通过更改他们之间的对应关系可以生成新颖的图形

#4.8 位置调整
#所谓位置调整，即对该层中的元素位置进行微调
#位置调整多见与处理离散型数据，连续行数据一般很少出现完全重叠的问题
#有5中类型的位置调整
#堆叠（stack） 填充（fill） 并列（dodge） 同一（identity） 扰动（jitter）

#4.9 综合操作

#4.9.1 结合几何对象和统计变换
#将几何对象和不同的统计变换结合在一起
#下面为直方图的三个变体：分别使用：面积、点 和 瓦块三种几何对象
d = ggplot(diamonds, aes(carat)) + xlim(0, 3)
d + stat_bin(aes(ymax = ..count..), binwidth = 0.1, geom = "area")#频率多边形
d + stat_bin(aes(size = ..density..), binwidth = 0.1, geom = "point", position = "identity")#散点图，点的大小和高度都映射给了频率
d + stat_bin2d(aes(y = 1, fill = ..count..), binwidth = 0.1, geom = "tile", position = "identity") #热图,用颜色来表示频率
#注意 stat_bin 是计数的统计变换，它计数的结果会投影到y轴上，因此在stat_bin 中不能设置y值，stat_bin2d中可以

#其实ggplot2中有大量几何对象是基于其他几何对象衍生出来的，即修改某个已存在的几何对象的默认图形属性或统计变换，这样就可以创建一个新的几何对象

#4.9.2 显示已计算过的统计量
#如果你有已经汇总过的数据，并想直接使用它，而不进行其他统计变换，可以使用stat_identity()，然后将合适的变量映射到相应的属性中

#4.9.3 改变图形属性和数据集
#ggplot2还有一个更强大的功能——将不同的数据画在不同的图层上，从而使得不同的数据在同一张图上显示

#一种常见的例子就是：使用拟合模型得出的预测值来扩充原数据集

#nlme包中的Oxboys数据，我们拟合过每个孩子的曲线（个体模型），所有男孩的线性拟合去向（群体模型），但是这两者都不能单独的精确预测个体，
#因此我们可以使用混合模型来得到更好的结果下面的代码就是：

#我们首先读入nlme包，然后拟合一个截距和斜率都包含随机效应的混合模型，然后我们建立一个图形对象作为模板
library(nlme)
data(Oxboys)
model = lme(height ~ age, data = Oxboys, random = ~1 + age | Subject)#模型
oplot = ggplot(Oxboys, aes(age, height, group = Subject)) + geom_line() #模板
oplot

#随后我们对预测的生长轨迹和实际的生长轨迹进行对比，我们首先建立一个包含所有年龄（age）和个体（Subject）组合的网格数据框，
#然后我们把模型的预测值添加到新生成的数据集中，变量名为height（我们得到的预测）
age_grid = seq(-1, 1, length = 10)
subjects = unique(Oxboys$Subject)
preds = expand.grid(age = age_grid, Subject = subjects)
preds$height = predict(model, preds) #使用predict函数来对建立的preds数据框中的数据应用model模型来得到我们想要的预测值height

#得到预测值后我们把他和原数据绘制到同一张图上
#由于在新的数据集preds中我们使用了与原数据Oxboys中相同的变量名，并且我们使用的分组属性也是与原数据相同的，所以我们不用修改图形属性映射
#只需要在新图层中修改默认数据集即可
#我们还设定了颜色和大小两个图形属性参数，以方便区分于上一个图层中的图形
oplot + geom_line(data = preds, colour = "#3366ff", size = 0.4)

#从图形上看似乎拟合效果还可以，但是细节很难分辨，因此我们使用另一种比较模型好坏的方法：观察残差法

#首先我们把拟合值（fitted）和残差（resid）都添加到原数据中，然后更新数据集（用%+%），将默认的y图形属性改成resid，最后对整个数据添加一条光滑曲线
Oxboys$fitted = predict(model)#计算模型预测值
Oxboys$resid = with(Oxboys, fitted - height)#计算预测值和实际值的差，即为残差
oplot %+% Oxboys + aes(y = resid) + geom_smooth(aes(group = 1)) #绘制更换数据集绘制残差和年龄的关系图，并添加对全部数据（group=1）的拟合曲线

#从图形中看出残差并不是随机分布的，我们建立的模型有缺陷，在新的模型中我们添加一个二次项，再次计算拟合值和残差并重新绘图
model2 = update(model, height ~ age + I(age ^ 2))#对模型进行更新
Oxboys$fitted2 = predict(model2)#生成新模型下的预测值
Oxboys$resid2 = with(Oxboys, fitted2 - height)#生成新模型下的残差

oplot %+% Oxboys + aes(y = resid2) + geom_smooth(aes(group = 1))#绘制新的残差图


