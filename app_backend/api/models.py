from django.db import models

# Create your models here.
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.db import models
from django.utils import timezone

# 1. Utilisateur (Admin)

class UtilisateurManager(BaseUserManager):
    def create_user(self, email, mot_de_passe=None, **extra_fields):
        if not email:
            raise ValueError("L'email est obligatoire")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(mot_de_passe)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, mot_de_passe=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("actif", True)

        return self.create_user(email, mot_de_passe, **extra_fields)

class Utilisateur(AbstractBaseUser, PermissionsMixin):
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    date_creation = models.DateTimeField(auto_now_add=True)
    derniere_connexion = models.DateTimeField(blank=True, null=True)
    actif = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)  # nécessaire pour l'admin

    objects = UtilisateurManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nom', 'prenom']

    def __str__(self):
        return f"{self.prenom} {self.nom}"



# 2. Formation
class Formation(models.Model):
    STATUT_CHOICES = [
        ('a_venir', 'À venir'),
        ('en_cours', 'En cours'),
        ('terminee', 'Terminée')
    ]

    titre = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    date_debut = models.DateTimeField()
    date_fin = models.DateTimeField()
    lieu = models.CharField(max_length=255, blank=True)
    salle = models.CharField(max_length=100, blank=True)
    places_total = models.IntegerField()
    places_reservees = models.IntegerField(default=0)
    contact_email = models.EmailField(blank=True)
    image_url = models.URLField(blank=True)
    statut = models.CharField(max_length=10, choices=STATUT_CHOICES, default='a_venir')
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre


# 3. Participant
class Participant(models.Model):
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    email = models.EmailField()
    telephone = models.CharField(max_length=20, blank=True)
    date_naissance = models.DateField(blank=True, null=True)
    lieu_naissance = models.CharField(max_length=100, blank=True)
    qr_code = models.CharField(max_length=255, unique=True)
    date_generation_qr = models.DateTimeField(auto_now_add=True)
    actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.prenom} {self.nom}"


# 4. Inscription
class Inscription(models.Model):
    formation = models.ForeignKey(Formation, on_delete=models.CASCADE, related_name="inscriptions")
    participant = models.ForeignKey(Participant, on_delete=models.CASCADE, related_name="inscriptions")
    date_inscription = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('formation', 'participant')


# 5. Séance
class Seance(models.Model):
    formation = models.ForeignKey(Formation, on_delete=models.CASCADE, related_name="seances")
    titre = models.CharField(max_length=255, blank=True)
    date_debut = models.DateTimeField()
    date_fin = models.DateTimeField()
    lieu = models.CharField(max_length=255, blank=True)
    salle = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return self.titre or f"Séance de {self.formation}"


# 6. Présence
class Presence(models.Model):
    STATUT_CHOICES = [
        ('present', 'Présent'),
        ('absent', 'Absent')
    ]

    seance = models.ForeignKey(Seance, on_delete=models.CASCADE, related_name="presences")
    participant = models.ForeignKey(Participant, on_delete=models.CASCADE, related_name="presences")
    date_scan = models.DateTimeField(auto_now_add=True)
    statut = models.CharField(max_length=10, choices=STATUT_CHOICES, default='absent')
    scanne_par = models.ForeignKey(Utilisateur, on_delete=models.SET_NULL, null=True, blank=True)

    class Meta:
        unique_together = ('seance', 'participant')


# 7. Rapport
class Rapport(models.Model):
    TYPE_CHOICES = [
        ('presence', 'Présence'),
        ('participation', 'Participation'),
        ('satisfaction', 'Satisfaction'),
    ]
    FORMAT_CHOICES = [
        ('pdf', 'PDF'),
        ('excel', 'Excel'),
        ('csv', 'CSV'),
    ]

    formation = models.ForeignKey(Formation, on_delete=models.SET_NULL, null=True, related_name="rapports")
    titre = models.CharField(max_length=255)
    date_generation = models.DateTimeField(auto_now_add=True)
    genere_par = models.ForeignKey(Utilisateur, on_delete=models.SET_NULL, null=True)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    format = models.CharField(max_length=10, choices=FORMAT_CHOICES)
    url_fichier = models.URLField(blank=True)

    def __str__(self):
        return self.titre

