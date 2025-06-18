#urls.py
from .views import (
    ParticipantPresencesView, UtilisateurLoginView, InscriptionViewSet, PresenceViewSet, SeanceViewSet,
    FormationViewSet, ParticipantViewSet, InscriptionView, ParticipantRegisterView, marquer_presence_par_qr, modifier_profil,
    notifications_participant, FormateurRegisterView, upload_image, list_formateurs, get_recent_activities
)
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from django.conf import settings
from django.conf.urls.static import static

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
    path('upload-image/', upload_image, name='upload-image'),  # Ajoute cette ligne
    path('formateurs/', list_formateurs, name='list_formateurs'),  # Ajoute cette ligne
    path('activities/recent/', get_recent_activities, name='recent-activities'),  # Ajoute cette ligne
    path('presences/marquer_par_qr/', marquer_presence_par_qr, name='presence-par-qr'),
    path('presences/participant/', ParticipantPresencesView.as_view(), name='participant-presences'),

]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)