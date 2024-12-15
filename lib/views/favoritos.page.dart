import 'package:flutter/material.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  String buttonText = 'Adicionar Localização';
  List<String> locais = []; 


  void addLocal(String local) {
    setState(() {
      locais.add(local); 
    });
  }

  void onAddLocal() {
    addLocal('Local ${locais.length + 1}');
  }

  void removeLocal(int index) {
    setState(() {
      locais.removeAt(index); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFEAF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              'Favoritos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Visualize ou edite sua lista de desejos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 50),
            
            Text(
              'Localizações salvas',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20),
          
            // Lista de boxes de localizações
            Expanded(
              child: ListView.builder(
                itemCount: locais.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:Color(0xFFDFEAF1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Texto com o nome da localização
                        Text(
                          locais[index], // Exibe o nome da localização
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Botão de deletar
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeLocal(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Botão para adicionar localizações
            Center(
              child: SizedBox(
                width: 250,
                height: 48,
                child: OutlinedButton(
                  onPressed: onAddLocal,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
                    backgroundColor: Color(0xFF266B70),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 16, color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
