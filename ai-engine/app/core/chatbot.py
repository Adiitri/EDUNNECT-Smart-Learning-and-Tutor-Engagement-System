import google.generativeai as genai
import os

# Configure API Key (You will need a Gemini API Key later)
def get_ai_response(question, history=[]):
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        return "Error: AI API Key is missing."

    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-flash-latest')
        response = model.generate_content(question)
        return response.text
    except Exception as e:
        return f"AI Error: {str(e)}"