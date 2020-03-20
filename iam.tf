resource "aws_iam_policy" "jenkins_policy" {
  name        = "${var.stack_name}-jenkins-policy"
  path        = "/serviceRole/"
  description = "Policy for Jenkins services."
  policy      = templatefile("${path.module}/jenkins-access-policy.tpl",
                             { instance_arn = aws_instance.jenkins_01.arn,
                               region = var.region })
}

resource "aws_iam_role" "jenkins_role" {
  name = "${var.stack_name}-jenkins-role"
  path = "/serviceRole/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${var.stack_name}-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "jenkins_role_jenkins_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

resource "aws_iam_role_policy_attachment" "jenkins_role_ssm_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}