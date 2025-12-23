#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Deploy OIDI Updates to Production
# ═══════════════════════════════════════════════════════════
#
# This script updates OIDI on the production frontend server
# Run this after pushing updates to GitHub
#

set -e

SERVER_IP="64.176.173.105"
SERVER_USER="ploi"
PROJECT_PATH="/home/ploi/ovu-oidi"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║   🚀 Deploying OIDI Updates to Production               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

echo "📡 Connecting to Frontend Server: $SERVER_IP"
echo "👤 User: $SERVER_USER"
echo "📁 Path: $PROJECT_PATH"
echo ""

# Connect to server and run deployment commands
ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
    set -e

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📥 Step 1: Pulling latest code from GitHub..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd /home/ploi/ovu-oidi
    git pull origin master
    echo "✅ Code updated"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Step 2: Installing dependencies..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    npm install
    echo "✅ Dependencies installed"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔨 Step 3: Building application..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    npm run build
    echo "✅ Build completed"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "♻️  Step 4: Restarting OIDI service..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sudo systemctl restart oidi
    echo "✅ Service restarted"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Step 5: Checking service status..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sudo systemctl status oidi --no-pager -l
    echo ""

    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   ✅ OIDI DEPLOYMENT SUCCESSFUL!                         ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "🌐 URL: https://oidi.ovu.co.il"
    echo "📝 Check deployment page: https://oidi.ovu.co.il/deployment"
    echo ""
ENDSSH

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Visit https://oidi.ovu.co.il to verify"
echo "   2. Test new deployment guide: https://oidi.ovu.co.il/deployment"
echo "   3. Verify SAM integration examples: https://oidi.ovu.co.il/sam"
echo ""

