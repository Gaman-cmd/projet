#serializers.py
from rest_framework import serializers
from .models import Formation, Seance, Inscription, Presence, User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'nom', 'prenom', 'email', 'role', 'telephone',
            'date_naissance', 'lieu_naissance', 'qr_code',
            'date_generation_qr', 'actif', 'date_creation'
        ]
        read_only_fields = ['qr_code', 'date_generation_qr', 'date_creation']

class ParticipantRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'nom', 'prenom', 'password', 'telephone', 'date_naissance', 'lieu_naissance']

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            nom=validated_data.get('nom', ''),
            prenom=validated_data.get('prenom', ''),
            telephone=validated_data.get('telephone', ''),
            date_naissance=validated_data.get('date_naissance', None),
            lieu_naissance=validated_data.get('lieu_naissance', ''),
            role='participant'
        )
        return user

class FormateurRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'nom', 'prenom', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            nom=validated_data.get('nom', ''),
            prenom=validated_data.get('prenom', ''),
           # telephone=validated_data.get('telephone', ''),
            role='formateur'
        )
        return user

class SeanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Seance
        fields = ['id', 'titre', 'date_debut', 'date_fin', 'lieu', 'salle', 'formation']

class FormationSerializer(serializers.ModelSerializer):
    seances = SeanceSerializer(many=True, read_only=True)
    participants_inscrits = serializers.SerializerMethodField()
    formateur = UserSerializer(read_only=True)
    formateur_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role='formateur'),
        source='formateur',
        write_only=True,
        required=False
    )
    nombre_participants_acceptes = serializers.SerializerMethodField()
    image_url = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    class Meta:
        model = Formation
        fields = [
            'id', 'titre', 'description', 'date_debut', 'date_fin',
            'lieu', 'places_total', 'places_reservees', 'contact_email',
            'image_url', 'statut', 'date_creation', 'seances',
            'participants_inscrits', 'formateur', 'formateur_id',
            'nombre_participants_acceptes'
        ]

    def get_participants_inscrits(self, obj):
        return Inscription.objects.filter(formation=obj, statut='accepte').count()

    def get_nombre_participants_acceptes(self, obj):
        return obj.inscriptions.filter(statut='accepte').count()

class InscriptionSerializer(serializers.ModelSerializer):
    participant = UserSerializer(read_only=True)
    formation = FormationSerializer(read_only=True)

    class Meta:
        model = Inscription
        fields = [
            'id', 'participant', 'formation', 'date_inscription', 'statut', 'qr_code'
        ]

class PresenceSerializer(serializers.ModelSerializer):
    participant = UserSerializer(read_only=True)
    participant_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role='participant'),
        source='participant',
        write_only=True,
        required=False
    )
    seance = SeanceSerializer(read_only=True)
    seance_id = serializers.PrimaryKeyRelatedField(
        queryset=Seance.objects.all(),
        source='seance',
        write_only=True,
        required=False
    )
    scanne_par = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role='formateur'),
        required=False
    )

    class Meta:
        model = Presence
        fields = [
            'id', 'seance', 'seance_id', 'participant', 'participant_id',
            'date_scan', 'statut', 'scanne_par'
        ]

    def validate(self, data):
        # Vérifie que participant et séance sont présents, sauf si on passe par une vue personnalisée (qr_code)
        if not data.get('participant') and not self.context.get('allow_qr_only'):
            raise serializers.ValidationError("participant_id est requis")
        if not data.get('seance') and not self.context.get('allow_qr_only'):
            raise serializers.ValidationError("seance_id est requis")
        return data
