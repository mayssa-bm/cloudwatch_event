/******************** lambda function *********************/
data "archive_file" "zipit" {
  type        = "zip"
  source_file = "base-resource-lambda.py"
  output_path = "lambda.zip"
}
/*set up lambda function  to start and stop instances***/


resource "aws_lambda_function" "ec2-stop-start" {
  filename      = "lambda.zip"
  function_name = "base-resource-lambda"
  role          = aws_iam_role.lambda-role.arn
  handler       = "base-resource-lambda.lambda_handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"

  runtime = "python3.7"
  timeout = 63
}




/******************** cloudwatch event rules *********************/

/*** set up cloud watch event to stop ec2 ***/
resource "aws_cloudwatch_event_rule" "ec2-stop-event-rule" {
  name        = "ec2-stop-event-rule"
  description = "Trigger Stop Instance at 5PM"
  schedule_expression = var.cloudwatch_schedule_stop
}

/*** set up cloud watch event to start ec2 ***/
resource "aws_cloudwatch_event_rule" "ec2-start-event-rule" {
  name        = "ec2-start-event-rule"
  description = "Trigger start Instance at 8AM"
  schedule_expression = var.cloudwatch_schedule_start
}





/******************** targets *********************/

/* stop event target*/
resource "aws_cloudwatch_event_target" "ec2-stop-event-rule-target" {
  rule      = aws_cloudwatch_event_rule.ec2-stop-event-rule.name
  target_id = "lambda"
  arn       = awion.ec2-stop-start.arn
  input     = "{\"action\":\"stop\"}"
}

/* start event target*/
resource "aws_cloudwatch_event_target" "ec2-start-event-rule-target" {
  rule      = aws_cloudwatch_event_rule.ec2-start-event-rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.ec2-stop-start.arn
  input     = "{\"action\":\"start\"}"
}



/********************* permissions ***************/

resource "aws_lambda_permission" "allow_cloudwatch" {
  
  for_each      = {for idx, v in [
      aws_cloudwatch_event_rule.ec2-stop-event-rule,
      aws_cloudwatch_event_rule.ec2-start-event-rule
  ]: idx => v}
  
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2-stop-start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}


