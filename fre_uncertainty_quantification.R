# =============================================================================
# MODIS火点数据FRE不确定性量化 - R实现
# Fire Radiative Energy (FRE) Uncertainty Quantification for MODIS Fire Data
# =============================================================================

# 加载必要的包
if (!require("MASS")) install.packages("MASS")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")

library(MASS)
library(ggplot2)
library(dplyr)

# 设置随机种子以确保结果可重复
set.seed(123)

# =============================================================================
# 1. 参数设置
# =============================================================================

# 蒙特卡洛模拟次数
n_simulations <- 10000

# MODIS测量误差：变异系数15%
cv_modis <- 0.15

# =============================================================================
# 2. 生成或加载校正模型参数
# =============================================================================

# 假设已经通过 log(FRP_VIIRS) = beta * log(FRP_MODIS) 得到了校正系数
# 这里使用示例值，实际应用中需要用真实的回归结果替换

# 校正系数beta及其标准误差（从线性回归中获得）
beta_estimate <- 0.95  # 校正系数估计值
beta_se <- 0.05        # beta的标准误差

# =============================================================================
# 3. 焚烧时长-FRP线性回归模型参数
# =============================================================================

# 线性模型：duration = alpha + beta_duration * FRP + error
# 从回归模型中获得的参数
alpha_estimate <- 2.5      # 截距
beta_duration_estimate <- 0.3  # 斜率
alpha_se <- 0.5            # 截距标准误差
beta_duration_se <- 0.05   # 斜率标准误差
cor_alpha_beta <- -0.3     # 参数之间的相关系数

# 构建协方差矩阵
cov_alpha <- alpha_se^2
cov_beta_duration <- beta_duration_se^2
cov_alpha_beta <- cor_alpha_beta * alpha_se * beta_duration_se

covariance_matrix <- matrix(c(cov_alpha, cov_alpha_beta,
                              cov_alpha_beta, cov_beta_duration), 
                            nrow = 2)

# =============================================================================
# 4. 积分函数分布参数
# =============================================================================

# 正态分布参数（焚烧时长 <= 4小时）
# 参数存在不确定性，这里假设通过bootstrap或其他方法得到了参数分布
normal_mu_mean <- 1.0
normal_mu_sd <- 0.1
normal_sigma_mean <- 0.3
normal_sigma_sd <- 0.05

# Weibull分布参数（焚烧时长 > 4小时）
# shape参数k和scale参数lambda
weibull_shape_mean <- 2.0
weibull_shape_sd <- 0.2
weibull_scale_mean <- 3.0
weibull_scale_sd <- 0.3

# =============================================================================
# 5. 定义积分函数
# =============================================================================

# 时间展开函数：正态分布
integrate_normal <- function(max_frp, duration, mu, sigma) {
  # 归一化正态分布积分到1，然后乘以持续时间和最大FRP
  # 简化计算：FRE = max_frp * duration * 积分因子
  # 对于正态分布，积分因子近似为1（假设3sigma覆盖整个燃烧期）
  integration_factor <- 1.0  # 可以根据实际情况调整
  fre <- max_frp * duration * integration_factor
  return(fre)
}

# 时间展开函数：Weibull分布
integrate_weibull <- function(max_frp, duration, shape, scale) {
  # Weibull分布的期望值用于积分
  # E[X] = scale * gamma(1 + 1/shape)
  # FRE = max_frp * duration * 积分因子
  integration_factor <- scale * gamma(1 + 1/shape) / duration
  fre <- max_frp * duration * integration_factor
  return(fre)
}

# =============================================================================
# 6. 蒙特卡洛模拟主函数
# =============================================================================

monte_carlo_fre_uncertainty <- function(frp_modis_observed, n_sim = n_simulations) {
  
  # 存储每次模拟的FRE结果
  fre_results <- numeric(n_sim)
  
  # 存储中间结果用于敏感性分析
  beta_samples <- numeric(n_sim)
  duration_samples <- numeric(n_sim)
  
  for (i in 1:n_sim) {
    
    # 步骤1：MODIS测量误差抽样
    # 使用对数正态分布确保FRP为正值
    frp_error <- rnorm(1, mean = 0, sd = cv_modis)
    frp_modis_actual <- frp_modis_observed * (1 + frp_error)
    frp_modis_actual <- max(frp_modis_actual, 0.01)  # 确保为正
    
    # 步骤2：VIIRS-MODIS校正系数抽样
    beta_sample <- rnorm(1, mean = beta_estimate, sd = beta_se)
    beta_samples[i] <- beta_sample
    
    # 应用校正公式
    log_frp_viirs <- beta_sample * log(frp_modis_actual)
    frp_corrected <- exp(log_frp_viirs)
    
    # 步骤3：焚烧时长-FRP回归参数抽样（考虑参数相关性）
    regression_params <- mvrnorm(1, 
                                 mu = c(alpha_estimate, beta_duration_estimate),
                                 Sigma = covariance_matrix)
    alpha_sample <- regression_params[1]
    beta_duration_sample <- regression_params[2]
    
    # 计算焚烧时长（加入残差不确定性）
    duration_residual <- rnorm(1, mean = 0, sd = 0.5)  # 残差标准差
    duration <- alpha_sample + beta_duration_sample * frp_corrected + duration_residual
    duration <- max(duration, 0.1)  # 确保为正且合理
    duration_samples[i] <- duration
    
    # 步骤4：根据焚烧时长选择积分函数和抽样分布参数
    if (duration <= 4) {
      # 使用正态分布
      mu_sample <- rnorm(1, mean = normal_mu_mean, sd = normal_mu_sd)
      sigma_sample <- abs(rnorm(1, mean = normal_sigma_mean, sd = normal_sigma_sd))
      
      fre <- integrate_normal(frp_corrected, duration, mu_sample, sigma_sample)
      
    } else {
      # 使用Weibull分布
      shape_sample <- abs(rnorm(1, mean = weibull_shape_mean, sd = weibull_shape_sd))
      scale_sample <- abs(rnorm(1, mean = weibull_scale_mean, sd = weibull_scale_sd))
      
      fre <- integrate_weibull(frp_corrected, duration, shape_sample, scale_sample)
    }
    
    fre_results[i] <- fre
  }
  
  # 返回结果
  return(list(
    fre = fre_results,
    beta = beta_samples,
    duration = duration_samples
  ))
}

# =============================================================================
# 7. 运行模拟
# =============================================================================

# 示例：假设观测到的MODIS FRP值为100 MW
frp_modis_observed <- 100

cat("开始蒙特卡洛模拟...\n")
cat(sprintf("模拟次数: %d\n", n_simulations))
cat(sprintf("观测FRP: %.2f MW\n\n", frp_modis_observed))

# 执行模拟
simulation_results <- monte_carlo_fre_uncertainty(frp_modis_observed, n_simulations)

# =============================================================================
# 8. 结果统计分析
# =============================================================================

fre_values <- simulation_results$fre

# 基本统计量
fre_mean <- mean(fre_values)
fre_median <- median(fre_values)
fre_sd <- sd(fre_values)
fre_cv <- fre_sd / fre_mean

# 置信区间
ci_95 <- quantile(fre_values, probs = c(0.025, 0.975))
ci_90 <- quantile(fre_values, probs = c(0.05, 0.95))

# 打印结果
cat("=============================================================================\n")
cat("FRE不确定性量化结果\n")
cat("=============================================================================\n\n")

cat("统计摘要:\n")
cat(sprintf("  均值:         %.2f MJ\n", fre_mean))
cat(sprintf("  中位数:       %.2f MJ\n", fre_median))
cat(sprintf("  标准差:       %.2f MJ\n", fre_sd))
cat(sprintf("  变异系数:     %.2f%%\n", fre_cv * 100))
cat("\n")

cat("置信区间:\n")
cat(sprintf("  90%% CI:      [%.2f, %.2f] MJ\n", ci_90[1], ci_90[2]))
cat(sprintf("  95%% CI:      [%.2f, %.2f] MJ\n", ci_95[1], ci_95[2]))
cat("\n")

cat("分位数:\n")
quantiles <- quantile(fre_values, probs = c(0.05, 0.25, 0.50, 0.75, 0.95))
for (i in 1:length(quantiles)) {
  cat(sprintf("  %d%%:          %.2f MJ\n", 
              as.numeric(names(quantiles)[i]) * 100, 
              quantiles[i]))
}
cat("\n")

# =============================================================================
# 9. 可视化结果
# =============================================================================

# 创建数据框用于绘图
plot_data <- data.frame(FRE = fre_values)

# 图1：FRE分布直方图及密度曲线
p1 <- ggplot(plot_data, aes(x = FRE)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50, 
                 fill = "skyblue", color = "black", alpha = 0.7) +
  geom_density(color = "red", linewidth = 1) +
  geom_vline(xintercept = fre_mean, color = "blue", 
             linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = ci_95[1], color = "green", 
             linetype = "dotted", linewidth = 1) +
  geom_vline(xintercept = ci_95[2], color = "green", 
             linetype = "dotted", linewidth = 1) +
  labs(title = "FRE不确定性分布",
       subtitle = sprintf("均值 = %.2f MJ, 95%% CI = [%.2f, %.2f] MJ", 
                         fre_mean, ci_95[1], ci_95[2]),
       x = "FRE (MJ)",
       y = "密度") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

print(p1)

# 保存图形
ggsave("fre_uncertainty_distribution.png", p1, width = 10, height = 6, dpi = 300)

# 图2：累积分布函数
plot_data_sorted <- plot_data %>% 
  arrange(FRE) %>%
  mutate(cumulative = row_number() / n())

p2 <- ggplot(plot_data_sorted, aes(x = FRE, y = cumulative)) +
  geom_line(color = "blue", linewidth = 1) +
  geom_hline(yintercept = c(0.025, 0.5, 0.975), 
             linetype = "dashed", color = "red", alpha = 0.5) +
  labs(title = "FRE累积分布函数",
       x = "FRE (MJ)",
       y = "累积概率") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p2)
ggsave("fre_cumulative_distribution.png", p2, width = 10, height = 6, dpi = 300)

# =============================================================================
# 10. 敏感性分析（方差分解）
# =============================================================================

cat("=============================================================================\n")
cat("敏感性分析\n")
cat("=============================================================================\n\n")

# 简化的敏感性分析：单独改变每个不确定性来源

# 10.1 仅MODIS测量误差的影响
fre_modis_only <- numeric(n_simulations)
for (i in 1:n_simulations) {
  frp_error <- rnorm(1, mean = 0, sd = cv_modis)
  frp_modis_actual <- frp_modis_observed * (1 + frp_error)
  frp_modis_actual <- max(frp_modis_actual, 0.01)
  
  # 使用固定的其他参数
  log_frp_viirs <- beta_estimate * log(frp_modis_actual)
  frp_corrected <- exp(log_frp_viirs)
  duration <- alpha_estimate + beta_duration_estimate * frp_corrected
  duration <- max(duration, 0.1)
  
  if (duration <= 4) {
    fre_modis_only[i] <- integrate_normal(frp_corrected, duration, 
                                          normal_mu_mean, normal_sigma_mean)
  } else {
    fre_modis_only[i] <- integrate_weibull(frp_corrected, duration, 
                                           weibull_shape_mean, weibull_scale_mean)
  }
}

# 10.2 仅校正系数beta的影响
fre_beta_only <- numeric(n_simulations)
for (i in 1:n_simulations) {
  beta_sample <- rnorm(1, mean = beta_estimate, sd = beta_se)
  
  log_frp_viirs <- beta_sample * log(frp_modis_observed)
  frp_corrected <- exp(log_frp_viirs)
  duration <- alpha_estimate + beta_duration_estimate * frp_corrected
  duration <- max(duration, 0.1)
  
  if (duration <= 4) {
    fre_beta_only[i] <- integrate_normal(frp_corrected, duration, 
                                         normal_mu_mean, normal_sigma_mean)
  } else {
    fre_beta_only[i] <- integrate_weibull(frp_corrected, duration, 
                                          weibull_shape_mean, weibull_scale_mean)
  }
}

# 计算各来源的方差贡献
var_total <- var(fre_values)
var_modis <- var(fre_modis_only)
var_beta <- var(fre_beta_only)

cat("方差分解:\n")
cat(sprintf("  总方差:                 %.2f\n", var_total))
cat(sprintf("  MODIS测量误差贡献:      %.2f (%.1f%%)\n", 
            var_modis, var_modis/var_total*100))
cat(sprintf("  校正系数beta贡献:       %.2f (%.1f%%)\n", 
            var_beta, var_beta/var_total*100))
cat(sprintf("  其他来源（交互+残差）:  %.2f (%.1f%%)\n", 
            var_total - var_modis - var_beta,
            (var_total - var_modis - var_beta)/var_total*100))
cat("\n")

# =============================================================================
# 11. 导出结果
# =============================================================================

# 创建结果汇总数据框
results_summary <- data.frame(
  Metric = c("Mean", "Median", "SD", "CV", "CI_95_Lower", "CI_95_Upper"),
  Value = c(fre_mean, fre_median, fre_sd, fre_cv, ci_95[1], ci_95[2])
)

# 保存到CSV文件
write.csv(results_summary, "fre_uncertainty_summary.csv", row.names = FALSE)
write.csv(plot_data, "fre_simulation_results.csv", row.names = FALSE)

cat("结果已保存到:\n")
cat("  - fre_uncertainty_summary.csv (统计摘要)\n")
cat("  - fre_simulation_results.csv (完整模拟结果)\n")
cat("  - fre_uncertainty_distribution.png (分布图)\n")
cat("  - fre_cumulative_distribution.png (累积分布图)\n")
cat("\n")

# =============================================================================
# 12. 批量处理多个火点的函数
# =============================================================================

# 为实际应用创建批量处理函数
process_multiple_fires <- function(frp_observations, n_sim = 1000) {
  
  n_fires <- length(frp_observations)
  results <- data.frame(
    fire_id = 1:n_fires,
    frp_observed = frp_observations,
    fre_mean = numeric(n_fires),
    fre_sd = numeric(n_fires),
    fre_ci_lower = numeric(n_fires),
    fre_ci_upper = numeric(n_fires)
  )
  
  cat(sprintf("处理%d个火点...\n", n_fires))
  
  for (i in 1:n_fires) {
    if (i %% 10 == 0) {
      cat(sprintf("  进度: %d/%d\n", i, n_fires))
    }
    
    sim <- monte_carlo_fre_uncertainty(frp_observations[i], n_sim)
    results$fre_mean[i] <- mean(sim$fre)
    results$fre_sd[i] <- sd(sim$fre)
    ci <- quantile(sim$fre, probs = c(0.025, 0.975))
    results$fre_ci_lower[i] <- ci[1]
    results$fre_ci_upper[i] <- ci[2]
  }
  
  return(results)
}

# 示例：批量处理
cat("=============================================================================\n")
cat("批量处理示例\n")
cat("=============================================================================\n\n")

# 生成示例数据：10个火点
example_frp_data <- c(50, 75, 100, 120, 150, 80, 95, 110, 130, 160)

# 批量处理（使用较少的模拟次数以加快演示）
batch_results <- process_multiple_fires(example_frp_data, n_sim = 1000)

print(batch_results)

# 保存批量结果
write.csv(batch_results, "batch_fre_results.csv", row.names = FALSE)

cat("\n批量处理结果已保存到: batch_fre_results.csv\n")

# =============================================================================
# 完成
# =============================================================================

cat("\n")
cat("=============================================================================\n")
cat("不确定性量化分析完成！\n")
cat("=============================================================================\n")
