from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('card.urls')), 
    path('log/', include('user.urls')), 
    path('services/', include('service.urls')), 
    path('products/', include('products.urls')), 
    path('utils/', include('utils.urls')), 
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)