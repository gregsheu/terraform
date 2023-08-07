#If there are vpc endpoints, add permissions for aws managed workernodes or will fail to join.
provider "aws" {
  region = "us-east-2"
}
