#' Download and extract EC2 pricing table from web page
#'
#' @export
#'
#' @import rvest
#' @import xml2
#' @import dplyr
fetch_price_table <- function() {
  price <- read_html("https://www.amazonaws.cn/ec2/pricing/ec2-linux-pricing")
  tables <- price %>% html_table(header = TRUE, fill = TRUE)

  tb_nx <- tables[[1]]
  x <- c(grep('实例', tb_nx$实例类型), nrow(tb_nx)+1)
  tb_nx$type <- rep(c("通用型实例", "计算优化型实例", "GPU 实例", "内存优化型实例", "存储优化型实例"), diff(x))
  tb_nx <- tb_nx[grep('[0-9]', tb_nx$内存), -3]
  colnames(tb_nx) <- c('Type_en', 'vCPUs', 'Memory', 'Storage', 'Price', 'Type_cn')
  tb_nx$Region <- '宁夏'

  tb_bj <- tables[[7]]
  x <- c(grep('实例', tb_bj$实例类型), nrow(tb_bj)+1)
  tb_bj$type <- rep(c("通用型实例", "计算优化型实例", "GPU 实例", "内存优化型实例", "存储优化型实例"), diff(x))
  tb_bj <- tb_bj[grep('[0-9]', tb_bj$内存), -3]
  colnames(tb_bj) <- c('Type_en', 'vCPUs', 'Memory', 'Storage', 'Price', 'Type_cn')
  tb_bj$Region <- '北京'

  tb <- rbind(tb_nx, tb_bj)
  tb <- tb[!tb$Price %in% c('N/A', '不适用'), ]
  tb$Price <- as.numeric(tb$Price)
  tb$Memory <- sub('GiB', '', tb$Memory)
  tb$Memory <- sub(',', '', tb$Memory)
  tb
}
