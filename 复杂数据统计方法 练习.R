#实践9（数据输入输出）
x = scan()

#实践10（序列等）
z = seq(-1, 10, length = 100) #从-1到10等间距产生100个数
z = seq(-1, 10, len = 100)
x = rep(1:3, 3)
x = rep(3:5, 1:3)
x = rep(c(1, 10), c(4, 5))
w = c(1, 3, x, z)
w[3]
x = rep(0, 10);
z = 1:3;
x + z
x * z
rev(x)
z = c("no cat", "has ", "nine", "tails")
z[1]
z = factor(z)
levels(z)
rev(z)
z[1] == "no cat"
z = 1:5
z[7] = 8
z = NULL
z[c(1, 3, 5)] = 1:3
z
rnorm(10)[c(2, 5)]
z[-c(1, 3)]#去掉第1,3个元素
z = sample(1:100, 10)
which(z == max(z)) #给出最大值的下标


#实践14（矩阵与向量之间的运算）
x = matrix(1:20, 5, 4)
sweep(x, 1, 1:5, "*")
x * 1:4
#下面把x标准化，即每一个元素减去该列的均值，然后除以该列的标准差
x = matrix(sample(1:100, 24), 6, 4)
x1 = scale(x)
x2 = scale(x, scale = F)
x3 = scale(x, center = F)
x
x1
x2
x3
round(apply(x1, 2, mean), 14)
apply(x1, 2, sd)
round(apply(x2, 2, mean))
apply(x2, 2, sd)
round(apply(x3, 2, mean))
apply(x3, 2, sd)
#上面应该是一个数学问题，centre scale？