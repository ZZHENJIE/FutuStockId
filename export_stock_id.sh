#!/bin/bash

# 定义变量
DB_FILE="./stock.db"
OUTPUT_FILE="stock_id.csv"
MARKET_CODES="10,11,12"
SQLITE_CMD="sqlite3"

# 检测sqlite3是否可用
if ! command -v $SQLITE_CMD &> /dev/null; then
    # Windows可能使用sqlite3.exe
    if [[ -f "./sqlite3.exe" ]]; then
        SQLITE_CMD="./sqlite3.exe"
    else
        echo "错误：未找到 sqlite3 命令。请先安装 SQLite。"
        echo "Linux/macOS: sudo apt-get install sqlite3 或 brew install sqlite"
        echo "Windows: 请从 https://sqlite.org/download.html 下载 sqlite-tools"
        exit 1
    fi
fi

# 检查数据库文件是否存在
if [[ ! -f "$DB_FILE" ]]; then
    echo "错误：数据库文件 $DB_FILE 不存在"
    exit 1
fi

# 检查是否可写入输出目录
if [[ ! -w "." ]]; then
    echo "错误：当前目录不可写"
    exit 1
fi

# 执行SQLite命令
$SQLITE_CMD "$DB_FILE" <<EOF
.headers on
.mode csv
.output $OUTPUT_FILE
SELECT stock_id, code FROM t_stock WHERE market_code IN ($MARKET_CODES);
.output stdout
EOF

# 检查执行是否成功
if [[ $? -ne 0 ]]; then
    echo "错误：SQLite命令执行失败"
    exit 1
fi

# 检查输出文件是否生成
if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "错误：输出文件 $OUTPUT_FILE 未生成"
    exit 1
fi

# 输出成功信息
echo "数据已成功导出到 $OUTPUT_FILE"
echo "记录数：$(wc -l < "$OUTPUT_FILE" | xargs)（包含表头）"