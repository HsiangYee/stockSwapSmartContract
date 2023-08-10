from django.shortcuts import render
from django.http import HttpResponse
import json

def index(request):
    return render(request, 'index.html')

# def swap(request):
#     return render(request, 'swap.html')

def pool(request, contract_address):
    response = {"contract_address": contract_address}

    return render(request, 'pools.html', response)

def addLiquidity(request, contract_address):
    response = {"contract_address": contract_address}

    return render(request, "addLiquidity.html", response)