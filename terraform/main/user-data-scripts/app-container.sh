#!/bin/bash
set -euo pipefail

AWS_REGION="${region}"
ECR_REPO_URL="${repo_url}"
SSM_PREFIX="${ssm_prefix}"
DATABASE_URL="${database_url}"
CORS_ORIGIN="${cors_origin}"

yum update -y

if ! command -v docker >/dev/null 2>&1; then
  yum install -y docker
fi

if ! command -v aws >/dev/null 2>&1; then
  yum install -y awscli
fi

systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user || true

IMAGE_TAG=$(aws ssm get-parameter --name "$SSM_PREFIX/backend/image_tag" --region "$AWS_REGION" --query "Parameter.Value" --output text)
IMAGE_TAG=$(echo "$IMAGE_TAG" | tr -d '\r' | xargs)
ECR_REPO_URL=$(echo "$ECR_REPO_URL" | tr -d '\r' | xargs)
ECR_REGISTRY=$(echo "$ECR_REPO_URL" | cut -d'/' -f1)

if [ -z "$IMAGE_TAG" ] || [ -z "$ECR_REPO_URL" ]; then
  echo "Missing image tag or ECR repo URL" >&2
  exit 1
fi

if [[ "$ECR_REPO_URL" == http* ]]; then
  echo "ECR_REPO_URL must not include a scheme (expected 123456789012.dkr.ecr.region.amazonaws.com/repo)" >&2
  exit 1
fi

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "Using image: $ECR_REPO_URL:$IMAGE_TAG"
docker pull "$ECR_REPO_URL:$IMAGE_TAG"

token=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
if [ -n "$token" ]; then
  INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token:$token" http://169.254.169.254/latest/meta-data/instance-id || true)
  PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token:$token" http://169.254.169.254/latest/meta-data/local-ipv4 || true)
  AZ=$(curl -s -H "X-aws-ec2-metadata-token:$token" http://169.254.169.254/latest/meta-data/placement/availability-zone || true)
else
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || true)
  PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || true)
  AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone || true)
fi

docker rm -f backend || true

docker run -d \
  --name backend \
  --restart unless-stopped \
  -p 80:3001 \
  -e NODE_ENV=production \
  -e PORT=3001 \
  -e DATABASE_URL="$DATABASE_URL" \
  -e CORS_ORIGIN="$CORS_ORIGIN" \
  -e INSTANCE_ID="$INSTANCE_ID" \
  -e INSTANCE_PRIVATE_IP="$PRIVATE_IP" \
  -e INSTANCE_AZ="$AZ" \
  "$ECR_REPO_URL:$IMAGE_TAG"
