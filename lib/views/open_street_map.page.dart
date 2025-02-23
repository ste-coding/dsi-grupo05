import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_1/models/local_model.dart'; 
import 'package:flutter_application_1/services/foursquare_service.dart'; 

class OpenStreetMapPage extends StatefulWidget {
  const OpenStreetMapPage({super.key});

  @override
  State<OpenStreetMapPage> createState() => _OpenStreetMapPageState();
}

class _OpenStreetMapPageState extends State<OpenStreetMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];

  List<LocalModel> _places = [];
  final bool _showPlaces = true;
  LocalModel? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });

      // Buscar locais do Foursquare
      await _fetchNearbyPlaces();

      Geolocator.getPositionStream().listen((position) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
            });
    } catch (e) {
      setState(() => isLoading = false);
      errorMessage('Erro ao obter localização');
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_currentLocation == null) return;

    try {
      final places = await FoursquareService().fetchPlaces(
        '',
        '${_currentLocation!.latitude},${_currentLocation!.longitude}',
      );

      setState(() {
        _places = places.where((place) => 
          place.latitude != 0.0 && place.longitude != 0.0
        ).toList();
      });
    } catch (e) {
      errorMessage('Erro ao carregar locais próximos');
    }
  }

  // Usar coordenadas do local selecionado
  void _onPlaceSelected(LocalModel place) {
    setState(() {
      _selectedPlace = place;
      _destination = LatLng(place.latitude, place.longitude);
      _locationController.text = place.nome;
    });
    _fetchRoute();
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      errorMessage('Ative os serviços de localização');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        errorMessage('Permissão de localização negada');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      errorMessage('Permissão permanente negada. Ative nas configurações');
      await openAppSettings();
      return false;
    }
    
    return true;
  }

  Future<void> fetchCoordinatesPoint(String location) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final coordinates = data[0];
        final latitude = double.parse(coordinates['lat']);
        final longitude = double.parse(coordinates['lon']);
        setState(() {
          _destination = LatLng(latitude, longitude);
        });
        await _fetchRoute();
      } else {
        errorMessage('Localização não encontrada');
      }
    } else {
      errorMessage('Erro ao buscar a localização');
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;
    
    final url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/"
        '${_currentLocation!.longitude},${_currentLocation!.latitude};'
        '${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline');
        
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      errorMessage('Erro ao buscar a rota');
    }
  }

  void _decodePolyline(String encodedPolyline) {
    final PolylinePoints polylinePoints = PolylinePoints();
    final List<PointLatLng> decodedPoints = 
        polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      _route = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      errorMessage('Localização não encontrada');
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          isLoading 
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? const LatLng(-23.5505, -46.6333),
                    initialZoom: 15,
                    minZoom: 3,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),

                    CurrentLocationLayer(
                      style: LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          color: Colors.blue,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                          ),
                        ),
                        markerSize: const Size(35, 35),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),
                    
                    // Marcadores dos locais do Foursquare
                    MarkerLayer(
                      markers: _places.map((place) => Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _onPlaceSelected(place),
                          child: Icon(
                            _getCategoryIcon(place.categoria),
                            color: _selectedPlace?.id == place.id 
                                ? Colors.green 
                                : const Color(0xFF01A897),
                            size: 30,
                          ),
                        ),
                      )).toList(),
                    ),

                    // Marcador de destino
                    if (_destination != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _destination!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),

                    // Polilinha da rota
                    if (_currentLocation != null && 
                        _destination != null &&
                        _route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            color: const Color(0xFF01A897).withOpacity(0.8),
                            strokeWidth: 5,
                          )
                        ],
                      ),
                  ],
                ),
          
          // Campo de busca
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Digite o destino...',
                        hintStyle: TextStyle(fontFamily: 'Poppins'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins'),
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          await fetchCoordinatesPoint(value);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final location = _locationController.text.trim();
                      if (location.isNotEmpty) {
                        await fetchCoordinatesPoint(location);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Botão de localização
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _userCurrentLocation,
              backgroundColor: const Color(0xFF01A897),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Painel de informações do local
          if (_selectedPlace != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPlace!.nome,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: Colors.red, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '${_selectedPlace!.cidade}, ${_selectedPlace!.estado}',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            ' ${_selectedPlace!.mediaEstrelas.toStringAsFixed(1)}',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          const SizedBox(width: 15),
                          Icon(Icons.people, color: Colors.blue, size: 20),
                          Text(
                            ' ${_selectedPlace!.totalAvaliacoes} avaliações',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'park':
        return Icons.park;
      case 'museum':
        return Icons.museum;
      case 'hotel':
        return Icons.hotel;
      case 'coffee shop':
        return Icons.coffee;
      case 'shop':
      case 'store':
        return Icons.shopping_cart;
      default:
        return Icons.location_pin;
    }
  }
}
