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

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)
        print(f"Disconnected from session: {self.session_id}")  

    async def receive(self, text_data):
        # Handle incoming signaling messages (offer, answer, ICE candidates)
        # only for printing whether offer,ans or ice candidate
        text_data_json = json.loads(text_data)
        message_type = text_data_json.get('type') 

        # Forward the message to other peers in the session
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'forward.message',
                'message': text_data,
            }
        )

    async def forward_message(self, event):
        # Send the signaling message to the WebSocket
        message = event['message']
        await self.send(text_data=message)