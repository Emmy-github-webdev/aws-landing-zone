variable "aws_region" {
  description = "AWS Organisation home region for Control Tower"
  type        = string
  default     = "us-east-1"

}
variable "control_tower_version" {
  description = "AWS Control Tower version"
  type        = string
  default     = "4.0"
}