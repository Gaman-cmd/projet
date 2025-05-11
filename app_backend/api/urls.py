from .views import (
    UtilisateurLoginView, InscriptionViewSet, PresenceViewSet, SeanceViewSet,
    FormationViewSet, ParticipantViewSet, InscriptionView, ParticipantRegisterView, modifier_profil,
    notifications_participant, FormateurRegisterView
)
from django.urls import path, include
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'formations', FormationViewSet)
router.register(r'participants', ParticipantViewSet)
router.register(r'inscriptions', InscriptionViewSet)
router.register(r'presences', PresenceViewSet)
router.register(r'seances', SeanceViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('login/', UtilisateurLoginView.as_view(), name='login'),
    path('inscription/', InscriptionView.as_view(), name='inscription'),  # endpoint POST inscription simple
    path('register/', ParticipantRegisterView.as_view(), name='participant-register'),
    path('modifier_profil/<int:pk>/', modifier_profil, name='modifier-profil'),
    path('notifications/<int:participant_id>/', notifications_participant, name='notifications-participant'),
    path('register_formateur/', FormateurRegisterView.as_view(), name='formateur-register'),
]