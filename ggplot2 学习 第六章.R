#第六章 标度 坐标轴和图例
#6.1 简介
#标度控制着数据到图形属性的映射：标度的定义域提供了标度变量的取值范围，标度的值域包含了我们可感知，R能够理解的图形属性
#标度执行分为三个过程：变换，训练和映射
#标度粗略的可以分为四类： 位置标度，颜色标度，手动离散型标度和同一型标度

#标度的另一个重要角色：生成允许读图者从图形属性空间到数据空间进行反向映射的引导元素，并从图中读出值。
#对于位置型图形属性，引导元素是坐标轴。对于其他图形属性来说，引导元素是图例
#引导元素的外观皆由标度的参数控制，不存在gglegend或者ggaxis这种修改图例或坐标轴的函数

#6.2 标度的工作原理
#标度的定义域（数据空间）---标度的值域（图形属性空间）

#定义域：离散型：某些值组成的集合，以因子的形式储存； 连续型：实值区间，以长度为2的数值向量形式存储
#值域：离散型：输入值对应的图形属性值组成的一个向量； 连续型：穿过某种更复杂空间的一条一维的路径

#将定义域映射到值域包含以下几个阶段：
#变换：（仅针对连续型的定义域）对数据变换后再展示是有益处的
#训练：通过学习得到标度的定义域。定义域也可以通过limits跳过训练过程直接指定，在此标度定义域外的任何值都将被映射为NA
#映射：有了定义域和值域，对他们进行映射即可

#6.3 用法
#如果要添加一个不同的标度或修改默认标度的某些特征，我们必须构造一个新的标度，然后使用+将其添加到图层上
#标度构建器有一套通用的命名股则：他们以scale_开头，接下来是图形属性名称（例如 colour_、shape_或者x_）,最后以标度的名称结尾（例如 gradient、hue或者manual）

#修改默认标度
library(ggplot2)
data(mpg)
data(mtcars)

p = qplot(sleep_total, sleep_cycle, data = msleep, colour = vore) #不添加任何标度，则使用默认标度
print(p)

p + scale_colour_hue() #手动添加默认标度

p + scale_colour_hue("What does\nit eat?", breaks = c("herbi", "carni", "omni", NA), labels = c("plants", "meat", "both", "don't know"))
#修改默认标度参数，这里改变了图例的外观

p + scale_colour_brewer(palette = "Set1") #使用了一种不同的标度

#6.4 标度详解
#标度可大致分为以下四种：
#位置标度：用于将连续型、离散型和日期-时间型变量映射到绘图区域，以及构造对应的坐标轴
#颜色标度：用于将连续型和离散型变量映射到颜色
#手动标度：用于将离散型变量映射到我们选择的符号大小、线条类型、形状或颜色，以及创建对应的图例
#同一型标度：用于直接将变量值绘制为图形属性，而不去映射他们

#6.4.1 通用参数
#name 设置坐标轴和图例标签，可以指定字符串或数学表达式，由于经常要微调，因此有三个辅助函数 xlab，ylab，labs
p = qplot(cty, hwy, data = mpg, colour = displ)
p
p+scale_x_continuous("City mpg")
p + xlab("City mpg")
p + ylab("Highway mpg")
p + labs(x = "City mpg", y = "Highway", colour = "Displacement")
p + xlab(expression(frac(miles, gallon)))
#标签可以接受不同形式的参数

#limits:用来固定标度的定义域，连续型标度接受一个长度为2的数值型向量，离散型标度接受一个字符型向量
#breaks和labels：breaks控制着显示在坐标轴和图例上的值，即坐标轴上应该显示哪些刻度线的值，或者一个连续型标度在图例中应该如何分段
#                labels指定了在断点处应该显示的标签，若设置了labels则必须同时指定breaks，只有这样两个参数才能被正确匹配
#要注意breaks和limits的区别，breaks影响显示在坐标轴和图例上的元素，limits影响显示在图形上的元素
p = qplot(cyl, wt, data = mtcars) #使用默认设置limits=c(4,8) breaks=c(4,8)
p
p + scale_x_continuous(breaks = c(5.5, 6.5)) #修改breaks但是显示的数据依然有在[4,8]区间内，只是在x轴上没有了相应的数据标签
p + scale_x_continuous(limits = c(5.5, 6.5)) #修改limits显示的数据在[5.5,6.5]之间，breaks没有设置，自动默认在这个区间内细分

p = qplot(wt, cyl, data = mtcars, colour = cyl)
p
p + scale_colour_gradient(breaks = c(5.5, 6.5)) #修改了breaks使得显示的图例标签变成了[5.5,6.5]但不影响点的颜色变化范围
p + scale_colour_gradient(limits = c(5.5, 6.5)) #修改了limits使得在[5.5,6.5]区间内的点才有颜色，在区间外的点没有这个属性显示

#formatter：如果未指定任何标签，则将在断点处自动调用格式刷（formatter）来格式化生成标签
#           对于连续型标度可用标签刷为：comma，percent，dollar和scientific
#           对于离散型标度，则为abbreviate

#6.4.2 位置标度
#一幅图必定拥有两个位置标度：水平位置标度x和竖直位置标度y；ggplot2提供三种类型的该种标度：连续型，离散型（针对 因子型、字符型和逻辑性向量），
#以及日期型标度

#由于经常修改坐标轴范围，因此ggplot2提供了一对辅助函数xlim,ylim
xlim(10, 20) #从10到20的连续型标度
xlim(20, 10) #从20到10的反转后的连续型标度
xlim("a", "b", "c") #一个离散型标度
xlim(as.Date(c("2008-05-01", "2008-08-01"))) #一个从2008年5月1日到8月1日的日期型标度
#任何在limits以外的数据都不会被绘制也不会被包括在统计变换之中

#默认情况下位置标度limits会稍微超出数据范围，这样就保证了数据与坐标轴不会重叠，我们可以使用参数expand来控制溢出量，此参数是长度为
#2的数值型向量，其中第一个元素给出的是乘式的溢出量，第二个参数给出的是加式的溢出量，如果不想要任何多余空间，expand=c(0,0)即可

#连续型：
#连续型位置标度最常用的是scale_x_continuous和scale_y_continuous他们均将数据映射到x轴和y轴，每个连续型标度均可以接受一个trans参数
#允许指定若干种线性或非线性的变换，每一种变换都是由所谓的“变换器”来实现的，变换器描述了变换本身和对应的逆变换，以及如何绘制标签
#常用见 p107
#变换常被用来修改位置标度，因此对于x，y，z标度都是有简便写法的：scale_x_log10等价于scale_x_continuous(trans="log10")
#注意参数trans对任意连续型标度都有效，包括颜色梯度等，但是仅有位置标度存在简便写法

#注意对数据进行自行变换绘图和使用变换器绘图在坐标轴和刻度标签上的区别，虽然图形一模一样
qplot(log10(carat), log10(price), data = diamonds)
ggplot(data = diamonds, aes(carat, price)) + geom_point() + scale_x_log10() + scale_y_log10()

#日期和时间型：
#日期和时间值基本属于连续型，但在标注坐标轴的时候有着特殊的处理方法，可以使用as.Date或as.POSIXct来转换我们的时间值变为可处理的类型
library(scales)
plot = qplot(date, psavert, data = economics, geom = "line") + ylab("Personal savings rate") + geom_hline(yintercept = 0, colour = "grey50")
#默认显示外观
plot
plot + scale_x_date(breaks = date_breaks("10 years")) #修改x位置标度为10年一个断点
plot + scale_x_date(limits = as.Date(c("2004-01-01", "2005-01-01")), labels = date_format("%y-%m-%d")) #使用年月日格式显示2004年内的图形
#关于日期格式的编码含义 见书 p109

#离散型：
#离散型位置标度将输入中的各水平映射为整数，结果顺序可以使用参数breaks进行控制，不想要的水平可以使用limits进行丢弃

#6.4.3 颜色标度
#rgb色彩空间（使用红绿蓝三种光的光强来表示一种颜色）在感知上并不均匀，因此映射一个连续型变量到这个颜色集十分困难，ggplot2采用了hcl色彩空间
#hcl色彩空间：色相（hue） 彩度（chroma） 明度（luminance）
#色相：是一个0到360度之间的角度值，他讲一种色彩赋以“颜色”属性：如 蓝、红、橙等
#明度：指颜色的明暗程度，明度的高低要看其接近白色或者黑色的程度，0为黑1为白
#彩度：指色彩的纯度，0为灰色，彩度的最大值随着明度的变化而不同

#连续型：
#根据颜色梯度中的色彩数量划分，共有三类连续型梯度（即渐变色）

#双色梯度：scale_colour(fill)_gradient()，使用low和high参数控制此梯度两端的颜色
#三色梯度：scale_colour(fill)_gradient2()，顺序为低-中-高，参数low high作用同上，默认中点值为0，可以通过midpoint来修改
#自定义n-色梯度：scale_colour(fill)_gradientn()，此梯度需要赋值一个颜色向量给参数colours，使用values参数来使这些颜色参数不均匀分布（默认均匀）
#                如果rescale参数取值为true（默认），则values值在0-1之间，如果rescale取值为false，则values在数据范围内取值

#颜色梯度常被用来展示一个二维表面的高度，下面我们以faithful数据展示
data(faithful)
f2d = with(faithful, MASS::kde2d(eruptions, waiting, h = c(1, 10), n = 50)) #使用MASS包中的kde2d进行二维核密度估计
df = with(f2d, cbind(expand.grid(x, y), as.vector(z))) #由于上一步计算结果不是数据框格式，因此在这里变成数据框
names(df) = c("eruptions", "waiting", "density") #更改数据的列名

#上面为数据处理过程，下面开始画图
erupt = ggplot(df, aes(waiting, eruptions, fill = density)) + geom_tile() + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))
erupt + scale_fill_gradient(limits = c(0, 0.04))
erupt + scale_fill_gradient(limits = c(0, 0.04), low = "white", high = "black")
erupt + scale_fill_gradient2(limits = c(-0.04, 0.04), midpoint = mean(df$density))

#要创建自定义颜色梯度，使用scale_colour_gradientn()即可，这在颜色代表数据特征时很有用（例如：某个黑体的颜色或者标准地形的颜色）
#或者你也可以调用其他的包生成的调色板，以下代码展示了使用vcd包生成的调色板
fill_gradn = function(pal) { scale_fill_gradientn(colours = pal(7), limits = c(0, 0.04)) } #pal(7)表示取这种调色盘的7种颜色，生成一个颜色向量
erupt + fill_gradn(rainbow)


#离散型：离散数据有两种颜色标度，一种可以自动选择颜色，另一种可以轻松的从手工甄选的颜色集中选择颜色
#默认配色方案：scale_colour_hue()，他可以通过沿着hcl色轮选取均匀分布的色相来生成颜色，这种方案对多至约8种颜色时都能有较好的效果，但对于更多的颜色
#要区分开不同的颜色就变得比较困难，默认配色的另外一个缺点是，由于所有颜色都拥有相同的明度和彩度，所以黑白打印时，他们就会成为几近相同的灰影
#除了这种基于计算的方案外，另一种可选方案就是使用ColorBrewer配色，该配色更专注于地图，因此在展示较大面积时表现更佳。
#对于类别型数据的点而言，我们最感兴趣的调色盘是“Set1”和“Dark2”，对面积而言是“Set2”，“Pastel1”，“Pastel2”和“Accent”
library("RColorBrewer")
data(msleep)
point = qplot(brainwt, bodywt, data = msleep, log = "xy", colour = vore)
area = qplot(log10(brainwt), data = msleep, fill = vore, binwidth = 1)

point
point + scale_colour_brewer(palette = "Set1")
point + scale_colour_brewer(palette = "Set2")
point + scale_colour_brewer(palette = "Pastel1")
area + scale_fill_brewer(palette = "Set1")
area + scale_fill_brewer(palette = "Set2")
area + scale_fill_brewer(palette = "Pastel1")

#如果要使用自制的离散型颜色标度，可使用下文所述的scale_colour_manual()

# 6.4.4 手动离散型标度（要很好的使用手动离散标度，要了解一些可用的图形属性值 附录B）
#离散型标度：scale_linetype(),scale_size_discrete()和scale_shape()基本上没有选项（虽然对于形状标度，你可以选择是空心可填充还是实心的），
#            这些标度仅仅是按一定的顺序将因子的水平映射到一系列取值中
#手动离散型标度：如果你想要定制这些标度，你需要使用一下手动型标度创建新的标度
#                scale_shape_manual(),scale_linetype_manual(),scale_colour_manual()等，手动型标度有一个重要参数values，values是个向量，可以通过它来指定这
#                个标度应该生成的值，因为是离散型标度每个标度对应的定义域就是离散变量的水平，可以通过指定每个水平对应的值来进行匹配，此时values向量中每个
#                元素是要有名称的，这些名称对应于离散变量的水平，否则它将按照离散变量中水平出现的先后次序进行匹配

plot = qplot(brainwt, bodywt, data = msleep, log = "xy")
#按照水平先后顺序进行匹配
plot + aes(colour = vore) + scale_colour_manual(values = c("red", "orange", "yellow", "green", "blue")) #通过这种手动方式指定每个离散水平要映射成什么值

#指定每个名字的水平对应什么值
colours = c(carni = "red", "NA" = "orange", insecti = "yellow", herbi = "green", omni = "blue")
plot + aes(colour = vore) + scale_colour_manual(values = colours) #values向量元素有名称，名称对应于离散变量水平，来指定匹配方式

#手动指定点的形状，注意首先要存在shape这个属性的映射
#注意下面两个代码的区别
plot + aes(colour = vore) + scale_shape_manual(values = c(1, 2, 6, 0, 23)) #这段代码没有指定shape属性的映射对象，因此后面改变标度也于事无补
plot + aes(colour = vore, shape = vore) + scale_shape_manual(values = c(1, 2, 6, 0, 23)) #这段代码就可以通过不同颜色不同形状来显示


#如果我想把两个数据变量，显示在同一副图中
#方案一：把这两组数据合并，并新建一个属性值，两组数据通过这个属性进行区分，然后画图，把颜色映射到这个新建的属性上，这样图例就会自动产生，然后通过labels来修改名称
#方案二：我不想这么麻烦合并数据，那么我们可以通过绘制两个图层来把这两组数据放在同一个图中，但是者出现了一个问题，图例怎么办，图例是通过属性映射，利用标度自动完成的
#        不能像其他绘图函数一样自己diy，这时候我们就可以通过手动标度来解决这个问题，在属性映射中自己添加对应的映射属性，然后使用属性manual来修改

#下面就是一种创意举例

#下面的代码，标度不知道要为线条添加何种标签，虽然能区别显示出不同的线，但是没法产生图例，注意此处的颜色是设定，不是映射
huron = data.frame(year = 1875:1972, level = LakeHuron)
ggplot(huron, aes(year)) + geom_line(aes(y = level - 5), colour = "blue") + geom_line(aes(y = level + 5), colour = "red")

#要想产生正常的图例，首先要通过创建从数据到颜色图形属性的一个映射，来告诉颜色标度这两条线的信息，由于此数据中并没有合适颜色的变量，就自己创建
ggplot(huron, aes(year)) + geom_line(aes(y = level - 5, colour = "below")) + geom_line(aes(y = level + 5, colour = "above"))
#可以看到上面的代码就有图例了，因为有了对应的属性映射，但是这个图例的标签,颜色都是有问题的，因此可以使用scale_colour_manual来进行修改
ggplot(huron, aes(year)) + geom_line(aes(y = level - 5, colour = "below")) + geom_line(aes(y = level + 5, colour = "above")) + scale_colour_manual("Direction", values = c("below" = "blue", "above" = "red"), labels = c("blue", "red"))


# 6.4.5 同一型标度  scale_identity
#当你的数据能被R中的绘图函数理解时，即数据空间和图形属性空间相同时，可以使用同一型标度（定义域就是值域），但是仅从数据本身是无法生成有意义的图例的，所以
#默认是不生成图例（没有映射关系），但是如果你仍然想要一个，则可以使用参数breaks和labels进行设定，此时你需要自己考虑那些断点和标签对你的数据是有意义的


# 6.5 图例和坐标轴
#坐标轴和坐标被共同称为 引导元素，他们都是标度的逆函数，他们允许你在图中读出观测并将其映射回原始值















