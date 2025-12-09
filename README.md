# hello-world
This is a store for practice in quickstart guide
This is my first time to visit Github, because I want to learn something about programming and newly developed statistical methods from Github. So let's start it!

---

## 🔥 MODIS火点数据FRE不确定性量化

本仓库现包含完整的MODIS火点数据火辐射能量(FRE)不确定性量化解决方案。

### 📚 快速导航

1. **开始使用**: 查看 [`FRE_UNCERTAINTY_README.md`](FRE_UNCERTAINTY_README.md) 了解完整的使用说明
2. **方法论**: 阅读 [`uncertainty_quantification_explanation.md`](uncertainty_quantification_explanation.md) 了解理论基础
3. **运行代码**: 直接运行 [`fre_uncertainty_quantification.R`](fre_uncertainty_quantification.R) 进行分析

### ✨ 主要特性

- ✅ 蒙特卡洛不确定性传播（10,000次模拟）
- ✅ 考虑MODIS测量误差（15%变异系数）
- ✅ VIIRS-MODIS校正模型不确定性
- ✅ 焚烧时长回归参数不确定性
- ✅ 条件积分（正态/Weibull分布）
- ✅ 敏感性分析和方差分解
- ✅ 完整的统计分析和可视化
- ✅ 批量处理支持

### 🚀 快速开始

```r
# 安装依赖包
install.packages(c("MASS", "ggplot2", "dplyr"))

# 运行完整分析
Rscript fre_uncertainty_quantification.R
```

详细说明请参考 [`FRE_UNCERTAINTY_README.md`](FRE_UNCERTAINTY_README.md)
