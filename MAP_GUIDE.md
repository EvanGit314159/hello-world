# R语言地图绘制指南 / R Map Visualization Guide

## 简介 / Introduction

**中文:**
这个项目展示了如何使用R语言绘制各种类型的地图。包含了从基础到高级的多个地图可视化示例。

**English:**
This project demonstrates how to create various types of maps using the R programming language. It includes multiple map visualization examples ranging from basic to advanced.

## 系统要求 / System Requirements

- R (版本 3.6.0 或更高 / version 3.6.0 or higher)
- 必需的R包 / Required R packages:
  - `ggplot2` - 现代图形系统 / Modern graphics system
  - `maps` - 地图数据包 / Map data package
  - `mapdata` - 额外的地图数据 / Additional map data (可选 / optional)

## 安装 / Installation

### 安装R包 / Install R Packages

在R控制台中运行以下命令 / Run the following commands in R console:

```r
install.packages("ggplot2")
install.packages("maps")
install.packages("mapdata")  # 可选 / optional
```

## 使用方法 / Usage

### 运行脚本 / Running the Script

**中文:**
1. 打开R或RStudio
2. 设置工作目录到项目文件夹
3. 运行脚本：

```r
source("map_visualization.R")
```

**English:**
1. Open R or RStudio
2. Set working directory to the project folder
3. Run the script:

```r
source("map_visualization.R")
```

### 或从命令行运行 / Or Run from Command Line

```bash
Rscript map_visualization.R
```

## 生成的地图 / Generated Maps

脚本将生成以下5个地图文件 / The script will generate 5 map files:

1. **world_map.png** - 世界地图 / World map with all countries
2. **usa_map.png** - 美国地图 / United States map with state boundaries
3. **china_map.png** - 中国地图 / China map
4. **advanced_map.png** - 高级数据可视化地图 / Advanced map with data visualization using color gradients
5. **base_r_map.png** - 基础R系统绘制的地图 / Map created using base R plotting system

## 示例说明 / Examples Explained

### 示例 1: 世界地图 / Example 1: World Map

使用`ggplot2`和`maps`包绘制一个简单的世界地图，展示所有国家的边界。

Uses `ggplot2` and `maps` packages to create a simple world map showing all country boundaries.

### 示例 2: 美国地图 / Example 2: USA Map

绘制美国各州的地图，显示州界线。

Creates a map of US states with state boundaries.

### 示例 3: 中国地图 / Example 3: China Map

从世界地图数据中提取中国的地理边界并单独显示。

Extracts China's geographical boundaries from world map data and displays it separately.

### 示例 4: 高级数据可视化 / Example 4: Advanced Data Visualization

创建一个带有数据可视化的地图，使用颜色渐变来表示不同国家的数值。

Creates a map with data visualization using color gradients to represent values for different countries.

### 示例 5: 基础R绘图系统 / Example 5: Base R Plotting

使用R的基础绘图系统（不依赖ggplot2）创建地图。

Creates a map using R's base plotting system (without ggplot2 dependency).

## 自定义 / Customization

### 更改颜色 / Change Colors

**中文:** 在脚本中修改`fill`和`color`参数来改变地图颜色：

**English:** Modify the `fill` and `color` parameters in the script to change map colors:

```r
geom_polygon(data = world_map, 
             aes(x = long, y = lat, group = group),
             fill = "lightblue",    # 填充颜色 / Fill color
             color = "white")       # 边界颜色 / Border color
```

### 选择不同的区域 / Select Different Regions

**中文:** 使用`map_data`函数选择不同的地理区域：

**English:** Use `map_data` function to select different geographical regions:

```r
# 欧洲 / Europe
europe_map <- map_data("world", region = c("France", "Germany", "Italy", "Spain"))

# 亚洲国家 / Asian countries
asia_map <- map_data("world", region = c("Japan", "South Korea", "Thailand"))
```

### 调整地图大小 / Adjust Map Size

**中文:** 修改`ggsave`函数中的参数：

**English:** Modify parameters in the `ggsave` function:

```r
ggsave("my_map.png", 
       plot, 
       width = 12,      # 宽度（英寸）/ Width in inches
       height = 8,      # 高度（英寸）/ Height in inches
       dpi = 300)       # 分辨率 / Resolution
```

## 进阶技巧 / Advanced Tips

### 1. 添加城市标记 / Add City Markers

```r
cities <- data.frame(
  name = c("北京", "上海", "广州"),
  lon = c(116.4, 121.5, 113.3),
  lat = c(39.9, 31.2, 23.1)
)

ggplot() +
  geom_polygon(data = china_map, aes(x = long, y = lat, group = group)) +
  geom_point(data = cities, aes(x = lon, y = lat), color = "red", size = 3) +
  geom_text(data = cities, aes(x = lon, y = lat, label = name), vjust = -1)
```

### 2. 使用不同的投影 / Use Different Projections

```r
# 使用墨卡托投影 / Use Mercator projection
ggplot() +
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group)) +
  coord_map("mercator")
```

### 3. 添加图例和注释 / Add Legends and Annotations

```r
ggplot() +
  geom_polygon(data = map_data, aes(x = long, y = lat, group = group, fill = value)) +
  scale_fill_gradient(name = "人口密度\nPopulation Density") +
  labs(caption = "数据来源: 示例数据\nData Source: Sample Data")
```

## 常见问题 / FAQ

**Q: 如何安装R？ / How to install R?**

A: 访问 https://www.r-project.org/ 下载并安装适合您操作系统的版本。
Visit https://www.r-project.org/ to download and install the version for your operating system.

**Q: 脚本运行出错怎么办？ / What if the script shows errors?**

A: 确保已安装所有必需的包。如果仍有问题，检查R版本是否满足要求。
Make sure all required packages are installed. If problems persist, check if your R version meets the requirements.

**Q: 如何绘制其他国家的地图？ / How to draw maps of other countries?**

A: 使用`map_data("world", region = "国家名")`来获取特定国家的地图数据。
Use `map_data("world", region = "CountryName")` to get map data for a specific country.

## 参考资源 / References

- [ggplot2 官方文档 / ggplot2 Official Documentation](https://ggplot2.tidyverse.org/)
- [maps 包文档 / maps Package Documentation](https://cran.r-project.org/web/packages/maps/)
- [R Graphics Cookbook](https://r-graphics.org/)

## 许可证 / License

本项目采用MIT许可证 / This project is licensed under the MIT License.

## 贡献 / Contributing

欢迎提交问题和拉取请求！/ Issues and pull requests are welcome!
