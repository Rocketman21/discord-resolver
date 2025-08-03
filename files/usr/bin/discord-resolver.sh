#!/bin/sh

    # atlanta
    # brazil
    # bucharest
    # buenos-aires
    # dammam
    # dubai
    # hongkong
    # india
    # jakarta
    # japan
    # madrid
    # milan
    # montreal
    # newark
    # oregon
    # russia
    # santa-clara
    # santiago
    # seattle
    # singapore
    # south-korea
    # southafrica
    # st-pete
    # stage-scale
    # sydney
    # tel-aviv
    # us-central
    # us-east
    # us-south
    # us-west

locations="\
    frankfurt
    rotterdam
    finland
    warsaw
    stockholm
"
src="$1"

MIN_RESOLVED_IP_LINES_COUNT=20
SLEEP_TIME=0.1
MAX_CONCURRENT_DNS_QUERIES=60 # Divide this by 2 if uncomment discord.media
ADDR_PER_LOCATION=15000

check_conttrack() {
    max_conntrack=$(cat /proc/sys/net/netfilter/nf_conntrack_max)
    cur_conntrack=$(cat /proc/sys/net/netfilter/nf_conntrack_count)

    threshold=$(( max_conntrack * 90 / 100 ))

    if [ "$cur_conntrack" -gt "$threshold" ]; then
        echo "[WARNING] conntrack table nearing full, flushing DNS entries..."
        conntrack -D -p udp --dport 53
    fi
}

resolve() {
    start=$(date +%s)
    logger "[START] Resolving discord IPs..."

    echo "$src" | while read -r loc; do
        [ -z "$loc" ] && continue

        i=0
        while [ "$i" -lt "$ADDR_PER_LOCATION" ]; do
            check_conttrack

            # nslookup "$loc$i.discord.media" > /dev/null &
            nslookup "$loc$i.discord.gg" > /dev/null &

        if [ $(( i % $MAX_CONCURRENT_DNS_QUERIES )) -eq 0 ]; then 
            logger "Resolving Discord IPs... Current location: $loc index: $i out of $ADDR_PER_LOCATION"
        wait
            timeout $SLEEP_TIME sleep 0
        fi

        i=$((i + 1))
    done

    wait
    done

    end=$(date +%s)
    logger "[DONE] Resolving discord IPs. Elapsed time: $((end - start))s"
}

start() {
    [ -z "$1" ] && src="$locations"

    resolve

    while true; do
        if [ "$(nft list set inet fw4 vpn_domains | wc -l)" -lt "$MIN_RESOLVED_IP_LINES_COUNT" ]; then
            logger "Less than $MIN_RESOLVED_IP_LINES_COUNT vpn_domains ip lines foud"
            resolve
        fi

        wait
        sleep 5;
    done
}

"$@"
