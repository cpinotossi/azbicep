#!/bin/bash

az network watcher connection-monitor create -g $1 -l $2 --endpoint-source-type AzureVM --endpoint-dest-type AzureVM --test-config-name icmp --protocol Icmp --icmp-disable-trace-route false \
--name $3 \
--test-group-name ${3}tgrp \
--endpoint-source-resource-id $4 \
--endpoint-source-name $5 \
--endpoint-dest-resource-id $6 \
--endpoint-dest-name $7 -o none $8