import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()

# 1. Setup the key
api_key = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=api_key)

print(f"Testing Key: {api_key[:10]}...")

try:
    # 2. Ask Google: "What models can I use?"
    print("Attempting to list models...")
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            print(f" FOUND MODEL: {m.name}")
except Exception as e:
    print(f" ERROR: {e}")