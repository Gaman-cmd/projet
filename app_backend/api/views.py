from django.shortcuts import render

# Create your views here.

from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UtilisateurSerializer


class LoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        mot_de_passe = request.data.get("mot_de_passe")
        
        # Vérification simple des identifiants
        if not email or not mot_de_passe:
            return Response({"error": "Email et mot de passe requis"}, status=status.HTTP_400_BAD_REQUEST)

        user = authenticate(request, username=email, password=mot_de_passe)

        if user is not None:
            # Connexion réussie, tu peux renvoyer un message ou un token
            return Response({"message": "Login réussi"})
        else:
            return Response({"error": "Identifiants invalides"}, status=status.HTTP_401_UNAUTHORIZED)



