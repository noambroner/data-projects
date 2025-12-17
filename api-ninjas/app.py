from flask import Flask, render_template, request, jsonify
import requests
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False  # תמיכה בעברית ב-JSON

# קבלת API Key מ-environment variable
API_KEY = os.getenv('API_NINJAS_KEY', '')

@app.route('/')
def index():
    """דף הבית עם טופס חישוב מס מכירה"""
    api_key_preview = f"...{API_KEY[-5:]}" if API_KEY and len(API_KEY) >= 5 else None
    return render_template('index.html', api_key_exists=bool(API_KEY), api_key_preview=api_key_preview)

@app.route('/api-key-setup')
def api_key_setup():
    """דף הזנת API Key"""
    api_key_preview = f"...{API_KEY[-5:]}" if API_KEY and len(API_KEY) >= 5 else None
    return render_template('setup.html', api_key_exists=bool(API_KEY), api_key_preview=api_key_preview)

@app.route('/save-api-key', methods=['POST'])
def save_api_key():
    """שמירת API Key בקובץ .env"""
    try:
        data = request.get_json()
        api_key = data.get('api_key', '').strip()
        
        if not api_key:
            return jsonify({
                'success': False,
                'error': 'נא להזין API Key'
            }), 400
        
        # שמירה בקובץ .env
        env_path = os.path.join(os.path.dirname(__file__), '.env')
        with open(env_path, 'w') as f:
            f.write(f'API_NINJAS_KEY={api_key}\n')
        
        return jsonify({
            'success': True,
            'message': 'API Key נשמר בהצלחה! יש לרענן את הדף.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'שגיאה בשמירה: {str(e)}'
        }), 500

@app.route('/calculate-sales-tax', methods=['POST'])
def calculate_sales_tax():
    """חישוב מס מכירה באמצעות API Ninjas"""
    try:
        # קבלת נתונים מהטופס
        data = request.get_json()
        print(f"Received data: {data}")
        zip_code = data.get('zip_code', '').strip()
        amount = float(data.get('amount', 0))
        print(f"zip_code: {zip_code}, amount: {amount}")
        
        # בדיקת תקינות
        if not API_KEY:
            return jsonify({
                'success': False,
                'error': 'חסר API Key. אנא הגדר את המשתנה API_NINJAS_KEY'
            }), 400
            
        if not zip_code or amount <= 0:
            return jsonify({
                'success': False,
                'error': 'נא למלא את כל השדות הנדרשים'
            }), 400
        
        # קריאה ל-Sales Tax Calculator API
        api_url = 'https://api.api-ninjas.com/v1/salestaxcalculator'
        params = {
            'zip_code': zip_code,
            'amount': amount
        }
        
        headers = {
            'X-Api-Key': API_KEY
        }
        
        response = requests.get(api_url, params=params, headers=headers)
        
        if response.status_code == 200:
            result = response.json()
            
            # הדפסת התוצאה המלאה לדיבוג
            print("=" * 50)
            print("API Response:")
            print(result)
            print("=" * 50)
            
            # בדיקה אם קיבלנו מידע
            if not result or len(result) == 0:
                return jsonify({
                    'success': False,
                    'error': 'לא נמצא מידע עבור מיקוד זה'
                }), 404
            
            tax_data = result[0] if isinstance(result, list) else result
            
            # הדפסת המידע שקיבלנו
            print("Tax Data Keys:", tax_data.keys())
            for key, value in tax_data.items():
                print(f"  {key}: {value} (type: {type(value).__name__})")
            print("=" * 50)
            
            # נסה להמיר ל-float בזהירות
            def safe_float(value, default=0.0):
                try:
                    if isinstance(value, str) and 'premium' in value.lower():
                        return None  # ערך premium
                    return float(value)
                except (ValueError, TypeError):
                    return default
            
            # קבלת הנתונים
            state_rate = safe_float(tax_data.get('state_rate'))
            state_tax = safe_float(tax_data.get('state_tax'))
            city_rate = safe_float(tax_data.get('city_rate'))
            city_tax = safe_float(tax_data.get('city_tax'))
            county_rate = safe_float(tax_data.get('county_rate'))
            county_tax = safe_float(tax_data.get('county_tax'))
            total_rate = safe_float(tax_data.get('total_rate'))
            total_tax = safe_float(tax_data.get('total_tax'))
            total_price = safe_float(tax_data.get('total_price'))
            
            # הכנת התוצאות - רק עם מה שקיבלנו
            formatted_result = {
                'zip_code': tax_data.get('zip_code', zip_code),
                'amount': f"${amount:,.2f}",
            }
            
            # הוסף רק שדות שקיימים (לא premium)
            if state_rate is not None:
                formatted_result['state_rate'] = f"{state_rate * 100:.3f}%"
            if state_tax is not None:
                formatted_result['state_tax'] = f"${state_tax:,.2f}"
            
            if city_rate is not None:
                formatted_result['city_rate'] = f"{city_rate * 100:.3f}%"
            if city_tax is not None:
                formatted_result['city_tax'] = f"${city_tax:,.2f}"
                
            if county_rate is not None:
                formatted_result['county_rate'] = f"{county_rate * 100:.3f}%"
            if county_tax is not None:
                formatted_result['county_tax'] = f"${county_tax:,.2f}"
                
            if total_rate is not None:
                formatted_result['total_rate'] = f"{total_rate * 100:.3f}%"
            if total_tax is not None:
                formatted_result['total_tax'] = f"${total_tax:,.2f}"
            if total_price is not None:
                formatted_result['total_amount'] = f"${total_price:,.2f}"
            elif state_tax is not None:
                # אם אין total_price, נחשב רק עם state tax
                formatted_result['total_amount'] = f"${(amount + state_tax):,.2f}"
            
            return jsonify({
                'success': True,
                'data': formatted_result
            })
        else:
            return jsonify({
                'success': False,
                'error': f'שגיאה בקריאה ל-API: {response.status_code}'
            }), response.status_code
            
    except ValueError as e:
        print(f"ValueError: {str(e)}")
        return jsonify({
            'success': False,
            'error': 'נא להזין סכום תקין'
        }), 400
    except Exception as e:
        print(f"Exception occurred: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'success': False,
            'error': f'שגיאה: {str(e)}'
        }), 500

if __name__ == '__main__':
    if not API_KEY:
        print('⚠️  אזהרה: לא נמצא API Key!')
        print('📝 אנא צור קובץ .env והוסף: API_NINJAS_KEY=your_api_key_here')
    else:
        print('✅ API Key נטען בהצלחה')
    
    app.run(debug=True, host='0.0.0.0', port=5000)
