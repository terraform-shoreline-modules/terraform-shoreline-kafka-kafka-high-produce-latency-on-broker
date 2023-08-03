
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