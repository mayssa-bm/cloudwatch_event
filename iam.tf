/*** set up iam role ***/
/* when the function is triggered lambda should assume this role */

resource "aws_iam_role" "lambda-role" {
    name = "ec2-stop-start-role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
    tags = {
    Name = "lambda-ec2-role"
    }
    }

/*** iam policy ***/
resource "aws_iam_policy" "lambda-policy" {
  name = "ec2-stop-start-policy"

  policy = jsonencode({
    Version = "2012-10-17"
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    }
  ]
  })
}


/*integrate policy with a role */

resource "aws_iam_role_policy_attachment" "lambda-ec2-policy-attach" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
  
}