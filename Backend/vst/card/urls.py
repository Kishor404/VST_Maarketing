from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CardViewSet, ServiceEntryViewSet, CardListView, 
    CardCreateByHead, CardUpdateByHead, CardListByHead,
    ServiceEntryCreateByHeadAndWorker, ServiceEntryUpdateByHeadAndWorker,
    ServiceEntryCustomerSignatureUpdate, CardListByHeadByID
)

# Create a router and register the viewsets
router = DefaultRouter()
router.register(r'cards', CardViewSet, basename='cardDetails')
router.register(r'cards-details', CardListView, basename='card')
router.register(r'service-entries', ServiceEntryViewSet, basename='serviceentry')

# Include the router URLs
urlpatterns = [
    path('', include(router.urls)),
    
    # Card-related URLs
    path('headcreatecard/', CardCreateByHead.as_view(), name='head-create-card'),
    path('headeditcard/<int:id>/', CardUpdateByHead.as_view(), name='edit-card-by-head'),
    path('headcardlist/', CardListByHead.as_view(), name='list-card-by-head'),
    path('headcardgetid/<int:id>/', CardListByHeadByID.as_view(), name='list-card-by-head-id'),

    # ServiceEntry-related URLs
    path('createserviceentry/', ServiceEntryCreateByHeadAndWorker.as_view(), name='create-service-entry'),
    path('editserviceentry/<int:id>/', ServiceEntryUpdateByHeadAndWorker.as_view(), name='edit-service-entry'),
    path('signbycustomer/<int:id>/', ServiceEntryCustomerSignatureUpdate.as_view(), name='customer-sign-service-entry'),
]
