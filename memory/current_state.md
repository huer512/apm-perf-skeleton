# 当前状态

> 新会话进场先读本文件恢复上下文;每次会话收尾时更新本文件。
> 调度以「工作流状态机」四字段为准(见 AGENTS.md);下方叙述为补充。

## 工作流状态机
- phase: intake
- active_exp: none
- last_diag_exp: none
- queue: []

## 当前阶段
问题理解
<!-- 叙述性补充;取值参考:问题理解 / baseline 建立 / 瓶颈定位 / 优化验证 / 合并验证 / 最终整理 -->

## 当前最佳实验
无

## 当前关注假设
- 无

## 当前主要风险
- 无

## 最近完成
- 仓库骨架初始化

## 下一步动作
- 从任务描述填写 `problem/intake.md`,再分发四文件
- 填写 `memory/global_context.md`
- 完成 baseline 后进入 `diagnose`
