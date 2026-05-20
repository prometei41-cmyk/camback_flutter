from django.urls import path

from .views import AddressListView, AddressCreateView, AddressUpdateView, AddressDeleteView, \
    set_default_address

urlpatterns = [
    path('', AddressListView.as_view()),
    path('create/', AddressCreateView.as_view()),
    path('<int:pk>/', AddressUpdateView.as_view()),
    path('<int:pk>/delete/', AddressDeleteView.as_view()),
    path('<int:pk>/set_default/', set_default_address),
]
