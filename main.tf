data "aws_caller_identity" "current" {}

locals {
  name_prefix = "jibintan" # split("/", "${data.aws_caller_identity.current.arn}")[1]
}
