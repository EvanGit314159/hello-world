# R语言地图绘制示例 / R Map Visualization Examples
# 
# 这个脚本展示了如何使用R语言绘制各种类型的地图
# This script demonstrates how to create various types of maps using R
#
# 需要的包 / Required packages:
# - ggplot2: 用于创建图形 / For creating graphics
# - maps: 提供地图数据 / Provides map data
# - mapdata: 额外的地图数据 / Additional map data
#
# 安装包 / Install packages (if needed):
# install.packages(c("ggplot2", "maps", "mapdata"))

# 加载必要的包 / Load required packages
library(ggplot2)
library(maps)

# ============================================================================
# 示例 1: 绘制世界地图 / Example 1: World Map
# ============================================================================

cat("示例 1: 绘制世界地图\n")
cat("Example 1: Drawing World Map\n\n")

# 获取世界地图数据 / Get world map data
world_map <- map_data("world")

# 创建世界地图 / Create world map
world_plot <- ggplot() +
  geom_polygon(data = world_map, 
               aes(x = long, y = lat, group = group),
               fill = "lightblue", 
               color = "white") +
  coord_fixed(1.3) +
  theme_minimal() +
  labs(title = "世界地图 / World Map",
       x = "经度 / Longitude",
       y = "纬度 / Latitude")

# 保存地图 / Save map
ggsave("world_map.png", world_plot, width = 10, height = 6, dpi = 300)
cat("世界地图已保存为 world_map.png\n")
cat("World map saved as world_map.png\n\n")

# ============================================================================
# 示例 2: 绘制美国地图 / Example 2: USA Map
# ============================================================================

cat("示例 2: 绘制美国地图\n")
cat("Example 2: Drawing USA Map\n\n")

# 获取美国各州地图数据 / Get USA states map data
usa_map <- map_data("state")

# 创建美国地图 / Create USA map
usa_plot <- ggplot() +
  geom_polygon(data = usa_map,
               aes(x = long, y = lat, group = group),
               fill = "lightgreen",
               color = "darkgreen") +
  coord_fixed(1.3) +
  theme_minimal() +
  labs(title = "美国地图 / USA Map",
       x = "经度 / Longitude",
       y = "纬度 / Latitude")

# 保存地图 / Save map
ggsave("usa_map.png", usa_plot, width = 10, height = 6, dpi = 300)
cat("美国地图已保存为 usa_map.png\n")
cat("USA map saved as usa_map.png\n\n")

# ============================================================================
# 示例 3: 绘制中国地图（使用世界地图数据过滤）
# Example 3: China Map (using filtered world map data)
# ============================================================================

cat("示例 3: 绘制中国地图\n")
cat("Example 3: Drawing China Map\n\n")

# 从世界地图数据中提取中国 / Extract China from world map data
china_map <- map_data("world", region = "China")

# 创建中国地图 / Create China map
china_plot <- ggplot() +
  geom_polygon(data = china_map,
               aes(x = long, y = lat, group = group),
               fill = "coral",
               color = "darkred") +
  coord_fixed(1.3) +
  theme_minimal() +
  labs(title = "中国地图 / China Map",
       x = "经度 / Longitude",
       y = "纬度 / Latitude")

# 保存地图 / Save map
ggsave("china_map.png", china_plot, width = 10, height = 6, dpi = 300)
cat("中国地图已保存为 china_map.png\n")
cat("China map saved as china_map.png\n\n")

# ============================================================================
# 示例 4: 高级地图 - 使用颜色渐变显示数据
# Example 4: Advanced Map - Using color gradients to show data
# ============================================================================

cat("示例 4: 高级地图 - 带数据可视化\n")
cat("Example 4: Advanced Map - With Data Visualization\n\n")

# 创建模拟数据 / Create sample data
set.seed(123)
map_with_data <- world_map
countries <- unique(world_map$region)
country_data <- data.frame(
  region = countries,
  value = runif(length(countries), 0, 100)
)

# 合并地图数据和数值数据 / Merge map data with values
map_with_data <- merge(world_map, country_data, by = "region", all.x = TRUE)

# 创建带数据的地图 / Create map with data
advanced_plot <- ggplot() +
  geom_polygon(data = map_with_data,
               aes(x = long, y = lat, group = group, fill = value),
               color = "white", size = 0.1) +
  scale_fill_gradient(low = "yellow", high = "red", na.value = "grey90",
                      name = "数值 / Value") +
  coord_fixed(1.3) +
  theme_minimal() +
  labs(title = "世界地图 - 数据可视化 / World Map - Data Visualization",
       x = "经度 / Longitude",
       y = "纬度 / Latitude")

# 保存地图 / Save map
ggsave("advanced_map.png", advanced_plot, width = 12, height = 7, dpi = 300)
cat("高级地图已保存为 advanced_map.png\n")
cat("Advanced map saved as advanced_map.png\n\n")

# ============================================================================
# 使用基础R绘图系统 / Using base R plotting system
# ============================================================================

cat("示例 5: 使用基础R绘图系统\n")
cat("Example 5: Using Base R Plotting System\n\n")

# 保存基础R地图 / Save base R map
png("base_r_map.png", width = 800, height = 600)
map("world", 
    col = "lightblue", 
    fill = TRUE, 
    bg = "white",
    mar = c(0, 0, 2, 0))
title(main = "世界地图 (基础R) / World Map (Base R)")
dev.off()
cat("基础R地图已保存为 base_r_map.png\n")
cat("Base R map saved as base_r_map.png\n\n")

# ============================================================================
# 完成 / Complete
# ============================================================================

cat("========================================\n")
cat("所有地图已成功创建！\n")
cat("All maps created successfully!\n")
cat("========================================\n")
cat("生成的文件 / Generated files:\n")
cat("  1. world_map.png - 世界地图 / World Map\n")
cat("  2. usa_map.png - 美国地图 / USA Map\n")
cat("  3. china_map.png - 中国地图 / China Map\n")
cat("  4. advanced_map.png - 高级数据可视化地图 / Advanced Data Visualization Map\n")
cat("  5. base_r_map.png - 基础R系统地图 / Base R System Map\n")
cat("========================================\n")
