from rest_framework import serializers
from .models import Formation, Seance, Inscription, Participant

class ParticipantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Participant
        fields = [
            'id', 'nom', 'prenom', 'email', 'telephone',
            'date_naissance', 'lieu_naissance', 'qr_code',
            'date_generation_qr', 'actif', 'date_creation'
        ]
        read_only_fields = ['qr_code', 'date_generation_qr', 'date_creation']

class SeanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Seance
        fields = ['id', 'titre', 'date_debut', 'date_fin', 'lieu', 'salle']

class FormationSerializer(serializers.ModelSerializer):
    seances = SeanceSerializer(many=True, read_only=True)
    participants_inscrits = serializers.SerializerMethodField()

    class Meta:
        model = Formation
        fields = [
            'id', 'titre', 'description', 'date_debut', 'date_fin',
            'lieu', 'places_total', 'places_reservees', 'contact_email',
            'image_url', 'statut', 'date_creation', 'seances',
            'participants_inscrits'
        ]

    def get_participants_inscrits(self, obj):
        return Inscription.objects.filter(formation=obj).count()