#!/bin/bash

# create-argocd-user.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 <username> <password> [permissions]"
    echo "Example: $0 john password123 'apiKey, login, get'"
    echo "Default permissions: 'apiKey, login'"
    exit 1
fi

USERNAME=$1
PASSWORD=$2
PERMISSIONS=${3:-"apiKey, login"}

echo "Creating ArgoCD user: $USERNAME"

# 1. 添加用户到 ConfigMap
echo "Step 1: Adding user to ConfigMap..."
kubectl patch configmap argocd-cm -n argocd --type='merge' -p="{\"data\":{\"accounts.$USERNAME\":\"$PERMISSIONS\"}}"

if [ $? -eq 0 ]; then
    echo "✅ User $USERNAME added to ConfigMap"
else
    echo "❌ Failed to add user to ConfigMap"
    exit 1
fi

# 2. 等待配置生效
echo "Step 2: Waiting for configuration to reload..."
sleep 5

# 3. 设置用户密码
echo "Step 3: Setting password for $USERNAME..."
argocd account update-password --account $USERNAME --current-password $PASSWORD --new-password $PASSWORD

if [ $? -eq 0 ]; then
    echo "✅ Password set for user $USERNAME"
    echo ""
    echo "🎉 User created successfully!"
    echo "Username: $USERNAME"
    echo "Password: $PASSWORD"
    echo "Permissions: $PERMISSIONS"
else
    echo "❌ Failed to set password"
fi
