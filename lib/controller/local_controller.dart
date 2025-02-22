import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/foursquare_service.dart';
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../repositories/local_repository.dart';
import '../services/firestore/favoritos.service.dart';
import '../services/firestore/itinerarios.service.dart';
import '../models/itinerario_model.dart';

class LocalController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalRepository repository;
  final FavoritosService favoritosService;
  final ItinerariosService itinerariosService;

  bool _isLoading = false;
  bool _finishLoading = false;
  String? _errorMessage;
  final List<LocalModel> _locais = [];
  final List<LocalModel> _locaisProximos = [];
  int _page = 0;
  Position? _userPosition;

  bool get isLoading => _isLoading;
  bool get finishLoading => _finishLoading;
  String? get errorMessage => _errorMessage;
  List<LocalModel> get locais => _locais;
  List<LocalModel> get locaisProximos => _locaisProximos;

  LocalController(
      this.repository, this.favoritosService, this.itinerariosService);

  void resetLocais() {
    _locais.clear();
    _page = 0;
    _finishLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _userPosition = position;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      await fetchLocaisProximos();

      Geolocator.getPositionStream().listen((position) {
        _userPosition = position;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      });
    } catch (e) {
      _errorMessage = 'Erro ao obter localização: $e';
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = 'Ative os serviços de localização';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Permissão de localização negada';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'Permissão permanente negada. Ative nas configurações';
      await Geolocator.openAppSettings();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }

    return true;
  }

  Future<void> fetchLocais(String query, String location) async {
    if (_isLoading || _finishLoading) return;

    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      await _initializeLocation();

      final result =
          await repository.fetchLocais(query, location, offset: _page * 20);

      result.fold(
        (error) {
          _errorMessage = error;
          _isLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        },
        (response) {
          if (response.locais.isEmpty) {
            _finishLoading = true;
          } else {
            _locais.addAll(response.locais);
            _page++;
          }
          _isLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        },
      );
    } catch (e) {
      _errorMessage = "Erro ao carregar locais: $e";
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> fetchLocaisProximos() async {
    if (_isLoading) return;

    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      if (_userPosition == null) {
        await _initializeLocation();
      }

      if (_userPosition == null) {
        _errorMessage = 'Não foi possível obter a localização atual';
        _isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }

      final places = await FoursquareService().fetchPlaces(
        '',
        '${_userPosition!.latitude},${_userPosition!.longitude}',
      );

      _locaisProximos.clear();
      _locaisProximos.addAll(places
          .where((place) => place.latitude != 0.0 && place.longitude != 0.0)
          .toList());

      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = "Erro ao carregar locais próximos: $e";
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> addToFavoritos(LocalModel local) async {
    try {
      await favoritosService.addFavorito(local);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Erro ao adicionar favorito: $e';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> removeFromFavoritos(String localId) async {
    try {
      await favoritosService.removeFavorito(localId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Erro ao remover favorito: $e';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> addToItinerario(Map<String, dynamic> itinerario) async {
    try {
      await itinerariosService.addItinerario(itinerario);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Erro ao adicionar ao itinerário: $e';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<List<ItinerarioModel>> getUserItinerarios() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("Usuário não autenticado");
        return [];
      }

      final snapshot = await _firestore
          .collection('viajantes')
          .doc(userId)
          .collection('itinerarios')
          .get();

      print(
          "Snapshot de itinerários recuperado. Total de documentos: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        print("Nenhum itinerário encontrado.");
        return [];
      }

      List<ItinerarioModel> itinerarios = [];

      for (var doc in snapshot.docs) {
        var itinerarioData = doc.data();
        String itinerarioId = doc.id;

        var locaisSnapshot = await _firestore
            .collection('viajantes')
            .doc(userId)
            .collection('itinerarios')
            .doc(itinerarioId)
            .collection('roteiro')
            .get();

        List<ItinerarioItem> locais = locaisSnapshot.docs
            .map((localDoc) => ItinerarioItem.fromFirestore(localDoc.data()))
            .toList();

        itinerarios.add(ItinerarioModel.fromFirestore(itinerarioData, locais));
      }

      print("Itinerários carregados: ${itinerarios.length}");
      return itinerarios;
    } catch (e) {
      print('Erro ao buscar itinerários: $e');
      return [];
    }
  }

  Future<void> addLocalToRoteiro(
      String itinerarioId, LocalModel local, DateTime visitDate) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Usuário não autenticado");
      return;
    }

    final itinerarioDoc = await _firestore
        .collection('viajantes')
        .doc(userId)
        .collection('itinerarios')
        .doc(itinerarioId)
        .get();

    if (!itinerarioDoc.exists) {
      print("Erro: itinerário não encontrado para o ID: $itinerarioId");
      return;
    }

    final itinerarioItem = ItinerarioItem(
      localId: local.id,
      localName: local.nome,
      visitDate: visitDate,
      comment: 'Comentário opcional',
    );

    final localData = itinerarioItem.toFirestore();

    try {
      await _firestore
          .collection('viajantes')
          .doc(userId)
          .collection('itinerarios')
          .doc(itinerarioId)
          .collection('roteiro')
          .add(localData);

      print("Local adicionado ao roteiro com sucesso!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print("Erro ao adicionar local ao roteiro: $e");
    }
  }
}

