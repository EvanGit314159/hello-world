# R语言地图绘制简单示例 / Simple R Map Example
# 这是一个最小化的示例，用于演示基本概念
# This is a minimal example to demonstrate basic concepts

# 检查并安装必要的包 / Check and install necessary packages
check_and_install <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(sprintf("正在安装包: %s / Installing package: %s\n", pkg, pkg))
      install.packages(pkg, repos = "https://cloud.r-project.org/")
      library(pkg, character.only = TRUE)
    } else {
      cat(sprintf("包已安装: %s / Package already installed: %s\n", pkg, pkg))
    }
  }
}

# 主程序 / Main program
main <- function() {
  cat("\n====================================\n")
  cat("R语言地图绘制示例 / R Map Example\n")
  cat("====================================\n\n")
  
  # 检查必要的包 / Check required packages
  cat("检查必要的包... / Checking required packages...\n")
  required_packages <- c("ggplot2", "maps")
  
  tryCatch({
    check_and_install(required_packages)
    cat("\n所有必要的包已就绪！/ All required packages are ready!\n")
    cat("\n提示: 运行 'source(\"map_visualization.R\")' 来生成地图\n")
    cat("Tip: Run 'source(\"map_visualization.R\")' to generate maps\n\n")
  }, error = function(e) {
    cat("\n错误: ", e$message, "\n")
    cat("Error: ", e$message, "\n")
  })
}

# 运行主程序 / Run main program
# 只在交互式会话中或直接执行时运行
# Only run in interactive sessions or when executed directly
if (interactive()) {
  main()
}
