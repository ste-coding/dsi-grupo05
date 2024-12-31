import 'package:flutter/material.dart';

class LocationOptionsPage extends StatelessWidget {
  final String? initialLocation;

  const LocationOptionsPage({super.key, this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final List<String> locations = ["Recife", "Olinda", "Jaboatão", "Camaragibe", "Cabo", "Petrolina", "Paulista"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Escolha uma localização"),
        backgroundColor: const Color(0xFF266B70),
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adiciona espaço entre os itens
            child: Container(
              decoration: BoxDecoration(
                color: initialLocation == location ? Colors.blue[100] : null, // Destaca a localização
                borderRadius: BorderRadius.circular(8), // Adiciona borda arredondada
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Adiciona mais padding ao redor do texto
                onTap: () {
                  Navigator.pop(context, location); // Retorna a localização escolhida
                },
                title: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: const Color(0xFF266B70), // Cor do coração
                      size: 20.0, // Tamanho do ícone
                    ),
                    const SizedBox(width: 8.0), // Espaço entre o ícone e o texto
                    Text(location),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
