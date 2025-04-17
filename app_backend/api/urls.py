from .views import UtilisateurLoginView
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import FormationViewSet, ParticipantViewSet

router = DefaultRouter()
router.register(r'formations', FormationViewSet)
router.register(r'participants', ParticipantViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('login/', UtilisateurLoginView.as_view(), name='login'),
]