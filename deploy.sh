#!/bin/bash

set -e

# Stack names
VPC_STACK="vpc-stack"
IAM_STACK="iam-stack"
CLUSTER_STACK="eks-cluster"
NODEGROUP_STACK="eks-nodegroup"

echo "🔁 Deploying VPC stack..."
aws cloudformation deploy \
  --template-file cloudformation/vpc.yaml \
  --stack-name $VPC_STACK \
  --capabilities CAPABILITY_NAMED_IAM

echo "🔁 Deploying IAM roles stack..."
aws cloudformation deploy \
  --template-file cloudformation/iam-roles.yaml \
  --stack-name $IAM_STACK \
  --capabilities CAPABILITY_NAMED_IAM

echo "📦 Extracting outputs from VPC and IAM stacks..."
SUBNET1=$(aws cloudformation describe-stacks --stack-name $VPC_STACK \
  --query "Stacks[0].Outputs[?OutputKey=='Subnet1'].OutputValue | [0]" --output text)
SUBNET2=$(aws cloudformation describe-stacks --stack-name $VPC_STACK \
  --query "Stacks[0].Outputs[?OutputKey=='Subnet2'].OutputValue | [0]" --output text)
SG=$(aws cloudformation describe-stacks --stack-name $VPC_STACK \
  --query "Stacks[0].Outputs[?OutputKey=='SecurityGroupId'].OutputValue | [0]" --output text)
CLUSTER_ROLE=$(aws cloudformation describe-stacks --stack-name $IAM_STACK \
  --query "Stacks[0].Outputs[?OutputKey=='ClusterRoleArn'].OutputValue | [0]" --output text)
NODE_ROLE=$(aws cloudformation describe-stacks --stack-name $IAM_STACK \
  --query "Stacks[0].Outputs[?OutputKey=='NodeRoleArn'].OutputValue | [0]" --output text)

# Validate required values
if [[ -z "$SUBNET1" || -z "$SUBNET2" || -z "$SG" || -z "$CLUSTER_ROLE" || -z "$NODE_ROLE" ]]; then
  echo "❌ One or more required outputs are missing. Check your VPC and IAM stacks."
  exit 1
fi

echo "✅ All required outputs retrieved."

echo "🔁 Deploying EKS cluster stack..."
aws cloudformation deploy \
  --template-file cloudformation/eks-cluster.yaml \
  --stack-name $CLUSTER_STACK \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    Subnet1=$SUBNET1 \
    Subnet2=$SUBNET2 \
    SecurityGroupId=$SG \
    ClusterRoleArn=$CLUSTER_ROLE

echo "⏳ Waiting for EKS cluster to become ACTIVE..."
aws eks wait cluster-active --name StaticPortfolioCluster

# Handle ROLLBACK_COMPLETE for node group
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $NODEGROUP_STACK \
  --query "Stacks[0].StackStatus" --output text 2>/dev/null || echo "DELETE_ME")

if [[ "$STACK_STATUS" == "ROLLBACK_COMPLETE" ]]; then
  echo "⚠️ Node group stack is in ROLLBACK_COMPLETE. Deleting before redeploy..."
  aws cloudformation delete-stack --stack-name $NODEGROUP_STACK
  echo "⏳ Waiting for deletion..."
  aws cloudformation wait stack-delete-complete --stack-name $NODEGROUP_STACK
fi

echo "🚀 Deploying EKS node group stack..."
aws cloudformation deploy \
  --template-file cloudformation/eks-nodegroup.yaml \
  --stack-name $NODEGROUP_STACK \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    ClusterName=StaticPortfolioCluster \
    Subnet1=$SUBNET1 \
    Subnet2=$SUBNET2 \
    NodeRoleArn=$NODE_ROLE

echo "🎉 All stacks deployed successfully!"

