#!/usr/bin/env bash

#============================================================
# File: deploy.sh
# Description: 部署（拉取上游、增量翻译）
# URL:
# Author: Jetsung Chan <i@jetsung.com>
# Version: 0.2.0
# CreatedAt: 2025-12-16
# UpdatedAt: 2026-08-11
#============================================================


if [[ -n "${DEBUG:-}" ]]; then
    set -eux
else
    set -euo pipefail
fi

DEFAULT_BRANCH="main"
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/moghtech/komodo.git}"

DELETE_FILE="deleted_docs.txt"
ADD_FILE="new_docs.txt"
MODIFIED_FILE="modified_docs.txt"
TRANSLATE_LIST="translate_list.txt"

# 英文源目录（上游 docsite/docs 的镜像）
DOCS_DIR="docs"
# 中文译文目录
ZH_DIR="docs_zh"

install_aitr() {
    if ! command -v aitr &> /dev/null; then
        echo "正在安装 aitr ..."
        curl -L https://fx4.cn/aitr | bash
    fi
}

merge_config() {
    if [[ -f config.example.toml ]]; then
        sed '/providers/,$d' ./config.example.toml | tee config.toml > /dev/null
    fi

    if [[ -f aitr.toml ]]; then
        sed -n '/logging/,$p' aitr.toml | tee -a config.toml > /dev/null
    fi
}

# 拉取上游最新英文源（仅 docs/，部署框架由 CI clone 上游）
merge_source() {
    if ! git remote get-url upstream &> /dev/null; then
        git remote add upstream "$UPSTREAM_REPO"
    fi

    git fetch upstream "$DEFAULT_BRANCH"

    # 用上游 main 的 docsite/docs 覆盖本地 docs/（英文源镜像）
    git rm -rf "$DOCS_DIR" >/dev/null 2>&1 || true
    mkdir -p "$DOCS_DIR"
    git checkout "upstream/$DEFAULT_BRANCH" -- docsite/docs
    # 将 docsite/docs 的内容移动到 docs/
    for item in docsite/docs/*; do
        base=$(basename "$item")
        git mv "$item" "$DOCS_DIR/$base" 2>/dev/null || mv "$item" "$DOCS_DIR/$base"
    done
    rm -rf docsite

    # 记录上游 commit，便于 CI 锁定部署框架版本
    git rev-parse --short "upstream/$DEFAULT_BRANCH" > commit.txt

    echo "已同步上游至 $(cat commit.txt)"
}

# 增量更新：对比英文源与 HEAD，翻译新增/修改文件
incremental_update() {
    merge_source

    # 记录英文源中相对 HEAD 被删除的文件（上游已移除的文档）
    git diff --name-only HEAD -- "$DOCS_DIR" --diff-filter=D | tee "$DELETE_FILE"

    # 删除译文目录中对应的中文文件
    while read -r file; do
        [[ -z "$file" ]] && continue
        zh_file="${file/$DOCS_DIR/$ZH_DIR}"
        echo "删除废弃译文: $zh_file"
        rm -rf "$zh_file" || true
    done < "$DELETE_FILE"

    # 更新 git 索引
    git add .

    # 记录新增和修改的英文文件
    git diff --cached --name-only --diff-filter=A -- "$DOCS_DIR" | tee "$ADD_FILE"
    git diff --cached --name-only --diff-filter=M -- "$DOCS_DIR" | tee "$MODIFIED_FILE"

    cat "$ADD_FILE" "$MODIFIED_FILE" | tee "$TRANSLATE_LIST"

    # 移除以图片结尾的文件
    sed -i '/\.\(png\|jpg\|jpeg\|gif\|svg\)$/d' "$TRANSLATE_LIST"

    # 合并 aitr 配置
    merge_config

    # 确保 aitr 已安装
    install_aitr

    # 调用 aitr 进行翻译（输入为英文源路径列表，输出到译文目录）
    if command -v aitr &> /dev/null; then
        aitr --input "$TRANSLATE_LIST" --list --output "$ZH_DIR"
    else
        echo "aitr 未安装，跳过翻译步骤。"
    fi
}

# 复制 docs_zh 至上游 docsite/docs（本地预览用；CI 中由 clone 上游后执行）
copy_docs_zh() {
    if [[ ! -d docsite ]]; then
        echo "本地无 docsite，请先 clone 上游："
        echo "  git clone $UPSTREAM_REPO docsite && cd docsite && git checkout \$(cat ../commit.txt)"
        exit 1
    fi
    cp -r "$ZH_DIR"/* docsite/docs/
    echo "已将 $ZH_DIR 复制到 docsite/docs"
}

# 调用翻译脚本（全量）
translate() {
    install_aitr
    aitr
}

usage() {
    cat << EOF
用法: $0 [选项]

选项:
  -g --config        合并 config.toml
  -s --source        拉取上游最新英文源到 docs/
  -i --incremental   增量更新（拉取上游 + 翻译新增/修改）
  -c --copy          复制 docs_zh 至 docsite/docs（本地预览，需先 clone 上游）
  -t --translate     全量翻译（调用 aitr）
  -h --help          显示此帮助信息

示例:
  $0 --incremental    # 同步上游并增量翻译
  $0 --copy           # 本地预览前把译文覆盖到 docsite/docs
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--copy)
                copy_docs_zh
                shift
                ;;
            -g|--config)
                merge_config
                shift
                ;;
            -s|--source)
                merge_source
                shift
                ;;
            -i|--incremental)
                incremental_update
                shift
                ;;
            -t|--translate)
                translate
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                echo "未知参数: $1" >&2
                usage
                exit 1
                ;;
        esac
    done
}

main "$@"
