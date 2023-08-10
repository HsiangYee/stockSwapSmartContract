from django.contrib import admin
from django.urls import path
from apps.viewApp import views as viewApp

urlpatterns = [
    path('', viewApp.index, name='index'),
    # path('swap', viewApp.swap, name='view.swap'),
    # path('pools', viewApp.pools, name='view.pools'),
    path('addLiquidity/<str:contract_address>', viewApp.addLiquidity, name='view.addLiquidity'),
    path('pool/<str:contract_address>', viewApp.pool, name='view.pool'),
]
