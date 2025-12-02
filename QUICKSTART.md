# VerilogEval Ollama Testing - Quick Start Guide

## 快速开始（5分钟设置）

### 1. 安装依赖

```bash
# 安装Python依赖
pip install -r requirements.txt

# 验证安装
python check_prerequisites.py
```

### 2. 启动Ollama并拉取模型

```bash
# 启动Ollama服务（在另一个终端）
ollama serve

# 拉取一个小模型进行测试
ollama pull mistral:7b
```

### 3. 检查模型可用性

```bash
python check_models.py
```

### 4. 运行快速测试（前10个问题）

```bash
python run_verilog_eval.py --model mistral:7b --limit 10
```

### 5. 查看结果

```bash
cat results/mistral_7b_0shot_temp0.0/summary.txt
```

---

## 完整测试流程

### 测试单个模型（全部156个问题）

```bash
python run_verilog_eval.py --model gemma3:12b
```

### 测试所有模型

```bash
# 首先确保所有模型都已拉取
ollama pull llama3.2:3b
ollama pull mistral:7b
ollama pull qwen3:8b
ollama pull gemma3:12b
ollama pull deepseek-r1:14b
ollama pull phi4:14b
ollama pull gpt-oss:20b

# 运行批量测试
python run_all_models.py
```

### 对比结果

```bash
cat results/all_models_comparison.txt
```

---

## 常见问题

**Q: Ollama服务连接失败？**
```bash
# 确保Ollama正在运行
ollama serve
```

**Q: 模型未找到？**
```bash
# 拉取模型
ollama pull <model_name>
```

**Q: 内存不足？**
- 先测试小模型（llama3.2:3b, mistral:7b）
- 一次只运行一个模型

**Q: 测试被中断？**
```bash
# 使用--resume恢复
python run_verilog_eval.py --model <model> --resume
```

---

## 输出文件说明

每个问题会生成以下文件：

```
results/<model>/Prob001_zero/
├── *_sample01.sv                 # 完整Verilog代码
├── *_raw_response.txt            # 模型原始输出（完整保留）
├── *_extracted_code.txt          # 提取的代码片段
├── *-sv-generate.log             # 生成日志（含prompt）
└── *-sv-iv-test.log              # iverilog测试日志
```

所有成功和失败的输出都会保留，方便后续分析。

---

## 预期测试时间

根据模型大小和硬件：

| 模型大小 | 单个问题 | 全部156问题 |
|---------|---------|------------|
| 3B-7B   | 1-3秒   | 5-10分钟   |
| 8B-14B  | 2-5秒   | 10-20分钟  |
| 20B+    | 5-10秒  | 20-30分钟  |

---

## 详细文档

完整文档请查看：[README_TESTING.md](README_TESTING.md)
