output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}


output "aws_iam_role_policy_attachment" {
  value = aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
}
