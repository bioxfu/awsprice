#' Download and extract EC2 pricing table from web page
#'
#' @export
#'
#' @import rvest
#' @import xml2
#' @import dplyr
#' @import stringi
fetch_price_table <- function() {
  price <- read_html("https://www.amazonaws.cn/ec2/pricing/ec2-linux-pricing")
  tables <- price %>% html_table(header = TRUE, fill = TRUE)

  # stringi::stri_escape_unicode(c("通用型实例", "计算优化型实例", "GPU 实例", "内存优化型实例", "存储优化型实例"))
  # stringi::stri_escape_unicode(c("实例", "实例类型", "内存", "宁夏", "北京", "不适用"))
  tb_nx <- tables[[1]]
  x <- c(grep(stri_unescape_unicode('\\u5b9e\\u4f8b'), tb_nx[, stri_unescape_unicode('\\u5b9e\\u4f8b\\u7c7b\\u578b')]), nrow(tb_nx)+1)
  tb_nx$type <- stri_unescape_unicode(rep(c("\\u901a\\u7528\\u578b\\u5b9e\\u4f8b", "\\u8ba1\\u7b97\\u4f18\\u5316\\u578b\\u5b9e\\u4f8b", "GPU \\u5b9e\\u4f8b", "\\u5185\\u5b58\\u4f18\\u5316\\u578b\\u5b9e\\u4f8b", "\\u5b58\\u50a8\\u4f18\\u5316\\u578b\\u5b9e\\u4f8b"), diff(x)))
  tb_nx <- tb_nx[grep('[0-9]', tb_nx[, grep(stri_unescape_unicode('\\u5185\\u5b58'), colnames(tb_nx))]), -3]
  colnames(tb_nx) <- c('Type_en', 'vCPUs', 'Memory', 'Storage', 'Price', 'Type_cn')
  tb_nx$Region <- stri_unescape_unicode('\\u5b81\\u590f')

  tb_bj <- tables[[7]]
  colnames(tb_bj) <- sub('+GiB)', '', colnames(tb_bj))
  x <- c(grep(stri_unescape_unicode('\\u5b9e\\u4f8b'), tb_bj[, stri_unescape_unicode('\\u5b9e\\u4f8b\\u7c7b\\u578b')]), nrow(tb_bj)+1)
  tb_bj$type <- stri_unescape_unicode(rep(c("\\u901a\\u7528\\u578b\\u5b9e\\u4f8b", "\\u8ba1\\u7b97\\u4f18\\u5316\\u578b\\u5b9e\\u4f8b", "GPU \\u5b9e\\u4f8b", "\\u5185\\u5b58\\u4f18\\u5316\\u578b\\u5b9e\\u4f8b", "\\u5b58\\u50a8\\u4f18\\u5316\\u578b\\u5b9e\\u4f8b"), diff(x)))
  tb_bj <- tb_bj[grep('[0-9]', tb_bj[, grep(stri_unescape_unicode('\\u5185\\u5b58'), colnames(tb_bj))]), -3]
  colnames(tb_bj) <- c('Type_en', 'vCPUs', 'Memory', 'Storage', 'Price', 'Type_cn')
  tb_bj$Region <- stri_unescape_unicode('\\u5317\\u4eac')

  tb <- rbind(tb_nx, tb_bj)
  tb <- tb[!tb$Price %in% c('N/A', stri_unescape_unicode('\\u4e0d\\u9002\\u7528')), ]
  tb$Price <- as.numeric(tb$Price)
  tb$Memory <- sub('GiB', '', tb$Memory)
  tb$Memory <- sub(',', '', tb$Memory)
  tb
}
