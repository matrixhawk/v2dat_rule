#!/bin/sh

set -e  # 若任一命令失败则退出

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
    rm -f "$v2dat_dir/rules/geo"*.txt "$v2dat_dir/rules/geosite"*.txt

    # 原始解包（可保留或根据实际需求移除）
    "$v2dat_dir/v2dat" unpack geoip -o "$v2dat_dir/rules/" -f cn "$v2dat_dir/geoip.dat"
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f apple -f cn -f 'geolocation-!cn' "$v2dat_dir/geosite.dat"

    # 增加以下各项解包

    # 解包 geoip_cn.txt（提取 "cn" 标签）
    "$v2dat_dir/v2dat" unpack geoip -o "$v2dat_dir/rules/" -f cn "$v2dat_dir/geoip.dat"
    # 解包 geoip_private.txt（提取 "private" 标签）
    "$v2dat_dir/v2dat" unpack geoip -o "$v2dat_dir/rules/" -f private "$v2dat_dir/geoip.dat"
    
    # 解包 geosite_category-ads-all.txt（提取 "category-ads-all" 标签）
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f category-ads-all "$v2dat_dir/geosite.dat"
    # 解包 geosite_geolocation-!cn.txt（提取 "geolocation-!cn" 标签）
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f 'geolocation-!cn' "$v2dat_dir/geosite.dat"
    # 解包 geosite_gfw.txt（提取 "gfw" 标签）
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f gfw "$v2dat_dir/geosite.dat"
    # 解包 geosite_cn.txt（提取 "cn" 标签）
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f cn "$v2dat_dir/geosite.dat"

    # 重命名生成的文件为期望的文件名
    mv "$v2dat_dir/rules/geoip.dat_cn.txt" "$v2dat_dir/rules/geoip_cn.txt"
    mv "$v2dat_dir/rules/geoip.dat_private.txt" "$v2dat_dir/rules/geoip_private.txt"
    mv "$v2dat_dir/rules/geosite.dat_category-ads-all.txt" "$v2dat_dir/rules/geosite_category-ads-all.txt"
    mv "$v2dat_dir/rules/geosite.dat_geolocation-!cn.txt" "$v2dat_dir/rules/geosite_geolocation-!cn.txt"
    mv "$v2dat_dir/rules/geosite.dat_gfw.txt" "$v2dat_dir/rules/geosite_gfw.txt"
    mv "$v2dat_dir/rules/geosite.dat_cn.txt" "$v2dat_dir/rules/geosite_cn.txt"
    
    # 解包完毕后删除 v2dat 工具，避免残留
    rm -rf "$v2dat_dir/v2dat"
}

update_local_ptr() {
    curl --connect-timeout 5 -m 60 -kfSL -o "$v2dat_dir/rules/local-ptr.txt" "https://raw.githubusercontent.com/sbwml/luci-app-mosdns/v5/luci-app-mosdns/root/etc/mosdns/rule/local-ptr.txt"
}

geodat_update
v2dat_dump
update_local_ptr
