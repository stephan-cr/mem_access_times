# Copyright (C) 2011, Stephan Creutz
# Distributed under the MIT License

# to plot graph the R library "lattice" (by Deepayan Sarkar) for multivariate
# data plots the following two packages may be installed separately
#
# one option to install those packages is to do the following in R:
# install.packages(c('lattice', 'latticeExtra'))
#
# another option under Linux would be to install the according packages from the
# Linux distribution
library(lattice)
library(latticeExtra)

# read file content, the first line is expected to have a title for each column.
# the result is assigned to a so called data frame
read.table('output/run_time_sum', header=TRUE) -> t

# the measurements where done in several runs, calculate the trimmed mean
# divide all rows into groups of rows with the same b, k and s and calculate the
# mean of the time for each group of rows
aggregate(t$time, by=list(t$b, t$k, t$s), mean, trim=0.05) -> t
names(t) <- c('b', 'k', 's', 'time')

# change the unit to mega byte and multiply by the size of integers
t$s <- t$s * 4 / 1024 / 1024

# "pdf" plot device, paper is A4 landscape
trellis.device('pdf', file='mem_access_time_graph_s.pdf', color=F, paper='a4r')
xyplot(time ~ s | as.factor(b), data=t, type='b', groups=k,
       auto.key=list(rectangles=F, lines=T, columns=4, cex=0.75, title='k = # consecutive locations'),
       xlab='s = memory size [MB]', ylab='t = time [ns]',
       par.strip.text=list(cex=0.75), scales=list(y=list(relation='free', rot=45, log=10)),
       # the following line is not really important
       strip=strip.custom(strip.names=c(TRUE, TRUE), var.name='b'),
       par.settings=ggplot2like(n=8), lattice.options=ggplot2like.opts(), axis=axis.grid)
dev.off() -> null

trellis.device('pdf', file='mem_access_time_graph_k.pdf', color=F, paper='a4r')
xyplot(time ~ k | as.factor(b), data=t, type='b', groups=s,
       auto.key=list(rectangles=F, lines=T, columns=4, cex=0.75, title='s = memory size [MB]'),
       xlab='k = # consecutive locations', ylab='t = time [ns]',
       par.strip.text=list(cex=0.75), scales=list(x=list(log=2), y=list(relation='free', rot=45, log=10)),
       # the following line is not really important
       strip=strip.custom(strip.names=c(TRUE, TRUE), var.name='b'),
       par.settings=ggplot2like(n=8), lattice.options=ggplot2like.opts(), axis=axis.grid)
dev.off() -> null

trellis.device('pdf', file='mem_access_time_graph_b.pdf', color=F, paper='a4r')
xyplot(time ~ b | as.factor(s), data=t, type='b', groups=k,
       auto.key=list(rectangles=F, lines=T, columns=4, cex=0.75, title='k = # consecutive locations'),
       xlab='b = # numbers to sum up', ylab='t = time [ns]',
       par.strip.text=list(cex=0.75),
       scales=list(x=list(rot=45, log=2), y=list(relation='free', rot=45, log=10)),
       strip=strip.custom(strip.names=c(TRUE, TRUE), var.name='s'),
       # the following line is not really important
       par.settings=ggplot2like(n=8), lattice.options=ggplot2like.opts(), axis=axis.grid)
dev.off() -> null

trellis.device('pdf', file='mem_access_time_graph_tp.pdf', color=F, paper='a4r')
xyplot(((b * 4) / (time / 1000 / 1000 / 1000) / 1024 / 1024) ~ k | as.factor(s), data=t, type='b', groups=b,
       auto.key=list(rectangles=F, lines=T, columns=4, cex=0.75, title='b = # numbers to sum up'),
       xlab='k = # consecutive locations', ylab='memory throughput [MB/s]',
       par.strip.text=list(cex=0.75),
#       scales=list(x=list(rot=45, log=2), y=list(relation='free', rot=45, log=10)),
       strip=strip.custom(strip.names=c(TRUE, TRUE), var.name='s'),
       # the following line is not really important
       par.settings=ggplot2like(n=8), lattice.options=ggplot2like.opts(), axis=axis.grid)
dev.off() -> null

trellis.device('pdf', file='mem_access_time_graph_to.pdf', color=F, paper='a4r')
xyplot(time / b ~ k | as.factor(s), data=t, type='b', groups=b,
       auto.key=list(rectangles=F, lines=T, columns=4, cex=0.75, title='b = # numbers to sum up'),
       xlab='k = # consecutive locations', ylab='time per operation [ns]',
       par.strip.text=list(cex=0.75),
       scales=list(x=list(rot=45, log=2), y=list(relation='free', rot=45)),
       strip=strip.custom(strip.names=c(TRUE, TRUE), var.name='s'),
       # the following line is not really important
       par.settings=ggplot2like(n=8), lattice.options=ggplot2like.opts(), axis=axis.grid)
dev.off() -> null
