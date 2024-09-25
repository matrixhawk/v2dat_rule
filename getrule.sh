#!/bin/sh

set -e  # Exit if any command fails

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT  # Ensure temporary directory is removed on script exit

v2dat_dir=./

geodat_update() {
    curl --connect-timeout 5 -m 60 -kfSL -o "$TMPDIR/geoip.dat" "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip-only-cn-private.dat"
    
    curl --connect-timeout 5 -m 60 -kfSL -o "$TMPDIR/geosite.dat" "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

    \cp -a "$TMPDIR"/geoip.dat "$TMPDIR"/geosite.dat $v2dat_dir
}

# Unpack and process the data
v2dat_dump() {
    mkdir -p "$v2dat_dir/rules/"

    #curl -fSL -o "$v2dat_dir/v2dat" "https://raw.githubusercontent.com/xukecheng/scripts/main/v2dat"
    chmod +x "$v2dat_dir/v2dat"

    rm -f "$v2dat_dir/rules/geo"*.txt
    "$v2dat_dir/v2dat" unpack geoip -o "$v2dat_dir/rules/" -f cn "$v2dat_dir/geoip.dat"
    "$v2dat_dir/v2dat" unpack geosite -o "$v2dat_dir/rules/" -f apple -f cn -f 'geolocation-!cn' "$v2dat_dir/geosite.dat"

    rm -rf "$v2dat_dir/v2dat"
}

update_local_ptr() {
    curl --connect-timeout 5 -m 60 -kfSL -o "$v2dat_dir/rules/local-ptr.txt" "https://raw.githubusercontent.com/sbwml/luci-app-mosdns/v5/luci-app-mosdns/root/etc/mosdns/rule/local-ptr.txt"
}

geodat_update
v2dat_dump
update_local_ptr

#touch $v2dat_dir/rules/force-nocn.txt
#touch $v2dat_dir/rules/force-cn.txt
# force-cn 是强制本地解析域名，force-nocn 是强制非本地解析域名

echo "localhost 127.0.0.1" >> $v2dat_dir/rules/hosts.txt