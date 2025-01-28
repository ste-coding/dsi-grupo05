import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore.dart';
import '../widgets/tourist_spot_card.dart';
import 'dart:convert';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<QueryDocumentSnapshot> _touristSpots = [];
  bool _hasMore = true;
  bool _isLoading = false;
  DocumentSnapshot? _lastVisible;

  @override
  void initState() {
    super.initState();
    _loadTouristSpots();
  }

  void _loadTouristSpots() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    Stream<QuerySnapshot> stream =
        _firestoreService.getTouristSpotsStream(lastVisible: _lastVisible);

    stream.listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _touristSpots.addAll(snapshot.docs);
          _lastVisible = snapshot.docs.last;
          if (snapshot.docs.length < 10) {
            _hasMore = false;
          }
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Temporário'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _touristSpots.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _touristSpots.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TextButton(
                          onPressed: _hasMore ? _loadTouristSpots : null,
                          child: const Text('Ver Mais'),
                        );
                }

                final spot = _touristSpots[index];
                final locationString = spot['location'];
                final locationMap =
                    jsonDecode(locationString.replaceAll("'", '"'));
                final latitude = locationMap['latitude'];
                final longitude = locationMap['longitude'];

                return TouristSpotCard(
                  name: spot['name'],
                  city: spot['city'],
                  stars: spot['stars'],
                  latitude: latitude,
                  longitude: longitude,
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Avaliações'),
              onTap: () {
                Navigator.pushNamed(context, '/avaliacoes');
              },
            ),
            ListTile(
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pushNamed(context, '/favoritos');
              },
            ),
            ListTile(
              title: const Text('Itinerários'),
              onTap: () {
                Navigator.pushNamed(context, '/itinerario');
              },
            ),
            ListTile(
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushNamed(context, '/inicial');
              },
            ),
          ],
        ),
      ),
    );
  }
}
