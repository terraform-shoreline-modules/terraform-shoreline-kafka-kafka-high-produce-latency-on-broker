
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka high produce latency on broker.
---

This incident type typically involves a high produce latency on a broker in a Kafka environment. This can result in various potential impacts, such as client timeouts, delays in processing workload, or a lack of capacity leading to performance issues. Recommended actions typically include investigating the state of the broker, rebalancing topics, expanding capacity, or restarting/replacing the broker. Monitoring tools may trigger alerts to notify engineers of this potential issue.

### Parameters
```shell
# Environment Variables



export BROKER_IP="PLACEHOLDER"

export BROKER_PORT="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export ZOOKEEPER_URL="PLACEHOLDER"

export PATH_TO_KAFKA_CONFIG_FILE="PLACEHOLDER"

export NEW_BATCH_SIZE="PLACEHOLDER"

export NEW_NUMBER_OF_ACKNOWLEDGMENTS="PLACEHOLDER"

```

## Debug

### Check if Kafka is running on the broker
```shell
systemctl status kafka
```

### Check if there are any issues with the Kafka process
```shell
journalctl -u kafka  --since "2 hours ago"
```

### Check the disk usage on the broker
```shell
df -h
```

### Check the network connections on the broker
```shell
netstat -an | grep ${BROKER_IP}
```

### Check the number of connections to the broker
```shell
netstat -an | grep ${BROKER_IP} | wc -l
```

### Check the number of messages in the topic
```shell
kafka-run-class kafka.tools.GetOffsetShell --broker-list ${BROKER_IP}:${BROKER_PORT} --topic ${TOPIC_NAME}
```

### Check the number of partitions in the topic
```shell
kafka-topics --zookeeper ${ZOOKEEPER_IP}:${ZOOKEEPER_PORT} --describe --topic ${TOPIC_NAME}
```

### Check the resource utilization of the broker
```shell
top
```

### Check the Kafka log file for errors
```shell
tail -f /var/log/kafka/kafka.log
```

### High network latency can cause produce latency on Kafka brokers.
```shell
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

```

## Repair

### Tune Kafka configuration parameters, such as the producer batch size and the number of acknowledgments required, to optimize performance.
```shell

#!/bin/bash

# Set the Kafka configuration file path

KAFKA_CONFIG_FILE=${PATH_TO_KAFKA_CONFIG_FILE}

# Backup the original configuration file

cp $KAFKA_CONFIG_FILE $KAFKA_CONFIG_FILE.bak

# Update the producer batch size parameter

sed -i 's/producer.batch.size=.*/producer.batch.size=${NEW_BATCH_SIZE}/g' $KAFKA_CONFIG_FILE

# Update the number of acknowledgments required parameter

sed -i 's/acks=.*/acks=${NEW_NUMBER_OF_ACKNOWLEDGMENTS}/g' $KAFKA_CONFIG_FILE

# Restart the Kafka service

systemctl restart kafka.service

```