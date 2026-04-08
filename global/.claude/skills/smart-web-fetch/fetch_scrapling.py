#!/usr/bin/env python3
"""
Scrapling Fetcher - 处理反爬页面的网页抓取
用于微信公众号等需要绕过反爬的页面
"""

import sys
import json

def scrapling_fetch(url: str, timeout: int = 30) -> dict:
    """
    使用 Scrapling 获取网页内容（处理反爬页面）
    """
    try:
        from scrapling import Fetcher
        import html2text

        fetcher = Fetcher()
        page = fetcher.get(url)

        # 按优先级尝试正文选择器（针对微信公众号等特殊页面优化）
        selectors = [
            '#js_content',           # 微信公众号正文
            '.rich_media_content',   # 微信公众号（旧版）
            'article',               # 标准文章标签
            'main',                  # 主内容区
            '.post-content',         # 常见博客类
            '[class*="content"]',    # 通用内容区
            '[class*="body"]',       # 通用正文
        ]

        element = None
        html_content = None

        for sel in selectors:
            try:
                elem = page.find(sel)
                if elem and hasattr(elem, 'html_content'):
                    # 检查 HTML 内容长度
                    if len(elem.html_content) > 500:
                        element = elem
                        html_content = elem.html_content
                        break
            except:
                continue

        # 如果没找到特定选择器，使用整个页面
        if not html_content:
            html_content = page.html_content if hasattr(page, 'html_content') else str(page)

        # 转换为 Markdown
        h = html2text.HTML2Text()
        h.ignore_links = False
        h.ignore_images = False
        h.body_width = 0  # 不自动折行

        md_content = h.handle(html_content)

        if len(md_content) > 100:
            return {
                "success": True,
                "url": url,
                "content": md_content,
                "source": "scrapling",
                "error": None
            }
        else:
            return {
                "success": False,
                "url": url,
                "content": "",
                "source": "scrapling",
                "error": "Content too short"
            }

    except ImportError as e:
        return {
            "success": False,
            "url": url,
            "content": "",
            "source": "scrapling",
            "error": f"Scrapling not installed: {e}. Run: pip3 install scrapling html2text curl_cffi browserforge"
        }
    except Exception as e:
        return {
            "success": False,
            "url": url,
            "content": "",
            "source": "scrapling",
            "error": str(e)
        }


def main():
    if len(sys.argv) < 2:
        print(json.dumps({
            "success": False,
            "error": "Usage: fetch_scrapling.py <url>"
        }, ensure_ascii=False))
        sys.exit(1)

    url = sys.argv[1]
    result = scrapling_fetch(url)
    print(json.dumps(result, ensure_ascii=False))

    if not result["success"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
