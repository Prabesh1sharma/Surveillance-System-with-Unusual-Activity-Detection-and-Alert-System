"""
ASGI config for project2 project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os
from django.core.asgi import get_asgi_application
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from api import routing
import api.consumers

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project2.settings')

# application = ProtocolTypeRouter({
#     "http": get_asgi_application(),
#     "websocket": AuthMiddlewareStack(
#         URLRouter(
#             routing.websocket_urlpatterns  
#         )
#     ),
# }) 
# project/asgi.py
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
import api.consumers  # Replace with your app's routing module

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": URLRouter(api.consumers.websocket_urlpatterns),
})