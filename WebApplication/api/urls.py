from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'), 
    path('storage/', views.storage, name='storage'),
    path('notifications/', views.notifications, name='notifications'),
    path('live-stream/', views.livestream, name='live_stream'),
    path('live-stream/<str:session_id>', views.livestreaming, name='live_streaming'),
    path('surveillance/', views.surveillance, name='surveillance'),
    path('surveillance/<str:session_id>', views.surveillancing, name='surveillancing'),
    path('create-session/', views.create_session, name='create_session'),
    path('find-session-by-otp/', views.find_session_by_otp, name='find_session_by_otp'),
    path('terminate-session/<str:session_id>/', views.terminate_session, name='terminate_session'),
    path('process_video/', views.process_video, name='process_video'),

]
 