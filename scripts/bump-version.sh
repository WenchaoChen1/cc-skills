#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_FILE="$PROJECT_ROOT/.version-sync.json"

if [[ ! -f "$SYNC_FILE" ]]; then
  echo "错误：未找到 $SYNC_FILE"
  exit 1
fi

# 将 dot notation 转换为 jq path
# 例如 "plugins.0.version" → ".plugins[0].version"
field_to_jq() {
  local field="$1"
  local jq_path="."
  IFS='.' read -ra parts <<< "$field"
  for part in "${parts[@]}"; do
    if [[ "$part" =~ ^[0-9]+$ ]]; then
      jq_path="${jq_path}[${part}]"
    else
      jq_path="${jq_path}.${part}"
    fi
  done
  echo "$jq_path"
}

# 检查所有文件的版本号是否一致
check_versions() {
  local count
  count=$(jq '.files | length' "$SYNC_FILE")

  echo "版本同步检查"
  echo "============================================"
  printf "%-45s %s\n" "文件" "版本"
  echo "--------------------------------------------"

  local versions=()
  for ((i = 0; i < count; i++)); do
    local file_path
    local field
    file_path=$(jq -r ".files[$i].path" "$SYNC_FILE")
    field=$(jq -r ".files[$i].field" "$SYNC_FILE")

    local full_path="$PROJECT_ROOT/$file_path"
    local jq_path
    jq_path=$(field_to_jq "$field")

    if [[ ! -f "$full_path" ]]; then
      printf "%-45s %s\n" "$file_path" "(文件不存在)"
      continue
    fi

    local version
    version=$(jq -r "$jq_path" "$full_path" 2>/dev/null || echo "(读取失败)")
    printf "%-45s %s\n" "$file_path ($field)" "$version"
    versions+=("$version")
  done

  echo "============================================"

  # 检查版本一致性
  local first="${versions[0]:-}"
  local all_match=true
  for v in "${versions[@]}"; do
    if [[ "$v" != "$first" ]]; then
      all_match=false
      break
    fi
  done

  if $all_match; then
    echo "✓ 所有版本一致：$first"
  else
    echo "✗ 版本不一致，请运行 bump-version.sh <version> 进行同步"
    exit 1
  fi
}

# 更新所有文件的版本号
bump_version() {
  local new_version="$1"

  # 验证 semver 格式
  if [[ ! "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "错误：版本号格式无效，需要 X.Y.Z 格式（如 1.2.3）"
    exit 1
  fi

  local count
  count=$(jq '.files | length' "$SYNC_FILE")

  echo "将版本更新为：$new_version"
  echo "============================================"

  for ((i = 0; i < count; i++)); do
    local file_path
    local field
    file_path=$(jq -r ".files[$i].path" "$SYNC_FILE")
    field=$(jq -r ".files[$i].field" "$SYNC_FILE")

    local full_path="$PROJECT_ROOT/$file_path"
    local jq_path
    jq_path=$(field_to_jq "$field")

    if [[ ! -f "$full_path" ]]; then
      echo "跳过：$file_path（文件不存在）"
      continue
    fi

    # 使用临时文件避免截断
    local tmp_file
    tmp_file=$(mktemp)
    jq --arg v "$new_version" "$jq_path = \$v" "$full_path" > "$tmp_file"
    mv "$tmp_file" "$full_path"
    echo "已更新：$file_path ($field) → $new_version"
  done

  echo "============================================"
  echo "✓ 版本同步完成"
}

# 主入口
usage() {
  echo "用法：$(basename "$0") [--check | <version>]"
  echo ""
  echo "  --check       检查所有文件的版本号是否一致"
  echo "  <version>     将所有文件的版本号更新为指定版本（X.Y.Z 格式）"
  echo ""
  echo "示例："
  echo "  $(basename "$0") --check"
  echo "  $(basename "$0") 1.2.0"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

case "$1" in
  --check)
    check_versions
    ;;
  --help | -h)
    usage
    ;;
  *)
    bump_version "$1"
    ;;
esac
