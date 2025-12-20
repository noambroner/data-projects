#!/bin/bash
#
# Script to register OIDI in SAM
# Run this after SAM backend is available
#

echo "🎓 Registering OIDI in SAM..."
echo ""

# Method 1: Via API (requires backend to be running)
echo "Attempting API registration..."
RESPONSE=$(curl -s -X POST https://sam.ovu.co.il/api/v1/applications \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OIDI",
    "display_name": "OVU Initial Development Instructor",
    "code": "OIDI",
    "description": "Complete documentation and guide for OVU development. AI-friendly resource for developers and AI tools.",
    "purpose": "Provide comprehensive documentation, examples, and guidance for developing applications in the OVU ecosystem",
    "type": "tool",
    "status": "active",
    "category": "Documentation",
    "version": "1.0.0",
    "frontend_url": "https://oidi.ovu.co.il",
    "backend_url": "https://oidi.ovu.co.il/api",
    "docs_url": "https://oidi.ovu.co.il",
    "github_url": "https://github.com/noambroner/ovu-oidi",
    "icon": "🎓",
    "color": "#3B82F6",
    "tags": ["documentation", "guide", "tutorial", "ai-friendly", "developer-tools"],
    "tech_stack": {
      "frontend": ["Next.js 16", "React 19", "TypeScript", "Tailwind CSS"],
      "backend": ["Next.js API Routes"],
      "database": [],
      "cache": []
    }
  }')

if echo "$RESPONSE" | grep -q '"id"'; then
    echo "✅ OIDI registered successfully via API!"
    echo "$RESPONSE" | python3 -m json.tool
else
    echo "⚠️  API registration failed. Response:"
    echo "$RESPONSE"
    echo ""
    echo "📝 Alternative: Add directly to database"
    echo "   SSH to backend server (64.176.171.223)"
    echo "   Run the Python script below:"
    echo ""
    cat << 'EOFPYTHON'
# /tmp/add_oidi.py
import asyncio
import sys
sys.path.insert(0, '/home/ploi/ovu-sam/backend')

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select
from datetime import datetime
from app.db.models import Application

DATABASE_URL = 'postgresql+asyncpg://ovu_user:OvuDbUser2025Secure!Pass@64.177.67.215/sam_db'

async def add_oidi():
    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        result = await session.execute(select(Application).where(Application.code == 'OIDI'))
        if result.scalar_one_or_none():
            print('⚠️  OIDI already exists')
            return

        oidi = Application(
            name='OIDI',
            display_name='OVU Initial Development Instructor',
            code='OIDI',
            description='Complete documentation and guide for OVU development. AI-friendly resource for developers and AI tools.',
            purpose='Provide comprehensive documentation, examples, and guidance for developing applications in the OVU ecosystem',
            type='tool',
            status='active',
            category='Documentation',
            version='1.0.0',
            frontend_url='https://oidi.ovu.co.il',
            backend_url='https://oidi.ovu.co.il/api',
            docs_url='https://oidi.ovu.co.il',
            github_url='https://github.com/noambroner/ovu-oidi',
            icon='🎓',
            color='#3B82F6',
            tags=['documentation', 'guide', 'tutorial', 'ai-friendly', 'developer-tools'],
            tech_stack={
                'frontend': ['Next.js 16', 'React 19', 'TypeScript', 'Tailwind CSS'],
                'backend': ['Next.js API Routes'],
                'database': [],
                'cache': []
            },
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )

        session.add(oidi)
        await session.commit()
        print('✅ OIDI added successfully!')

    await engine.dispose()

asyncio.run(add_oidi())
EOFPYTHON
fi

