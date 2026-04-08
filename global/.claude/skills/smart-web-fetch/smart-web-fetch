#!/bin/bash
#
# Smart Web Fetch Pro - 智能网页抓取工具 (增强版)
# 替代内置 web_fetch，自动使用多种清洗服务获取干净 Markdown
# 支持多级降级策略，大幅降低 Token 消耗
# 四级降级：Jina Reader → markdown.new → defuddle.md → Scrapling (反爬)
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
TIMEOUT=30
MAX_RETRIES=2

# 清洗服务（按优先级排序）
JINA_READER="https://r.jina.ai/http"
MARKDOWN_NEW="https://markdown.new"
DEFUDDLE_MD="https://defuddle.md"

# 打印帮助信息
show_help() {
    cat << EOF
Smart Web Fetch Pro - 智能网页抓取工具 (增强版)

用法:
    smart-web-fetch <URL> [选项]

选项:
    -h, --help          显示帮助信息
    -o, --output FILE   输出到文件
    -s, --service NAME  指定清洗服务 (jina|markdown|defuddle|scrapling)
    -v, --verbose       显示详细日志
    -j, --json          输出 JSON 格式（包含 source 等元数据）
    --no-clean          禁用 HTML 清洗（仅使用基础抓取）

示例:
    smart-web-fetch https://example.com
    smart-web-fetch https://example.com -o output.md
    smart-web-fetch https://example.com -s jina
    smart-web-fetch https://mp.weixin.qq.com/s/xxx --json

支持的清洗服务:
    jina        - Jina Reader (r.jina.ai) - 推荐，最稳定，速度快
    markdown    - markdown.new API - 备用服务
    defuddle    - defuddle.md - 备用服务
    scrapling   - Python Scrapling - 处理反爬页面（如微信公众号）

降级策略:
    1. Jina Reader (普通网页，速度最快)
    2. markdown.new (Jina 失败时降级)
    3. defuddle.md (前两级失败时降级)
    4. Scrapling (反爬页面，如微信公众号)
EOF
}

# 日志函数
log_info() {
    [[ "$VERBOSE" == "1" ]] && echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    [[ "$VERBOSE" == "1" ]] && echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    [[ "$VERBOSE" == "1" ]] && echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# 检测内容是否被反爬拦截
is_blocked_content() {
    local content="$1"
    local content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')

    # 检测反爬关键词
    if echo "$content_lower" | grep -qiE '(环境异常 | 验证|captcha|access denied|blocked|forbidden|403 forbidden|cloudflare)'; then
        return 0
    fi
    return 1
}

# 使用 Jina Reader 获取内容
fetch_jina() {
    local url="$1"
    log_info "尝试使用 Jina Reader 获取内容..."

    # Jina Reader 直接使用 URL 作为参数
    local jina_url="https://r.jina.ai/${url}"

    local response
    if ! response=$(curl -sL --max-time "$TIMEOUT" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "Accept: text/html,application/xhtml+xml" \
        "$jina_url" 2>&1); then
        log_warn "Jina Reader 请求失败"
        return 1
    fi

    if [[ -z "$response" ]] || [[ ${#response} -lt 100 ]]; then
        log_warn "Jina Reader 返回内容过短"
        return 1
    fi

    # 检查是否被反爬拦截
    if is_blocked_content "$response"; then
        log_warn "Jina Reader 内容可能被反爬拦截"
        return 1
    fi

    log_success "Jina Reader 成功获取内容"
    echo "$response"
    return 0
}

# 使用 markdown.new 获取内容
fetch_markdown_new() {
    local url="$1"
    log_info "尝试使用 markdown.new 获取内容..."

    local response
    if ! response=$(curl -sL --max-time "$TIMEOUT" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "Accept: text/html,application/xhtml+xml" \
        "${MARKDOWN_NEW}/${url}" 2>&1); then
        log_warn "markdown.new 请求失败"
        return 1
    fi

    if [[ -z "$response" ]] || [[ ${#response} -lt 100 ]]; then
        log_warn "markdown.new 返回内容过短"
        return 1
    fi

    # 检查是否被反爬拦截
    if is_blocked_content "$response"; then
        log_warn "markdown.new 内容可能被反爬拦截"
        return 1
    fi

    log_success "markdown.new 成功获取内容"
    echo "$response"
    return 0
}

# 使用 defuddle.md 获取内容
fetch_defuddle() {
    local url="$1"
    log_info "尝试使用 defuddle.md 获取内容..."

    local response
    if ! response=$(curl -sL --max-time "$TIMEOUT" \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        -H "Accept: text/html,application/xhtml+xml" \
        "${DEFUDDLE_MD}/${url}" 2>&1); then
        log_warn "defuddle.md 请求失败"
        return 1
    fi

    if [[ -z "$response" ]] || [[ ${#response} -lt 100 ]]; then
        log_warn "defuddle.md 返回内容过短"
        return 1
    fi

    # 检查是否被反爬拦截
    if is_blocked_content "$response"; then
        log_warn "defuddle.md 内容可能被反爬拦截"
        return 1
    fi

    log_success "defuddle.md 成功获取内容"
    echo "$response"
    return 0
}

# 使用 Scrapling 获取内容 (处理反爬页面)
fetch_scrapling() {
    local url="$1"
    log_info "尝试使用 Scrapling 获取内容（处理反爬页面）..."

    # 检查 Scrapling 是否已安装
    if ! python3 -c "import scrapling" 2>/dev/null; then
        log_warn "Scrapling 未安装，请使用以下命令安装:"
        log_warn "pip3 install scrapling html2text curl_cffi browserforge"
        return 1
    fi

    # 使用 Python 脚本获取内容
    local script_dir="$(dirname "$0")"
    local scrapling_script="${script_dir}/fetch_scrapling.py"

    if [[ -f "$scrapling_script" ]]; then
        local response
        response=$(python3 "$scrapling_script" "$url" 2>&1)
        if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
            log_success "Scrapling 成功获取内容"
            echo "$response"
            return 0
        fi
    fi

    log_warn "Scrapling 获取失败"
    return 1
}

# 基础抓取（使用 curl 直接获取）
fetch_basic() {
    local url="$1"
    log_info "尝试使用基础抓取..."

    local response
    if ! response=$(curl -sL --max-time "$TIMEOUT" \
        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
        "$url" 2>&1); then
        log_warn "基础抓取失败"
        return 1
    fi

    # 如果安装了 html2text，使用它转换为 markdown
    if command -v html2text &>/dev/null; then
        echo "$response" | html2text -utf8 2>/dev/null || echo "$response"
    elif command -v lynx &>/dev/null; then
        echo "$response" | lynx -stdin -dump -nolist 2>/dev/null || echo "$response"
    else
        echo "$response"
    fi

    log_success "基础抓取成功"
    return 0
}

# 主抓取函数
smart_fetch() {
    local url="$1"
    local specified_service="$2"
    local result=""

    # 验证 URL
    if [[ -z "$url" ]]; then
        log_error "请提供 URL"
        return 1
    fi

    # 添加协议前缀（如果没有）
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="https://$url"
        log_info "自动添加 https:// 前缀：$url"
    fi

    log_info "开始抓取：$url"

    # 如果指定了服务，优先使用
    if [[ -n "$specified_service" ]]; then
        case "$specified_service" in
            jina)
                result=$(fetch_jina "$url") && { echo "$result"; return 0; }
                ;;
            markdown)
                result=$(fetch_markdown_new "$url") && { echo "$result"; return 0; }
                ;;
            defuddle)
                result=$(fetch_defuddle "$url") && { echo "$result"; return 0; }
                ;;
            scrapling)
                result=$(fetch_scrapling "$url") && { echo "$result"; return 0; }
                ;;
            *)
                log_warn "未知服务：$specified_service"
                ;;
        esac
    fi

    # 默认降级策略
    log_info "使用自动降级策略..."

    # 1. 尝试 Jina Reader (最稳定，速度最快)
    result=$(fetch_jina "$url") && { echo "$result"; return 0; }

    # 2. 尝试 markdown.new
    result=$(fetch_markdown_new "$url") && { echo "$result"; return 0; }

    # 3. 尝试 defuddle.md
    result=$(fetch_defuddle "$url") && { echo "$result"; return 0; }

    # 4. 尝试 Scrapling (反爬页面)
    result=$(fetch_scrapling "$url") && { echo "$result"; return 0; }

    # 5. 基础抓取
    if [[ "$NO_CLEAN" != "1" ]]; then
        result=$(fetch_basic "$url") && { echo "$result"; return 0; }
    fi

    log_error "所有抓取方式均失败"
    return 1
}

# 解析命令行参数
URL=""
OUTPUT=""
SERVICE=""
VERBOSE="0"
NO_CLEAN="0"
JSON_OUTPUT="0"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="1"
            shift
            ;;
        -j|--json)
            JSON_OUTPUT="1"
            shift
            ;;
        --no-clean)
            NO_CLEAN="1"
            shift
            ;;
        -*)
            log_error "未知选项：$1"
            show_help
            exit 1
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

# 执行抓取
if [[ -z "$URL" ]]; then
    log_error "请提供 URL"
    show_help
    exit 1
fi

CONTENT=$(smart_fetch "$URL" "$SERVICE")
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    if [[ "$JSON_OUTPUT" == "1" ]]; then
        # 输出 JSON 格式
        SOURCE="${SERVICE:-auto}"
        cat << EOF
{
  "success": true,
  "url": "$URL",
  "content": $(echo "$CONTENT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read(), ensure_ascii=False))'),
  "source": "$SOURCE"
}
EOF
    elif [[ -n "$OUTPUT" ]]; then
        echo "$CONTENT" > "$OUTPUT"
        log_success "内容已保存到：$OUTPUT"
    else
        echo "$CONTENT"
    fi
else
    if [[ "$JSON_OUTPUT" == "1" ]]; then
        cat << EOF
{
  "success": false,
  "url": "$URL",
  "content": "",
  "source": "none",
  "error": "所有抓取方式均失败"
}
EOF
    fi
    exit 1
fi
