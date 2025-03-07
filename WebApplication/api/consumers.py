import json
from channels.generic.websocket import AsyncWebsocketConsumer

class VideoStreamConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Extract session ID from the WebSocket URL
        self.session_id = self.scope['url_route']['kwargs']['session_id']
        self.room_group_name = f"stream_{self.session_id}"

        # Add the WebSocket to the group for this session
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    # consumers.py
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message_type = text_data_json.get('type')

        # Forward the message to the group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                "type": "forward.message",
                "message": text_data,
            },
        )

    async def forward_message(self, event):
        # Send the signaling message to the WebSocket
        message = event['message']
        await self.send(text_data=message)

    
    async def disconnect(self, close_code):
        # Remove the WebSocket from the group
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)
        print(f"Disconnected from session: {self.session_id}")  

# routing.py (or consumers.py)
from django.urls import re_path


# websocket_urlpatterns = [
#     re_path(r"ws/surveillance/(?P<session_id>\w+)/$", VideoStreamConsumer.as_asgi()),
# ]
websocket_urlpatterns = [
    re_path(r'ws/surveillance/(?P<session_id>\w+)/$', VideoStreamConsumer.as_asgi()),
    re_path(r'ws/live-stream/(?P<session_id>\w+)/$', VideoStreamConsumer.as_asgi()),
]

