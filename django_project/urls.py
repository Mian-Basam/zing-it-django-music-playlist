"""Project-level URL configuration: every request is forwarded to the zing_it app."""
from django.urls import include, path

urlpatterns = [
    path("", include("zing_it.urls")),
]
