resource "aws_apigatewayv2_api" "this" {
  for_each = local.api_gw_enabled

  name          = local.courier_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "this" {
  for_each = local.api_gw_enabled

  api_id    = aws_apigatewayv2_api.this[each.key].id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}

resource "aws_lambda_permission" "this" {
  for_each = local.api_gw_enabled

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.courier.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this[each.key].execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "this" {
  for_each = local.api_gw_enabled

  api_id           = aws_apigatewayv2_api.this[each.key].id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda example"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.courier.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_stage" "this" {
  for_each = local.api_gw_enabled

  api_id      = aws_apigatewayv2_api.this[each.key].id
  auto_deploy = true
  name        = "prod"
}
