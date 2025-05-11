from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from .models import Formation, Inscription, Presence, Seance, User
from django.utils import timezone
from .serializers import (
    FormationSerializer, UserSerializer, InscriptionSerializer,
    PresenceSerializer, SeanceSerializer, ParticipantRegisterSerializer,
    FormateurRegisterSerializer
)
import uuid

class UtilisateurLoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        if not email or not password:
            return Response({"error": "Email et mot de passe sont requis"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
            if user.check_password(password):
                # On renvoie toutes les infos utiles, y compris le rôle
                return Response({
                    "message": "Authentification réussie",
                    "user": {
                        "id": user.id,
                        "nom": user.nom,
                        "prenom": user.prenom,
                        "email": user.email,
                        "telephone": user.telephone,
                        "date_naissance": user.date_naissance,
                        "lieu_naissance": user.lieu_naissance,
                        "role": user.role,  # <-- le rôle ici
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Mot de passe incorrect"}, status=status.HTTP_401_UNAUTHORIZED)
        except User.DoesNotExist:
            return Response({"error": "Utilisateur non trouvé"}, status=status.HTTP_401_UNAUTHORIZED)

class FormationViewSet(viewsets.ModelViewSet):
    queryset = Formation.objects.all().order_by('-date_creation')
    serializer_class = FormationSerializer
    #permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Formation.objects.all()
        statut = self.request.query_params.get('statut', None)
        if statut:
            queryset = queryset.filter(statut=statut)
        return queryset.order_by('-date_creation')

    @action(detail=False, methods=['get'])
    def formations_a_venir(self, request):
        formations = Formation.objects.filter(
            date_debut__gt=timezone.now(),
            statut='a_venir'
        )
        serializer = self.get_serializer(formations, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def formations_en_cours(self, request):
        now = timezone.now()
        formations = Formation.objects.filter(
            date_debut__lte=now,
            date_fin__gte=now,
            statut='en_cours'
        )
        serializer = self.get_serializer(formations, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def par_participant(self, request):
        participant_id = request.query_params.get('participant_id')
        if not participant_id:
            return Response({"error": "participant_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        inscriptions = Inscription.objects.filter(participant_id=participant_id)
        formations = [insc.formation for insc in inscriptions]
        serializer = self.get_serializer(formations, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def par_formateur(self, request):
        formateur_id = request.query_params.get('formateur_id')
        if not formateur_id:
            return Response({"error": "formateur_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        formations = Formation.objects.filter(formateur_id=formateur_id)
        serializer = self.get_serializer(formations, many=True)
        return Response(serializer.data)

class ParticipantViewSet(viewsets.ModelViewSet):
    queryset = User.objects.filter(role='participant')
    serializer_class = UserSerializer

    def perform_create(self, serializer):
        # Générer un QR code unique pour le participant
        qr_code = str(uuid.uuid4())
        serializer.save(qr_code=qr_code, role='participant')

    @action(detail=False, methods=['get'])
    def actifs(self, request):
        participants = User.objects.filter(role='participant', actif=True)
        serializer = self.get_serializer(participants, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def par_formation(self, request):
        formation_id = request.query_params.get('formation_id')
        if not formation_id:
            return Response({"error": "formation_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        inscriptions = Inscription.objects.filter(formation_id=formation_id)
        participants = [insc.participant for insc in inscriptions]
        serializer = self.get_serializer(participants, many=True)
        return Response(serializer.data)

class InscriptionView(APIView):
    def post(self, request):
        participant_id = request.data.get('participant_id')
        formation_id = request.data.get('formation_id')

        try:
            participant = User.objects.get(id=participant_id, role='participant')
            formation = Formation.objects.get(id=formation_id)
            Inscription.objects.create(participant=participant, formation=formation)
            return Response({'message': 'Participant ajouté à la formation'}, status=status.HTTP_201_CREATED)
        except User.DoesNotExist:
            return Response({'error': 'Participant non trouvé'}, status=status.HTTP_404_NOT_FOUND)
        except Formation.DoesNotExist:
            return Response({'error': 'Formation non trouvée'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class InscriptionViewSet(viewsets.ModelViewSet):
    queryset = Inscription.objects.all()
    serializer_class = InscriptionSerializer

    def get_queryset(self):
        queryset = Inscription.objects.all()
        participant_id = self.request.query_params.get('participant_id')
        formation_id = self.request.query_params.get('formation_id')
        if participant_id:
            queryset = queryset.filter(participant_id=participant_id)
        if formation_id:
            queryset = queryset.filter(formation_id=formation_id)
        return queryset

    @action(detail=True, methods=['post'])
    def valider(self, request, pk=None):
        inscription = self.get_object()
        statut = request.data.get('statut')
        if statut not in ['accepte', 'refuse']:
            return Response({'error': 'Statut invalide'}, status=400)
        inscription.statut = statut
        if statut == 'accepte':
            inscription.qr_code = f"{inscription.formation.id}-{uuid.uuid4()}"
        inscription.save()
        return Response({'message': f'Inscription {statut} avec succès.', 'qr_code': inscription.qr_code})

class PresenceViewSet(viewsets.ModelViewSet):
    queryset = Presence.objects.all()
    serializer_class = PresenceSerializer

    @action(detail=False, methods=['get'])
    def par_seance(self, request):
        seance_id = request.query_params.get('seance_id')
        if not seance_id:
            return Response({"error": "seance_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        presences = Presence.objects.filter(seance_id=seance_id)
        serializer = self.get_serializer(presences, many=True)
        return Response(serializer.data)

class SeanceViewSet(viewsets.ModelViewSet):
    queryset = Seance.objects.all()
    serializer_class = SeanceSerializer

    @action(detail=False, methods=['get'])
    def par_formation(self, request):
        formation_id = request.query_params.get('formation_id')
        if not formation_id:
            return Response({"error": "formation_id requis"}, status=status.HTTP_400_BAD_REQUEST)
        seances = Seance.objects.filter(formation_id=formation_id)
        serializer = self.get_serializer(seances, many=True)
        return Response(serializer.data)

class ParticipantRegisterView(generics.CreateAPIView):
    serializer_class = ParticipantRegisterSerializer

class FormateurRegisterView(generics.CreateAPIView):
    serializer_class = FormateurRegisterSerializer

@api_view(['PUT'])
def modifier_profil(request, pk):
    try:
        user = User.objects.get(pk=pk)
        # Autorise admin et participant
        if user.role not in ['participant', 'admin']:
            return Response({'error': 'Modification non autorisée'}, status=403)
    except User.DoesNotExist:
        return Response({'error': 'Utilisateur non trouvé'}, status=404)
    data = request.data
    user.nom = data.get('nom', user.nom)
    user.prenom = data.get('prenom', user.prenom)
    user.telephone = data.get('telephone', user.telephone)
    user.date_naissance = data.get('date_naissance', user.date_naissance)
    user.lieu_naissance = data.get('lieu_naissance', user.lieu_naissance)
    user.save()
    return Response({'message': 'Profil mis à jour avec succès.'})

@api_view(['GET'])
def notifications_participant(request, participant_id):
    # Exemple dynamique : notifications liées aux inscriptions du participant
    from .models import Inscription
    notifications = []
    inscriptions = Inscription.objects.filter(participant_id=participant_id).order_by('-date_inscription')
    for insc in inscriptions:
        if insc.statut == 'accepte':
            notifications.append({
                "message": f"Votre inscription à \"{insc.formation.titre}\" a été acceptée.",
                "date": insc.date_inscription.strftime("%d/%m/%Y"),
            })
        elif insc.statut == 'refuse':
            notifications.append({
                "message": f"Votre inscription à \"{insc.formation.titre}\" a été refusée.",
                "date": insc.date_inscription.strftime("%d/%m/%Y"),
            })
        elif insc.statut == 'en_attente':
            notifications.append({
                "message": f"Votre inscription à \"{insc.formation.titre}\" est en attente de validation.",
                "date": insc.date_inscription.strftime("%d/%m/%Y"),
            })
    return Response(notifications)