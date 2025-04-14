from .views import UtilisateurLoginView
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import FormationViewSet
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

router = DefaultRouter()
router.register(r'formations', FormationViewSet)

urlpatterns = [
    
    path('', include(router.urls)),
    path('login/', UtilisateurLoginView.as_view(), name='login'),
    #path('api/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    #path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]