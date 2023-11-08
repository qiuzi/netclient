#!/bin/bash

sh -c rc-status
#Define cleanup
cleanup() {
    touch /etc/netclient/a.out
    nets=($(wg show interfaces))
    for net in ${nets[@]}; do
        if [ ${net} == "netmaker*" ]; then
            echo "deleting interface" $net >> /etc/netclient/a.out
            ip link del $net
        fi
    done
}

#Trap SigTerm
trap 'cleanup' SIGTERM &

echo "[netclient] joining network"

if [ -z "${SLEEP}" ]; then
    SLEEP=10
fi

TOKEN_CMD=""
if [ "$TOKEN" != "" ]; then
    TOKEN_CMD="-t $TOKEN"
fi

PORT_CMD=""
if [ "${PORT}" != "" ]; then
    PORT_CMD="-p ${PORT}"
fi

ENDPOINT_CMD=""
if [ "${ENPOINT}" != "" ];then
    ENDPOINT_CMD="-e ${ENPOINT}"
fi

MTU_CMD=""
if [ "${MTU}" != "" ];then
    MTU_CMD="-m ${MTU}"
fi

HOSTNAME_CMD=""
if [ "${HOST_NAME}" != "" ];then
    HOSTNAME_CMD="-o ${HOST_NAME}"
fi

STATIC_CMD=""
if [ "${IS_STATIC}" != "" ];then
    STATIC_CMD="-i ${IS_STATIC}"
fi
IFACE_CMD=""
if [ "${IFACE_NAME}" != "" ];then
    STATIC_CMD="-I ${IFACE_NAME}"
fi

echo "[netclient] Starting netclient daemon"
/root/netclient install
wait $!
netclient join $TOKEN_CMD $PORT_CMD $ENDPOINT_CMD $MTU_CMD $HOSTNAME_CMD $STATIC_CMD
if [ $? -ne 0 ]; then { echo "Failed to join, quitting." ; exit 1; } fi

sleep infinity

