from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/live-stream/(?P<session_id>\w+)/$', consumers.VideoStreamConsumer.as_asgi()),
    re_path(r'ws/surveillance/(?P<session_id>\w+)/$', consumers.VideoStreamConsumer.as_asgi()),
]
