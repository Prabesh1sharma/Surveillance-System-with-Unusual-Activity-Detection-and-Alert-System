# api/views.py 
from django.shortcuts import render
from django.urls import reverse
from django.http import JsonResponse, HttpResponseRedirect
from django.utils.crypto import get_random_string
import json, redis

# Connect to Redis
redis_client = redis.StrictRedis(host='localhost', port=6379, db=0, decode_responses=True)

# View for rendering the home page with the options for live stream and surveillance
def home(request):
    return render(request, 'api/index.html')

# View for rendering the storage page
def storage(request):
    return render(request, 'api/storage.html')

# View for rendering the notifications page
def notifications(request):
    return render(request, 'api/notifications.html')

def livestream(request):
    return render(request, 'api/livestream.html')

def livestreaming(request, session_id):
    for key in redis_client.scan_iter("otp:*"):
        if redis_client.get(key) == session_id:
            otp_key = key
            break
    otp = otp_key.split(':')[-1]
    return render(request, 'api/livestreaming.html',{'session_id': session_id, 'otp': otp})

def surveillance(request):
    return render(request, 'api/surveillance.html')
 
def surveillancing(request, session_id):
    return render(request, 'api/surveillancing.html', {'session_id': session_id}) 

def create_session(request):
    # Generate a unique session ID
    session_id = get_random_string(16)  # Example: 'abcd1234xyz'

    # Generate a random OTP
    otp = get_random_string(6, allowed_chars='0123456789')  # Example: '482317'

    # Store the OTP as the key and the session ID as the value in Redis
    redis_client.set(f"otp:{otp}", session_id)  # No expiry since it should last as long as the session
    url = reverse("live_streaming", args=[session_id])
    return HttpResponseRedirect(url)
 
def find_session_by_otp(request):
    if request.method == 'POST':
        # Get the OTP from the user
        otp = request.POST.get('otpInput')

        # Look up the session ID using the OTP in Redis
        session_id = redis_client.get(f"otp:{otp}")

        if session_id is None:
            return JsonResponse({"error": "Invalid or Expired OTP"}, status=404)

        url = reverse("surveillancing", args=[session_id])
        return HttpResponseRedirect(url)

    # # If GET request, render the form
    # return render(request, 'api/surveillance.html')

def terminate_session(request, session_id):
        # Find the OTP associated with the session (reverse lookup)
        for key in redis_client.scan_iter("otp:*"):
            if redis_client.get(key) == session_id:
                otp_key = key
                break
        else:
            return JsonResponse({"error": "Session not found"}, status=404)

        # Delete both the session and OTP keys from Redis
        redis_client.delete(f"otp:{otp_key.split(':')[-1]}")
        
        url = reverse("home")
        return HttpResponseRedirect(url)

import requests
from django.conf import settings
import tempfile
import os
import torch
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from transformers import pipeline
import cv2
from PIL import Image
import numpy as np
import logging
from collections import defaultdict
from dotenv import load_dotenv
load_dotenv()

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize model
try:
    pipe = pipeline('image-classification', model="/Users/prabeshsharma/Documents/django/testmyproject/crime_cctv_model", device="cpu")
    # pipe = pipeline('image-classification', model="D:\\major_project\\test\\test project\\project2\\crime_cctv_model", device="cpu")
except Exception as e:
    logger.error(f"Error loading model: {str(e)}")
    raise

def process_frames(frames, threshold=0.5):
    """
    Process a batch of frames for crime detection.
    """
    results = []
    
    for idx, frame in enumerate(frames):
        try:
            pil_image = Image.fromarray(frame)
            predictions = pipe(pil_image)
            crime_score = [res['score'] for res in predictions if res['label']=='Crime'][0]
            
            if crime_score > threshold:
                results.append({
                    'frame_number': idx,
                    'crime_score': float(crime_score)
                })
                
        except Exception as e:
            logger.error(f"Error processing frame {idx}: {str(e)}")
            
    return results

# Add this helper function
def send_telegram_alert(image_path):
    """
    Send an image alert via Telegram.
    """
    bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    api_url = f"https://api.telegram.org/bot{bot_token}/sendPhoto"
    
    try:
        with open(image_path, 'rb') as photo:
            files = {'photo': photo}
            data = {'chat_id': chat_id, 'caption': 'Something unusual is happening, please check it!'}
            response = requests.post(api_url, files=files, data=data)
            response.raise_for_status()
    except Exception as e:
        logger.error(f"Telegram API Error: {str(e)}")

# Modify the process_video view
@csrf_exempt
def process_video(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Only POST requests are allowed'}, status=405)
    
    try:
        video_file = request.FILES.get('video')
        if not video_file:
            return JsonResponse({'error': 'No video file received'}, status=400)
        
        # Save the uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix='.webm') as tmp_file:
            for chunk in video_file.chunks():
                tmp_file.write(chunk)
            tmp_file_path = tmp_file.name
        
        try:
            # Read and process video
            cap = cv2.VideoCapture(tmp_file_path)
            if not cap.isOpened():
                raise ValueError("Error opening video file")
            
            frames = []
            sample_rate = 4  # Process every 4th frame
            frame_count = 0
            
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                    
                if frame_count % sample_rate == 0:
                    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                    frames.append(frame_rgb)
                frame_count += 1
                
            cap.release()
            
            # Process collected frames
            results = process_frames(frames)
            
            # Initialize response structure
            response_data = {
                'status': 'normal',
                'predictions': [
                    {"label": "Abnormal", "score": 0.0},
                    {"label": "Normal", "score": 1.0}
                ],
                'highest_frame': None,
                'details': []
            }

            if results:
                # Find highest risk frame
                max_risk_frame = max(results, key=lambda x: x['crime_score'])
                
                # Count frames over threshold
                abnormal_count = sum(1 for res in results if res['crime_score'] > 0.8)
                
                # Determine status
                if abnormal_count >= 2:
                    response_data['status'] = 'abnormal'
                    # Update predictions for abnormal case
                    response_data['predictions'] = [
                        {"label": "Abnormal", "score": max_risk_frame['crime_score']},
                        {"label": "Normal", "score": 1 - max_risk_frame['crime_score']}
                    ]
                else:
                    # For normal case, set Normal score to 1 and Abnormal to 0
                    response_data['predictions'] = [
                        {"label": "Abnormal", "score": 0.0},
                        {"label": "Normal", "score": 1.0}
                    ]

                # Add frame details
                response_data['highest_frame'] = {
                    'frame_number': max_risk_frame['frame_number'],
                    'crime_score': float(max_risk_frame['crime_score'])
                }
                response_data['details'] = results

                # Send Telegram alert if abnormal
                if response_data['status'] == 'abnormal':
                    try:
                        alert_frame = frames[max_risk_frame['frame_number']]
                        pil_image = Image.fromarray(alert_frame)
                        
                        # Save to temp file
                        with tempfile.NamedTemporaryFile(suffix='.jpg', delete=False) as tmp_img:
                            tmp_path = tmp_img.name
                            pil_image.save(tmp_img, format='JPEG')
                        
                        # Send alert
                        send_telegram_alert(tmp_path)
                    except Exception as e:
                        logger.error(f"Error sending alert: {str(e)}")
                    finally:
                        if os.path.exists(tmp_path):
                            os.remove(tmp_path)

            logger.info(f"Generated response: {response_data}")
            return JsonResponse(response_data)
            
        finally:
            # Clean up the temporary video file
            if os.path.exists(tmp_file_path):
                os.remove(tmp_file_path)
                
    except Exception as e:
        logger.error(f"Error processing video: {str(e)}")
        return JsonResponse({
            'error': str(e),
            'status': 'error'
        }, status=500)