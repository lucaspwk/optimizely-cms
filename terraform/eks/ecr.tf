# Create ECR repository
resource "aws_ecr_repository" "my_repository" {
  name = "my-optimizely-cms"
}