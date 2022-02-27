variable "cloudwatch_schedule_stop" {
  type = string
  description = "cron(0 8 ? * 2-6 *)"
}


variable "cloudwatch_schedule_start" {
  type = string
  description = "cron(0 5 ? * 2-6 *)"
}