#第五章 工具箱
#不要指望默认配置能够得到表现力足够的图
library(ggplot2)
data(diamonds)
data(mpg)
#ggplot2的图层化构架鼓励我们以一种结构化的方式来设计和构建图形
#本章列举了ggplot2中大量几何对象和统计变换的一部分
#1.基本图形类型  2.展示分布  3.应对散点图中的遮盖绘制问题  4.绘制曲面图  5.统计汇总  6.绘制地图  7.解释数据中的不确定性和误差
#8.为图形添加注解  9.绘制加权数据

#5.2 图层叠加的总体策略
#总体来说图层有3个主要用途：
#1. 用以展示数据本身
#2. 用以展示数据的统计摘要：展示数据本身可以帮助我们改善模型，而展示模型可以帮助我们揭示数据的微妙之处，本层通常绘制在数据层之上
#3. 用以添加额外的元数据（metadata）、上下文信息和注解：元数据展示了背景的上下文信息，也可为原始数据赋予有现实意义的注解
#   其他元数据也可以用来强调数据中的重要特征

#5.3 基本图形类型
#geom_area(面积图)，bar（stat=identity）（条形图）,line(线条图)，point（散点图），polygon（多边形），text（添加标签，需要设置label属性），tile（色深图或水平图）
df = data.frame(x = c(3, 1, 5), y = c(2, 4, 6), label = c("a", "b", "c")) #生成数据集
p = ggplot(df, aes(x, y)) + xlab(NULL) + ylab(NULL) #建立图形对象
#添加各种图层
p + geom_point() + labs(title = "geom_point")
p + geom_bar(stat = "identity") + labs(title = "geom_bar(stat=\"identity\")")
p + geom_line() + labs(title = "geom_line")
p + geom_area() + labs(title = "geom_area")
p + geom_path() + labs(title = "geom_path")
p + geom_text(aes(label = label)) + labs(title = "geom_text")
p + geom_tile() + labs(title = "geom_tile")
p + geom_polygon() + labs(title = "geom_polygon")

#5.4 展示数据分布
#有些几何对象可以用于展示数据分布，具体使用哪种取决于：
#1.分布的维度
#2.分布是连续的还是离散的
#3.是条件分布还是联合分布

#对于一维连续型分布，最重要的几何对象是：直方图
#为了找到一个表现力强的视图，多次测试组距的布局细节是必不可少的，例如改变binwidth（组距宽度）或者指定break（切分位置）

#多种方式进行数据的跨组比较：
depth_dist = ggplot(diamonds, aes(depth)) + xlim(58, 68)
depth_dist + geom_histogram(aes(y = ..density..), binwidth = 0.1) + facet_grid(cut ~ .)#同时绘制多个小直方图
depth_dist + geom_histogram(aes(fill = cut), binwidth = 0.1, position = "fill") #使用条件密度图
depth_dist + geom_freqpoly(aes(y = ..density.., colour = cut), binwidth = 0.1) #使用频率多边形
#直方图和频率多边形都使用了统计变换 stat_bin，他产生两个输出变量：count和density，count是默认值，density则多用于比较数据中不同大小子集的分布，
#或者是比较不同的分布形状而不是数据的绝对大小时使用

#箱线图：一个变量针对一个类别型变量取条件所得的图形
#geom_boxplot=stat_boxplot+geom_boxplot
library(plyr)
qplot(cut, depth, data = diamonds, geom = "boxplot") #类别型变量取条件
qplot(carat, depth, data = diamonds, geom = "boxplot", group = round_any(carat, 0.1, floor), xlim = c(0, 3)) #连续型变量取条件，通过设置group属性来实现

#扰动图：通过在离散型分布上添加随机噪声来避免遮盖绘制问题，是避免遮盖的一种粗糙手法
#geom_jitter=position_jitter+geom_point
qplot(class, cty, data = mpg, geom = "point") #如果不添加随机噪声
qplot(class, cty, data = mpg, geom = "jitter") #添加噪声
qplot(class, drv, data = mpg, geom = "jitter") #更换纵坐标变量

#密度曲线：基于核平滑方法进行平滑后得到的频率多边形，使用adjust参数来调整平滑度，密度图实际就是直方图的平滑化版本
#geom_density=stat_density+geom_area
#请仅在一直潜在密度分布为平滑、连续且无界的时候使用这种密度图
qplot(depth, data = diamonds, geom = "density", xlim = c(54, 70))
qplot(depth, data = diamonds, geom = "density", xlim = c(54, 70), fill = cut, alpha = I(0.2))
qplot(depth, data = diamonds, geom = "density", xlim = c(54, 70), fill = cut, alpha = 0.2) #注意与上边的区别，上边的结果是想要的，这个是有问题的

#5.5 处理遮盖绘制问题
#散点图是研究两个连续变量间关系的重要工具，但是当数据量很大时，这些点经常会出现重叠现象，从而掩盖真实的关系，这种问题被称为：遮盖绘制（overplotting）

#小规模的遮盖：可以通过绘制更小的点加以缓解，或者使用中空的符号
df = data.frame(x = rnorm(2000), y = rnorm(2000))
norm = ggplot(data = df, aes(x, y))
norm + geom_point() #默认
norm + geom_point(shape = 1) #中空点
norm + geom_point(shape = ".") #使用像素大小的点（像素级大小）

#稍大规模的遮盖，可以通过α混合（调整透明度）的方法来让点产生透明叠加的效果，r中支持的最大透明度为1/256，即叠加256次使得一个点不再透明
norm + geom_point(colour = "black", alpha = 1 / 3)
norm + geom_point(colour = "black", alpha = 1 / 5)
norm + geom_point(colour = "black", alpha = 1 / 10)

#如果数据存在一定的离散性，我们可以通过在点上增加随机扰动来减轻重叠，特别是与透明度数据一起使用，很有效果，默认情况下，增加扰动量是数据分辨率的40%
#这样可以为数据中的临接区留下一定的小间隙
td = ggplot(diamonds, aes(table, depth)) + xlim(50, 70) + ylim(50, 70)
td + geom_point() #没有经过处理的原始数据
td + geom_jitter() #添加默认扰动后
jit = position_jitter(width = 0.5) #修改扰动为两个连续整数间距的一半，由于table变量是依据最近的整数做了取整处理，所以可以进行这种扰动量的设置
td + geom_jitter(position = jit) #横向扰动参数为0.5时打散后的点
td + geom_jitter(position = jit, alpha = 1 / 10, colour = "black")
td + geom_jitter(position = jit, alpha = 1 / 50, colour = "black")
td + geom_jitter(position = jit, alpha = 1 / 200, colour = "black")

#受此启发，我们也可以认为遮盖绘制问题是一种二维核密度估计问题，因此又可以有以下两种方法：

#1. 将点分箱，然后统计每个箱子中点的数量，然后通过某种方式可视化这个数量（直方图的二维推广），将图形划分为小的正方形箱可能会产生注意力分散的视觉
#   假象，所以建议使用六边形代替，可以使用geom_hexagon这一几何对象来实现，它使用了hexbin包，使用参数bins和binwidth来控制箱的数量和大小
library(hexbin)
d = ggplot(diamonds, aes(carat, price)) + xlim(1, 3) # + theme(legend.position = "none") 通过这一设定不显示图例

#使用正方形显示分箱
d + stat_bin2d() #默认箱参数
d + stat_bin2d(bins = 10)
d + stat_bin2d(binwidth = c(0.02, 200))

#使用六边形显示分箱
d + stat_binhex() #默认箱参数
d + stat_binhex(bins = 10)
d + stat_binhex(binwidth = c(0.02, 200))

#2. 使用stat_density2d作二维密度估计，并将等高线添加到散点图中，或以着色瓦片（colored tiles）直接展示密度，或者使用大小与分布密度成比例的点进行展示
d = ggplot(diamonds, aes(carat, price)) + xlim(1, 3) # + theme(legend.position="none") 不显示图例
d + geom_point() + geom_density2d() #使用点图层展示数据，使用二维密度统计变化来显示密度等高线
d + stat_density2d(geom = "point", aes(size = ..density..), contour = F) + scale_size_area() #使用大小与分布密度成比例的点进行展示
d + stat_density2d(geom = "tile", aes(fill = ..density..), contour = F) #以着色瓦片（colored tiles）直接展示密度
#可以自己将contour=F去掉看看运行结果
last_plot() + scale_fill_gradient(limits = c(1e-5, 8e-4)) #只显示在1e-5到8e-4之间的密度色块，其余的不着色

#对付遮盖绘制的另一种方法是在图形上添加数据摘要，来寻找模式的真实形状 例如：用geom_smooth来添加一条平滑的曲线

#5.7 绘制地图
#绘制地图两个好用包 maps 和 maptools 
library(maps)
library(maptools)
#ggplot2提供了一些工具使得maps包绘制的地图与其他ggplot2图形的结合变得十分方便
#我们使用地图数据的主要原因有两个：
#1. 为空间数据图形添加参考轮廓线
#2. 通过在不同的区域填充颜色以构建分级统计图（choropleth map）（地区分布图）

#添加地图边界可以通过函数borders()来完成，函数的前两个参数指定了要绘制的地图名map以及其中的具体区域region
data(us.cities)
big_cities = subset(us.cities, pop > 500000) #筛选出人口大于500000的美国城市
qplot(long, lat, data = big_cities) #显示了人口大于500000的美国城市的经纬位置
last_plot() + borders("state", size = 0.5) #使用borders()直接从maps中获取stat的位置数据进行绘制边界
tx_cities = subset(us.cities, country.etc == "TX") #筛选出德克萨斯州下属城市的名称
ggplot(tx_cities, aes(long, lat)) + borders("county", "texas", colour = "grey70") + geom_point(colour = "black", alpha = 0.5)
#在borders()中选择绘制地图名为 "county"中的"texas"（德克萨斯州这个地区的图）

#分级统计图绘制较为麻烦，问题在于如何将我们的数据同地图数据匹配形成一个大的数据框，关键在于我们的数据和地图数据中要有一列可以相互匹配
data(state)
states = map_data("state")#使用map_data()将地图数据转换为数据框，此数据框之后可以通过merge()操作与我们的数据相融合
arrests = USArrests
names(arrests) = tolower(names(arrests)) #把数据框的列名变为小写
arrests$region = tolower(rownames(USArrests)) #在arrests数据中添加一列region 信息为USArrests的行名

choro = merge(states, arrests, by = "region") #states和arrests数据中都存在region这一列且二者可以互相匹配，使用merge函数将他们合并

choro = choro[order(choro$order),] #由于通过绘制多边形来绘制地图时涉及到点的连接顺序问题，在使用merge后破坏了原始的order列的排序，因此
#要对它重新排序，这之后的数据体才能用来合理的绘制分级统计图

qplot(long, lat, data = choro, group = group, fill = assault, geom = "polygon") #展示美国各州人身伤害的案件数量
qplot(long, lat, data = choro, group = group, fill = assault / murder, geom = "polygon")

#使用map_data函数处理数据
library(plyr)
ia = map_data("county", "iowa")
mid_range = function(x) mean(range(x, na.rm = TRUE))
centres = ddply(ia, .(subregion), colwise(mid_range, .(lat, long)))#见数据清洗 dply包的函数 ddply colwise

ggplot(ia, aes(long, lat)) + geom_polygon(aes(group = group), fill = NA, colour = "grey60") + geom_text(aes(label = subregion), data = centres, size = 2, angle = 45)

#5.8 揭示不确定性
#ggplot2中共有四类几何对象可以用于这项工作，具体使用哪个取决于x的值是离散型还是连续型，以及我们是否想要展示区间内的中间值，
#或者仅仅展示区间
#这些几何对象均假设我们对给定x时y的条件分布感兴趣，并且都是用ymin和ymax来确定y的值域
#
#  变量X类型         仅展示区间              同时展示区间和中间值
#   连续型           geom_ribbon             geom_smooth(stat="identity")
#   离散型           geom_errorbar           geom_crossbar
#                    geom_linearange         geom_pointrange

#下例拟合了一个双因素含交互效应回归模型，并展示了如何提取边际效应和条件效应，以及如何将其可视化
data(diamonds)
d = subset(diamonds, carat < 2.5 & rbinom(nrow(diamonds), 1, 0.2) == 1)
d$lcarat = log10(d$carat)
d$lprice = log10(d$price)

#剔除整体的线性趋势
detrend = lm(lprice ~ lcarat * color, data = d)
d$lprice2 = resid(detrend)

mod = lm(lprice2 ~ lcarat * color, data = d)

library(effects)
effectdf = function(...) { suppressWarnings(as.data.frame(effect(...))) }
color = effectdf("color", mod)
both1 = effectdf("lcarat:color", mod)

carat = effectdf("lcarat", mod, default.levels = 50)
both2 = effectdf("lcarat:color", mod, default.levels = 3)

#画图
qplot(lcarat, lprice, data = d, colour = color) #该图数据对x轴和y轴的数据均取以10为底的对数，以剔除非线性性
qplot(lcarat, lprice2, data = d, colour = color) #该图剔除了主要趋势

fplot = ggplot(mapping = aes(y = fit, ymin = lower, ymax = upper)) + ylim(range(both2$lower, both2$upper))
fplot %+% color + aes(x = color) + geom_point() + geom_errorbar()
fplot %+% both2 + aes(x = color, colour = lcarat, group = interaction(color, lcarat)) + geom_errorbar() + geom_line(aes(grouping = lcarat)) + scale_colour_gradient()

fplot %+% carat + aes(x = lcarat) + geom_smooth(stat = "identity")

ends = subset(both1, lcarat == max(lcarat))
fplot %+% both1 + aes(x = lcarat, colour = color) + geom_smooth(stat = "identity") + scale_colour_hue()+ theme(legend.position = "none") + geom_text(aes(label = color, x = lcarat + 0.02), ends)


#5.9 摘要统计
#对于每个x的值计算对应的y值的统计摘要通常是很有用的，在ggplot2中，这一角色由stat_summary()担当，它使用ymin，y，ymax等图形属性
#为汇总y的条件分布提供一种灵活的方式
#使用方式：1.单独制定摘要计算函数  2.使用统一的函数对他们进行组合

#5.9.1 单独的摘要计算函数
#参数fun.y,fun.ymin,fun.ymax能够接受简单的数值型摘要计算函数，即该函数能够传入一个数值向量并返回一个数值型结果，如
#mean()，median(),min(),max()
stat_summary(aes(colour = "raw"), fun.y = mean, geom = "point")

#统一的摘要计算函数
#fun.data可以支撑更加复杂的摘要计算函数，例如使用Hmisc包中的摘要计算函数

#5.10 添加图形注解
#在使用额外的标签注解图形时要记住的重要的一点是：这些注解仅仅是额外的数据添加而已。
#添加图形注解有两种基本方式：逐个添加 或 批量添加

#逐个添加的方式适合少量的、图形属性多样化的注解。我们只要为所有想要的图形属性设置好对应的值就可以了。
#如果我们要添加多个具有类似属性的注解，将他们放到数据框中并一次性添加完成也许更有效

#下面我们使用上面两种方法向经济数据中添加美国总统的信息
data(economics)
unemp= qplot(date, unemploy, data = economics, geom = "line", xlab = "", ylab = "No. unemployed(1000s)")
print(unemp)

presidential1=presidential[-(1:3),]

yrng = range(economics$unemploy)
xrng = range(economics$date)
unemp + geom_vline(aes(xintercept = as.numeric(start)), data = presidential1)

library(scales)
unemp + geom_rect(aes(NULL, NULL, xmin = start, xmax = end, fill = party), ymin = yrng[1], ymax = yrng[2], data = presidential1, alpha = 0.2) + scale_fill_manual(values = c("blue", "red"))#添加不同党派颜色的区间背景色
last_plot() + geom_text(aes(label = name, x = start, y = yrng[1]), data = presidential1, size = 5, hjust = 0, vjust = 0)#添加总统名字
last_plot() + geom_vline(aes(xintercept = as.numeric(start)), data = presidential1)

caption = paste(strwrap("Unemployment rates in the US have varied a lot over the years", 40), collapse = "\n")
unemp + geom_text(aes(x, y, label = caption), data = data.frame(x = xrng[2], y = yrng[2]), hjust = 3, vjust = 3, size = 4) #添加说明
#hjust调整水平位置，vjust调整竖直位置，正数表示向左（上）移动，负数表示向右（下）移动


highest = subset(economics, unemploy == max(unemploy))
unemp + geom_point(data = highest, size = 5, colour = "red", alpha = 0.5) #在最值处添加点标识
last_plot() + geom_text(aes(label = "最大失业点"), data = highest, size = 5, hjust = -0.125) #对最大点添加说明

#geom_text可添加文字叙述或为点添加标签，对于多数图形，为所有观测添加标签是无益的，然而（通过区子集）抽取部分观测添加标签可能会非常有用，因为我们往往希望标注出离群点或其他重要的点
#geom_vline,geom_hline 向图形添加垂直或者水平的线
#geom_abline 向图形添加任意斜率和截距的直线
#geom_rect 可用来强调图形中感兴趣的矩形区域。geom_rect拥有xmin，xmax，ymin，ymax几种图形属性
#geom_line,geom_path,geom_segment都可以添加直线，所有这些几何对象都有一个arrow参数，可以用来在线上放置一个箭头
#arrow()函数绘制箭头，它拥有angle，length，ends，以及type几个参数

#5.11 含权数据
#在处理整合后的数据（aggregated data）时，数据集的每一行可能代表了多种观测值，这取决于你使用的权重，因此此时我们要把权重变量考虑进去

#以美国2000年人口普查的中西部各州的统计数据为例

#权重变量的不同将极大的影响图形内容以及观察结论，有两种可以用于表现权重的可调图形属性
#1. 对于点、线这类简单的几何对象，我们可以调整图形属性size来改变点的大小
data(midwest)
qplot(percwhite, percbelowpoverty, data = midwest) #无权重图
qplot(percwhite, percbelowpoverty, data = midwest, size = poptotal / 1e6) + scale_size_area("Population\n(millions)", breaks = c(0.5, 1, 2, 4))
#以人口数量为权重
qplot(percwhite, percbelowpoverty, data = midwest, size = area) + scale_size_area() #以面积为权重

#2. 对于更复杂的、设计到统计变换的情况，我们通过修改weight图形属性来表现权重，这些权重将被传递给统计汇总计算函数
#   在权重有意义的情况下，各种元素基本都支持权重设定，例如：各类平滑器，分位回归，箱线图，直方图以及各类密度图
#   我们无法看到这个权重变量，而且他也没有对应的图例，但是它却会改变统计汇总结果

#下面显示了 人口密度作为权重如何影响 白种人比例和贫困线以下人口比例 的关系
lm_smooth = geom_smooth(method = lm, size = 1)
qplot(percwhite, percbelowpoverty, data = midwest) + lm_smooth #不考虑权重的最优拟合曲线
qplot(percwhite, percbelowpoverty, data = midwest, weight = popdensity, size = popdensity) + lm_smooth #以人口数量作为权重的最优拟合曲线

#下面的图展示了 当我们使用总人口作为权重去修改直方图或者密度图的时候，我们的视角将从对郡数量分布的观察转向对人口数量分布的观察
qplot(percbelowpoverty, data = midwest, binwidth = 1)#无权重，表示了贫困比例在郡数量上的分布
qplot(percbelowpoverty, data = midwest, weight = poptotal, binwidth = 1) + ylab("population")#加入人口数量权重，表示了贫困比例在人口数量上的分布
#权重的加入极大改变了对图的解释








