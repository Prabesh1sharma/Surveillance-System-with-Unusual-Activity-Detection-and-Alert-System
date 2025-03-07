from django.urls import path
from . import views

urlpatterns = [
    path('create-session/', views.create_session, name='create_session'),  
    path('find-session/', views.find_session_by_otp, name='find_session_by_otp'), 
    path('active-sessions/', views.list_active_sessions, name='list_active_sessions'),  
    path('terminate-session/<str:session_id>/', views.terminate_session, name='terminate_session'), 
    path('process-video/', views.process_video, name='process_video'), 
]