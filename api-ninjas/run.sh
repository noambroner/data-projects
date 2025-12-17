#!/bin/bash

# סקריפט הפעלה מהיר למחשבון מס הכנסה

echo "🧮 מפעיל את מחשבון מס הכנסה..."
echo ""

# בדיקה אם קיים קובץ .env
if [ ! -f .env ]; then
    echo "⚠️  שגיאה: לא נמצא קובץ .env"
    echo ""
    echo "📝 כיצד ליצור קובץ .env:"
    echo "   1. העתק את env_example.txt ל-.env"
    echo "   2. ערוך את הקובץ והוסף את ה-API Key שלך"
    echo "   3. הרץ את הסקריפט שוב"
    echo ""
    echo "💡 קבל API Key חינם מ-https://api-ninjas.com"
    exit 1
fi

# בדיקה אם הסביבה הוירטואלית קיימת
if [ ! -d "venv" ]; then
    echo "📦 יוצר סביבה וירטואלית..."
    python3 -m venv venv
    echo "✅ סביבה וירטואלית נוצרה"
fi

# הפעלת הסביבה הוירטואלית
echo "🔧 מפעיל סביבה וירטואלית..."
source venv/bin/activate

# התקנת תלויות
echo "📚 מתקין תלויות..."
pip install -q -r requirements.txt

echo ""
echo "✅ הכל מוכן!"
echo "🚀 מפעיל שרת Flask..."
echo ""
echo "📱 גש לכתובת: http://localhost:5000"
echo ""
echo "🛑 לעצירת השרת: Ctrl+C"
echo ""

# הפעלת השרת
python app.py

