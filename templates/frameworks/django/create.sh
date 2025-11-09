#!/usr/bin/env bash

echo "🚀 Erstelle Django Projekt..."

mkdir -p backend
cd backend

python3 -m venv venv
source venv/bin/activate

pip install django
django-admin startproject app .

pip freeze > requirements.txt

deactivate

echo "✅ Django Projekt erstellt."
