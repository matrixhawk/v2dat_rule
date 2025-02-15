#!/bin/sh

set -e  # 任何命令失败则退出

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT  # 脚本退出时清除临时目录

v2dat_dir=./

geodat_update() {
    curl --connect-timeout 5 -m 60 -kfSL -o "$TMPDIR/geoip.dat" "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip-only-cn-private.dat"
    curl --connect-timeout 5 -m 60 -kfSL -o "$TMPDIR/geosite.dat" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
    \cp -a "$TMPDIR"/geoip.dat "$TMPDIR"/geosite.dat $v2dat_dir
}

v2dat_dump() {
    mkdir -p "$v2dat_dir/rules/"
    
    # 确保 v2dat 工具具有执行权限
    chmod +x "$v2dat_dir/v2dat"
    
    # 清除旧的规则文件
    rm -f "$v2dat_dir/rules/"*.txt

    # 分别生成所需的规则文件
    "$v2dat_dir/v2dat" unpack geoip -o "$v2dat_dir/rules/" -f cn "$v2dat_dir/geoip.dat"
    "$v2dat_dir/v2dat" unpack geoip -o "$v2dat_dir/rules/" -f private "$v2dat_dir/geoip.dat"
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f category-ads-all "$v2dat_dir/geosite.dat"
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f 'geolocation-!cn' "$v2dat_dir/geosite.dat"
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f gfw "$v2dat_dir/geosite.dat"
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f cn "$v2dat_dir/geosite.dat"

    # 根据 v2dat 工具的输出格式（默认 <输入文件名>_<filter>.txt），做重命名
    if [ -f "$v2dat_dir/rules/geoip.dat_cn.txt" ]; then
       mv "$v2dat_dir/rules/geoip.dat_cn.txt" "$v2dat_dir/rules/geoip_cn.txt"
    else
       echo "未找到 geoip.dat_cn.txt"
    fi
    if [ -f "$v2dat_dir/rules/geoip.dat_private.txt" ]; then
       mv "$v2dat_dir/rules/geoip.dat_private.txt" "$v2dat_dir/rules/geoip_private.txt"
    else
       echo "未找到 geoip.dat_private.txt"
    fi
    if [ -f "$v2dat_dir/rules/geosite.dat_category-ads-all.txt" ]; then
       mv "$v2dat_dir/rules/geosite.dat_category-ads-all.txt" "$v2dat_dir/rules/geosite_category-ads-all.txt"
    else
       echo "未找到 geosite.dat_category-ads-all.txt"
    fi
    if [ -f "$v2dat_dir/rules/geosite.dat_geolocation-!cn.txt" ]; then
       mv "$v2dat_dir/rules/geosite.dat_geolocation-!cn.txt" "$v2dat_dir/rules/geosite_geolocation-!cn.txt"
    else
       echo "未找到 geosite.dat_geolocation-!cn.txt"
    fi
    if [ -f "$v2dat_dir/rules/geosite.dat_gfw.txt" ]; then
       mv "$v2dat_dir/rules/geosite.dat_gfw.txt" "$v2dat_dir/rules/geosite_gfw.txt"
    else
       echo "未找到 geosite.dat_gfw.txt"
    fi
    if [ -f "$v2dat_dir/rules/geosite.dat_cn.txt" ]; then
       mv "$v2dat_dir/rules/geosite.dat_cn.txt" "$v2dat_dir/rules/geosite_cn.txt"
    else
       echo "未找到 geosite.dat_cn.txt"
    fi
    
    # 删除 v2dat 工具
    rm -rf "$v2dat_dir/v2dat"
}

update_local_ptr() {
    curl --connect-timeout 5 -m 60 -kfSL -o "$v2dat_dir/rules/local-ptr.txt" "https://raw.githubusercontent.com/sbwml/luci-app-mosdns/v5/luci-app-mosdns/root/etc/mosdns/rule/local-ptr.txt"
}

geodat_update
v2dat_dump
update_local_ptr
