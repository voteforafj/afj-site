#!/bin/bash
cd "$(dirname "$0")"
echo "📦 Staging changes..."
git add -A
echo "✅ Committing..."
git commit -m "Fix logo filename and nav sizing"
echo "🚀 Pushing to GitHub..."
git push
echo ""
echo "✅ Done! Vercel will deploy in ~30 seconds."
echo "Press any key to close..."
read -n 1
