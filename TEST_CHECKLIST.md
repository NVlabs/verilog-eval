# VerilogEval Ollama Testing - 测试验证清单

在正式开始大规模测试前，请按照此清单进行验证。

## ✅ 安装验证

- [ ] Python 3.8+ 已安装
- [ ] Ollama 已安装并运行 (`ollama serve`)
- [ ] iverilog v12 已安装
- [ ] Python依赖已安装 (`pip install -r requirements.txt`)

验证命令：
```bash
python check_prerequisites.py
```

---

## ✅ 模型准备

- [ ] 至少拉取一个测试模型
- [ ] 模型可以成功生成代码

验证命令：
```bash
python check_models.py
```

推荐首次测试的模型（从小到大）：
1. `llama3.2:3b` - 2.0 GB（最小，最快）
2. `mistral:7b` - 4.4 GB（平衡）
3. `qwen3:8b` - 5.2 GB（性能好）

---

## ✅ 快速功能测试

### 测试1: 单个问题生成（最快）

```bash
python run_verilog_eval.py --model mistral:7b --limit 1
```

**预期结果**：
- 在 `results/mistral_7b_0shot_temp0.0/Prob001_zero/` 下生成所有文件
- 包括：`.sv`, `_raw_response.txt`, `_extracted_code.txt`, 日志文件

**验证**：
```bash
ls -la results/mistral_7b_0shot_temp0.0/Prob001_zero/
cat results/mistral_7b_0shot_temp0.0/Prob001_zero/Prob001_zero_sample01_raw_response.txt
```

---

### 测试2: 前10个问题（快速验证）

```bash
python run_verilog_eval.py --model mistral:7b --limit 10
```

**预期时间**：1-3分钟

**预期结果**：
- 10个问题目录
- `summary.txt`, `summary.csv`, `results.json`

**验证**：
```bash
cat results/mistral_7b_0shot_temp0.0/summary.txt
```

---

### 测试3: 断点恢复测试

```bash
# 运行前5个问题
python run_verilog_eval.py --model mistral:7b --limit 5

# 继续运行到10个问题
python run_verilog_eval.py --model mistral:7b --limit 10 --resume
```

**预期结果**：
- 只生成新的5个问题
- 跳过已完成的前5个

---

## ✅ 输出验证

验证每个问题的输出文件是否完整：

```bash
PROB_DIR="results/mistral_7b_0shot_temp0.0/Prob001_zero"

# 应该存在的文件
ls -1 $PROB_DIR/ | grep -E "sample01"
```

**必须包含**：
- [x] `*_sample01.sv` - 完整Verilog代码
- [x] `*_sample01_raw_response.txt` - 原始响应
- [x] `*_sample01_extracted_code.txt` - 提取代码
- [x] `*_sample01-sv-generate.log` - 生成日志
- [x] `*_sample01-sv-iv-test.log` - 测试日志

验证内容：
```bash
# 查看原始响应（应该是模型的完整输出）
cat $PROB_DIR/Prob001_zero_sample01_raw_response.txt

# 查看生成日志（应该包含prompt和参数）
cat $PROB_DIR/Prob001_zero_sample01-sv-generate.log | grep -A5 "Generation Parameters"

# 查看测试日志（应该包含编译和测试结果）
cat $PROB_DIR/Prob001_zero_sample01-sv-iv-test.log
```

---

## ✅ 错误处理测试

测试当模型生成失败时，脚本是否正确处理：

```bash
# 使用一个不存在的模型（应该失败但不崩溃）
python run_verilog_eval.py --model nonexistent:model --limit 1 2>&1 | grep -i error
```

**预期结果**：
- 显示错误信息
- 但不会崩溃
- 生成日志文件记录错误

---

## ✅ 完整测试（可选）

如果快速测试都通过，可以运行完整测试：

### 单个模型完整测试

```bash
python run_verilog_eval.py --model mistral:7b
```

**预期时间**：5-10分钟（156个问题）

---

### 批量测试（多个模型）

```bash
python run_all_models.py --limit 10
```

**预期结果**：
- 每个模型的独立结果目录
- `results/all_models_comparison.txt`
- `results/all_models_comparison.csv`

---

## ✅ 结果分析

### 查看单个模型结果

```bash
# 文本报告
cat results/mistral_7b_0shot_temp0.0/summary.txt

# CSV报告
cat results/mistral_7b_0shot_temp0.0/summary.csv

# JSON详细数据
python -m json.tool results/mistral_7b_0shot_temp0.0/results.json | head -50
```

### 查看对比报告

```bash
cat results/all_models_comparison.txt
```

---

## ✅ 清理测试数据

测试完成后，如果需要清理：

```bash
# 删除特定模型的结果
rm -rf results/mistral_7b_0shot_temp0.0/

# 删除所有结果
rm -rf results/

# 删除模型检查结果
rm -f model_check_results.json
```

---

## 🎯 测试通过标准

如果以下项目都通过，说明系统已准备好进行大规模测试：

- ✅ `check_prerequisites.py` 所有检查通过
- ✅ `check_models.py` 至少一个模型可用
- ✅ 单个问题测试成功生成所有输出文件
- ✅ 10个问题测试完成且有正确的统计
- ✅ 断点恢复功能正常
- ✅ 输出文件完整且格式正确
- ✅ 原始响应被完整保留
- ✅ 错误情况下不会崩溃

---

## 📞 遇到问题？

如果任何测试失败：

1. 查看错误信息
2. 检查 `check_prerequisites.py` 输出
3. 确认Ollama服务正在运行
4. 查看生成的日志文件（`*-sv-generate.log`）
5. 参考 `README_TESTING.md` 的故障排除章节

---

## 🚀 准备就绪！

如果所有测试都通过，您可以：

1. 运行完整的单模型测试
2. 运行所有模型的批量测试
3. 开始分析结果

祝测试顺利！🎉
