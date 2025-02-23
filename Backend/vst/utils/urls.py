from django.urls import path
from .views import (
    CheckAvailabilityView,
    NextServiceView, 
    UpcomingServiceView, 
    CurrentServiceView, 
    CompletedServiceView,
    GetUserByID,
    GetStaffByID,
    RoleCountView,
    HeadEdit,
    AssignAvailableStaffView,
    EditReqView,
    GetAllUsersByRoleAndRegion,
    EditUsersByHeadAndAdmin,
    RejectEditReq,
    UnavailableReqView,
    RejectUnavaReq
    )

urlpatterns = [
    # User authentication endpoints
    path('checkstaffavailability/', CheckAvailabilityView.as_view(), name='checker'),
    path('next-service/', NextServiceView.as_view(), name='next-service-info'),
    path('upcomingservice/', UpcomingServiceView.as_view(), name='upcoming-service-info'),
    path('currentservice/', CurrentServiceView.as_view(), name='current-service-info'),
    path('completedservice/', CompletedServiceView.as_view(), name='completed-service-info'),
    path('getuserbyid/<int:id>', GetUserByID.as_view(), name='get-user-by-id'),
    path('getstaffbyid/<int:id>', GetStaffByID.as_view(), name='get-satff-by-id'),
    path('getalluser/', GetAllUsersByRoleAndRegion.as_view(), name='get-all-user-by-head-admin'),
    path('edituserxxx/', EditUsersByHeadAndAdmin.as_view(), name='edit-user-by-head-admin'),
    path('headeditreq/<int:id>', HeadEdit.as_view(), name='head-edit-by-id'),
    path('headrejectunavareq/<int:id>', RejectUnavaReq.as_view(), name='reject-unava-by-id'),
    path('headrejecteditreq/<int:id>', RejectEditReq.as_view(), name='reject-edit-by-id'),
    path('headvieweditreq/', EditReqView.as_view(), name='view-edit-by-head'),
    path('headviewunavareq/', UnavailableReqView.as_view(), name='view-unava-by-head'),
    path('role-count/', RoleCountView.as_view(), name='role-count'),
    path('reassingstaff/<int:id>', AssignAvailableStaffView.as_view(), name='reassign-staff'),
]
