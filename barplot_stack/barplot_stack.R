#unit(c(0.5, 1.5, 4, 4)
#0.5 : 样本标签的高度
#1.5 : 柱状图的高度

setwd("D:/project/Rstudio/heatmap_huyukai")
library(ComplexHeatmap)
library(circlize)
data <- read.table("./New_all.SNP_common_ratio4.xls",sep = "\t",header = TRUE)
rownames(data) <- c("A","B","C")
#lgd = Legend(labels = title)
#title <- c("A","B","C")
lgd_boxplot = Legend(labels = c("A", "B","C"), title = "type",
                     legend_gp = gpar(fill =c("red","blue","yellow")))
ha = HeatmapAnnotation(df = data.frame(group = group),
     stack.col.anno = column_anno_barplot(t(data), axis = TRUE,gp= gpar(fill =c("red","blue","yellow"))),
     annotation_height = unit(c(0.5, 10.5, 0.5, 1), "cm"))
#lgd = legendGrob(c("A","B","C"),gp= gpar(col =c("#bf94e4","#bf94e4","#1dacd6")))
#draw(ha,1:10)
zero_row_mat = matrix(nrow = 0, ncol = 58)
colnames(zero_row_mat) = colnames(data)
ht = Heatmap(zero_row_mat, top_annotation = ha, column_title = "frequency map")
#draw(ht, padding = unit(c(5, 20, -10, 2), "mm"))
draw(ht, padding = unit(c(5, 20, -10, 2), "mm"), 
     heatmap_legend_list = list(lgd_boxplot))
decorate_annotation("group", {grid.text("group", unit(-2, "mm"), just = "right")})
