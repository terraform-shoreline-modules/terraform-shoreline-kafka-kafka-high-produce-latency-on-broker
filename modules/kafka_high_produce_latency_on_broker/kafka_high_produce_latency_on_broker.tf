resource "shoreline_notebook" "kafka_high_produce_latency_on_broker" {
  name       = "kafka_high_produce_latency_on_broker"
  data       = file("${path.module}/data/kafka_high_produce_latency_on_broker.json")
  depends_on = [shoreline_action.invoke_check_kafka_latency,shoreline_action.invoke_kafka_config_update]
}

resource "shoreline_file" "check_kafka_latency" {
  name             = "check_kafka_latency"
  input_file       = "${path.module}/data/check_kafka_latency.sh"
  md5              = filemd5("${path.module}/data/check_kafka_latency.sh")
  description      = "High network latency can cause produce latency on Kafka brokers."
  destination_path = "/agent/scripts/check_kafka_latency.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kafka_config_update" {
  name             = "kafka_config_update"
  input_file       = "${path.module}/data/kafka_config_update.sh"
  md5              = filemd5("${path.module}/data/kafka_config_update.sh")
  description      = "Tune Kafka configuration parameters, such as the producer batch size and the number of acknowledgments required, to optimize performance."
  destination_path = "/agent/scripts/kafka_config_update.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_kafka_latency" {
  name        = "invoke_check_kafka_latency"
  description = "High network latency can cause produce latency on Kafka brokers."
  command     = "`chmod +x /agent/scripts/check_kafka_latency.sh && /agent/scripts/check_kafka_latency.sh`"
  params      = []
  file_deps   = ["check_kafka_latency"]
  enabled     = true
  depends_on  = [shoreline_file.check_kafka_latency]
}

resource "shoreline_action" "invoke_kafka_config_update" {
  name        = "invoke_kafka_config_update"
  description = "Tune Kafka configuration parameters, such as the producer batch size and the number of acknowledgments required, to optimize performance."
  command     = "`chmod +x /agent/scripts/kafka_config_update.sh && /agent/scripts/kafka_config_update.sh`"
  params      = ["NEW_NUMBER_OF_ACKNOWLEDGMENTS","NEW_BATCH_SIZE","PATH_TO_KAFKA_CONFIG_FILE"]
  file_deps   = ["kafka_config_update"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_config_update]
}

