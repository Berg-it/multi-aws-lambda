
locals {
  lambda_config = jsondecode(file("${path.module}/lambda-template.json"))
}

resource "aws_lambda_function" "test_lambda" {
  for_each = local.lambda_config
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = each.value.filename
  function_name = each.key
  role          = replace(replace("arn:aws:iam::account:role/role-name-with-path", "account", data.aws_caller_identity.current.account_id), "role-name-with-path", each.value.role)
  handler       = each.value.handler

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(each.value.filename)

  runtime     = each.value.runtime
  memory_size = each.value.memory_size
  dynamic "environment" {
    for_each = each.value.set_env == 1 ? [1] : []
    content {
      variables = each.value.environment
    }
  }
  tags = {
    Name = index(keys(local.lambda_config), each.key)
  }
}


##Gives an external source (like an EventBridge Rule, SNS, or S3) permission to access the Lambda function.
resource "aws_lambda_permission" "allow_bucket" {

  for_each = {
    for key, value in local.lambda_config : key => value
    if value.trigger_source.trigger == true
  }
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = each.value.trigger_source.principal
  source_arn    = replace("arn:aws:s3:::bucket_name", "bucket_name", each.value.trigger_source.partial_source_arn) #TO Update
}


resource "aws_s3_bucket_notification" "bucket_notification" {

  for_each = {
    for key, value in local.lambda_config : key => value
    if value.trigger_source.trigger == true
  }

  bucket = each.value.trigger_source.partial_source_arn

  lambda_function {
    lambda_function_arn = replace(replace(replace("arn:aws:lambda:REGION:ACCOUNT_ID:function:FUNCTION_NAME", "ACCOUNT_ID", data.aws_caller_identity.current.account_id), "REGION", data.aws_region.current.name), "FUNCTION_NAME", each.key)
    events              = each.value.trigger_source.events
  }
}