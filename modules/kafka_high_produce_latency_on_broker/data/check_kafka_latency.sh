#!/bin/bash

# Get the IP address of the Kafka broker to test

KAFKA_BROKER_IP=${KAFKA_BROKER_IP}

# Ping the Kafka broker to check for network latency

ping -c 10 $KAFKA_BROKER_IP

# Check the produce latency of the Kafka broker

KAFKA_PRODUCER_LATENCY=$(kafka-producer-perf-test.sh --topic test --num-records 1000000 --record-size 100 --throughput -1 --producer-props bootstrap.servers=$KAFKA_BROKER_IP:9092 acks=1 | grep "Average" | awk '{print $NF}')

# Check if the produce latency is high

if (( $(echo "$KAFKA_PRODUCER_LATENCY > 50" | bc -l) )); then

  echo "High produce latency detected on Kafka broker."

else

  echo "No issues detected with Kafka broker produce latency."

fi