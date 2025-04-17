from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from .models import Formation, Participant
from django.utils import timezone
from .serializers import FormationSerializer, ParticipantSerializer
import jwt
from django.conf import settings
from datetime import datetime, timedelta
import uuid

from django.contrib.auth.models import User


class UtilisateurLoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        if not email or not password:
            return Response({"error": "Email et mot de passe sont requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
            if user.check_password(password):
                # Supprimer la génération de token
                return Response({"message": "Authentification réussie"}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Mot de passe incorrect"}, status=status.HTTP_401_UNAUTHORIZED)
        except User.DoesNotExist:
            return Response({"error": "Utilisateur non trouvé"}, status=status.HTTP_401_UNAUTHORIZED)

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import viewsets, status
from rest_framework.decorators import action
from .models import Formation
from django.utils import timezone
from .serializers import FormationSerializer

class FormationViewSet(viewsets.ModelViewSet):
    queryset = Formation.objects.all().order_by('-date_creation')
    serializer_class = FormationSerializer

    def get_queryset(self):
        queryset = Formation.objects.all()
        statut = self.request.query_params.get('statut', None)
        
        if statut:
            queryset = queryset.filter(statut=statut)
        
        return queryset.order_by('-date_creation')

    @action(detail=False, methods=['get'])
    def formations_a_venir(self):
        formations = Formation.objects.filter(
            date_debut__gt=timezone.now(),
            statut='a_venir'
        )
        serializer = self.get_serializer(formations, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def formations_en_cours(self):
        now = timezone.now()
        formations = Formation.objects.filter(
            date_debut__lte=now,
            date_fin__gte=now,
            statut='en_cours'
        )
        serializer = self.get_serializer(formations, many=True)
        return Response(serializer.data)

class ParticipantViewSet(viewsets.ModelViewSet):
    queryset = Participant.objects.all()
    serializer_class = ParticipantSerializer

    def perform_create(self, serializer):
        # Générer un QR code unique pour le participant
        qr_code = str(uuid.uuid4())
        serializer.save(qr_code=qr_code)

    @action(detail=False, methods=['get'])
    def actifs(self, request):
        participants = Participant.objects.filter(actif=True)
        serializer = self.get_serializer(participants, many=True)
        return Response(serializer.data)