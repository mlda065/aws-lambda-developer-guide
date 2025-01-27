#!/bin/bash
FUNCTION=$(aws cloudformation describe-stack-resource --stack-name blank --logical-resource-id function --query 'StackResourceDetail.PhysicalResourceId' --output text)

while true; do
  aws lambda invoke --function-name $FUNCTION --payload '{}' out
  sleep 2
done
