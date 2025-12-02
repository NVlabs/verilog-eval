# VerilogEval Ollama Testing - Deliverables

## 📦 交付物清单

本项目包含以下文件和脚本，用于在本地Ollama模型上运行VerilogEval benchmark测试。

---

## ✅ 核心脚本

### 1. `check_prerequisites.py`
**前置依赖检查脚本**

- **功能**：检查所有必需的依赖项
- **检查项**：
  - Python版本（3.8+）
  - Ollama服务可用性
  - Python包（ollama, tqdm, requests）
  - iverilog安装和版本（v12）
  - 数据集目录
  - 磁盘空间
- **使用**：`python check_prerequisites.py`
- **输出**：彩色终端报告，显示所有检查结果

---

### 2. `check_models.py`
**模型可用性检查脚本**

- **功能**：测试每个Ollama模型的可用性和基本性能
- **测试项**：
  - 模型是否已拉取
  - 基本Verilog代码生成能力
  - 响应时间测量
  - 内存占用估算
- **测试模型**：
  - llama3.2:3b (2.0 GB)
  - mistral:7b (4.4 GB)
  - qwen3:8b (5.2 GB)
  - gemma3:12b (8.1 GB)
  - deepseek-r1:14b (9.0 GB)
  - phi4:14b (9.1 GB)
  - gpt-oss:20b (13 GB)
- **使用**：`python check_models.py`
- **输出**：
  - 终端彩色报告
  - `model_check_results.json` - JSON格式详细结果

---

### 3. `run_verilog_eval.py`
**VerilogEval测试主脚本**

- **功能**：对单个Ollama模型运行完整的VerilogEval测试
- **特性**：
  - Zero-shot测试（无上下文学习）
  - 低温度设置（temp=0.0, top_p=0.01）
  - 保存所有输出（原始响应、提取代码、日志）
  - 集成iverilog编译和测试
  - 进度跟踪和断点恢复
  - 生成评估报告
- **测试参数**：
  - 任务：code-complete-iccad2023
  - 温度：0.0
  - Top-p：0.01
  - 样本数：1
  - 最大令牌：1024
- **使用示例**：
  ```bash
  # 完整测试（156个问题）
  python run_verilog_eval.py --model gemma3:12b

  # 快速验证（前10个问题）
  python run_verilog_eval.py --model mistral:7b --limit 10

  # 断点恢复
  python run_verilog_eval.py --model qwen3:8b --resume

  # 自定义输出目录
  python run_verilog_eval.py --model phi4:14b --output-dir my_results/phi4
  ```
- **输出结构**：
  ```
  results/<model>_0shot_temp0.0/
  ├── Prob001_zero/
  │   ├── *_sample01.sv                 # 完整Verilog代码
  │   ├── *_raw_response.txt            # 模型原始输出
  │   ├── *_extracted_code.txt          # 提取的代码片段
  │   ├── *-sv-generate.log             # 生成日志（含prompt）
  │   └── *-sv-iv-test.log              # iverilog测试日志
  ├── summary.txt                        # 文本格式总结
  ├── summary.csv                        # CSV格式总结
  ├── results.json                       # 详细JSON结果
  └── progress.json                      # 进度跟踪
  ```

---

### 4. `run_all_models.py`
**批量测试脚本**

- **功能**：依次测试所有指定的Ollama模型
- **特性**：
  - 自动按顺序测试多个模型
  - 模型间内存清理
  - 运行时间跟踪
  - 生成对比报告
- **使用示例**：
  ```bash
  # 测试所有模型
  python run_all_models.py

  # 快速验证（每个模型10个问题）
  python run_all_models.py --limit 10

  # 测试特定模型
  python run_all_models.py --models mistral:7b qwen3:8b gemma3:12b

  # 跳过内存清理
  python run_all_models.py --skip-cleanup
  ```
- **输出**：
  - 每个模型的独立结果目录
  - `results/all_models_comparison.txt` - 对比文本报告
  - `results/all_models_comparison.csv` - 对比CSV报告

---

## 📄 文档

### 5. `requirements.txt`
**Python依赖文件**

- **内容**：
  - `ollama>=0.1.0` - Ollama Python SDK
  - `tqdm>=4.65.0` - 进度条
  - `requests>=2.28.0` - HTTP请求
- **使用**：`pip install -r requirements.txt`

---

### 6. `README_TESTING.md`
**完整使用说明文档**

- **内容**：
  - 系统要求
  - 详细安装步骤
  - 使用说明和命令示例
  - 输出结构说明
  - 结果分析方法
  - 故障排除指南
  - 最佳实践建议
- **长度**：约11KB，包含完整的使用指南

---

### 7. `QUICKSTART.md`
**快速入门指南**

- **内容**：
  - 5分钟快速设置流程
  - 常见问题快速解答
  - 预期测试时间
  - 输出文件说明
- **目标**：帮助用户快速上手

---

### 8. `example_workflow.sh`
**示例工作流脚本**

- **功能**：演示完整的测试工作流程
- **步骤**：
  1. 检查前置依赖
  2. 检查模型可用性
  3. 运行快速测试（10个问题）
  4. 提示下一步操作
- **使用**：`bash example_workflow.sh`

---

## 📊 输出说明

### 每个问题生成的文件

对于每个测试问题，脚本会生成以下文件：

1. **`*_sample01.sv`** - 完整的Verilog代码
   - 包含模块接口定义
   - 可以直接用iverilog编译

2. **`*_raw_response.txt`** - 模型的原始完整输出
   - **完全保留**模型生成的所有内容
   - 包括解释、markdown格式等
   - 用于后续分析模型行为

3. **`*_extracted_code.txt`** - 提取的代码片段
   - 去除markdown格式后的纯代码
   - 不含模块接口

4. **`*-sv-generate.log`** - 生成过程日志
   - 生成参数（模型、温度、top_p）
   - 完整的prompt
   - 系统消息
   - 模型响应
   - 任何提取错误

5. **`*-sv-iv-test.log`** - iverilog测试日志
   - 编译命令和输出
   - 测试执行结果
   - 错误信息（如果有）

### 总结报告

1. **`summary.txt`** - 人类可读的文本报告
   - 总体通过率
   - 编译成功率
   - 每个问题的详细状态
   - 时间统计

2. **`summary.csv`** - CSV格式报告
   - 与VerilogEval原有工具兼容
   - 可以用count_failures.py分析

3. **`results.json`** - 详细JSON结果
   - 完整的测试数据
   - 可编程访问
   - 用于自动化分析

---

## 🎯 关键特性

### 1. 完整输出保留
- ✅ 保存模型原始响应（`*_raw_response.txt`）
- ✅ 保存提取的代码（`*_extracted_code.txt`）
- ✅ 保存完整日志（生成+测试）
- ✅ **成功和失败的输出都会保留**
- ✅ 方便后续分析模型行为

### 2. 零温度测试
- ✅ Temperature = 0.0
- ✅ Top-p = 0.01
- ✅ 确保可重复性
- ✅ 评估模型的确定性表现

### 3. 错误处理
- ✅ 失败直接继续，不重试
- ✅ 保留所有错误信息
- ✅ 生成详细错误日志
- ✅ 不中断整个测试流程

### 4. 进度管理
- ✅ 实时进度条（tqdm）
- ✅ 断点恢复支持
- ✅ 进度跟踪（`progress.json`）
- ✅ 可随时中断和恢复

---

## 🚀 使用流程

### 基本流程

```bash
# 1. 检查依赖
python check_prerequisites.py

# 2. 检查模型
python check_models.py

# 3. 测试单个模型
python run_verilog_eval.py --model mistral:7b

# 4. 查看结果
cat results/mistral_7b_0shot_temp0.0/summary.txt
```

### 批量测试流程

```bash
# 1. 确保所有模型已拉取
ollama pull llama3.2:3b
ollama pull mistral:7b
ollama pull qwen3:8b
ollama pull gemma3:12b
ollama pull deepseek-r1:14b
ollama pull phi4:14b
ollama pull gpt-oss:20b

# 2. 运行批量测试
python run_all_models.py

# 3. 查看对比结果
cat results/all_models_comparison.txt
```

---

## 📈 预期性能

### 测试时间估算

| 模型大小 | 单个问题 | 全部156问题 |
|---------|---------|------------|
| 3B-7B   | 1-3秒   | 5-10分钟   |
| 8B-14B  | 2-5秒   | 10-20分钟  |
| 20B+    | 5-10秒  | 20-30分钟  |

### 硬件要求

- **显卡显存**：16GB（可运行≤13GB的模型）
- **系统内存**：16GB+
- **磁盘空间**：5GB+（存储结果）
- **限制**：同时只能运行一个模型

---

## 🔧 故障排除

### Ollama未运行
```bash
# 启动Ollama服务
ollama serve
```

### 模型未找到
```bash
# 拉取模型
ollama pull <model_name>
```

### 内存不足
- 测试小模型（3B-7B参数）
- 关闭其他GPU应用
- 使用量化版本

### 测试中断
```bash
# 使用--resume恢复
python run_verilog_eval.py --model <model> --resume
```

---

## 📝 引用

如果在研究中使用这些脚本，请引用VerilogEval论文：

```bibtex
@misc{pinckney2024revisitingverilogevalnewerllms,
  title={Revisiting VerilogEval: Newer LLMs, In-Context Learning, and Specification-to-RTL Tasks},
  author={Nathaniel Pinckney and Christopher Batten and Mingjie Liu and Haoxing Ren and Brucek Khailany},
  year={2024},
  eprint={2408.11053},
  archivePrefix={arXiv},
}
```

---

## ✨ 总结

本项目提供了一套完整的工具链，用于在本地Ollama模型上运行VerilogEval benchmark测试。所有脚本都经过精心设计，确保：

- ✅ 完整保留所有输出（成功和失败）
- ✅ 严格的零温度测试
- ✅ 健壮的错误处理
- ✅ 详细的日志和报告
- ✅ 易于使用和扩展

所有文件已准备就绪，可以立即开始测试！
