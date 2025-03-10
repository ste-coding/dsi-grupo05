import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import 'explore.page.dart';
import '../models/itinerario_model.dart';
import '../services/firestore/itinerarios.service.dart';
import '../widgets/itinerary_bottom_sheet.dart';
import '../services/firestore/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore/avaliacoes.service.dart';
import '../widgets/avaliacao_widget.dart';
import 'dart:convert';

class LocalDetailsPage extends StatefulWidget {
  final LocalModel local;

  const LocalDetailsPage({super.key, required this.local});

  @override
  _LocalDetailsPageState createState() => _LocalDetailsPageState();
}

class _LocalDetailsPageState extends State<LocalDetailsPage> {
  final AvaliacoesService avaliacoesService = AvaliacoesService();
  bool isFavorited = false;
  List<Map<String, dynamic>> avaliacoes = [];
  String? nomeUsuario;
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _carregarAvaliacoes();
    _carregarNomeUsuario();
  }

  Future<void> _carregarNomeUsuario() async {
    final userService = UserService();
    final userData = await userService.getUserData();
    if (userData != null && userData.containsKey('nome')) {
      setState(() {
        nomeUsuario = userData['nome'];
      });
    }
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final avaliacoesCarregadas = await avaliacoesService.carregarAvaliacoes(widget.local.id);
      setState(() {
        avaliacoes = avaliacoesCarregadas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar avaliações: $e')),
      );
    }
  }

  Future<void> abrirTelaAvaliacao({int? index}) async {
    if (nomeUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Nome do usuário não encontrado.')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final localId = widget.local.id;

    final usuarioJaAvaliou = await avaliacoesService.usuarioJaAvaliou(localId, userId);

    if (usuarioJaAvaliou && index == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você já avaliou este local.')),
      );
      return;
    }

    if (index != null) {
      final avaliacao = avaliacoes[index];
      if (userId != avaliacao['userId']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você não tem permissão para editar esta avaliação.')),
        );
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AvaliacaoFormPage(
            index: index,
            avaliacao: index != null ? avaliacoes[index] : null,
            nomeUsuario: nomeUsuario!,
            onSave: (avaliacao) async {
              try {
                avaliacao['nomeUsuario'] = nomeUsuario;
                if (index != null) {
                  await avaliacoesService.salvarAvaliacao(
                    localId,
                    avaliacao,
                    docId: avaliacoes[index]['id'],
                  );
                } else {
                  await avaliacoesService.salvarAvaliacao(localId, avaliacao);
                }
                await _carregarAvaliacoes(); 
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar avaliação: $e')),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _excluirAvaliacao(int index) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    final avaliacao = avaliacoes[index];
    if (avaliacao['userId'] != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não tem permissão para excluir esta avaliação.')),
      );
      return;
    }

    try {
      await avaliacoesService.excluirAvaliacao(widget.local.id, avaliacao['id']);
      setState(() {
        avaliacoes.removeAt(index); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação excluída!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir avaliação: $e')),
      );
    }
  }


  Future<void> _checkIfFavorited() async {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    bool favoritado = await localController.favoritosService
        .checkIfFavoritoExists(widget.local.id);
    setState(() {
      isFavorited = favoritado;
    });
  }

  void _toggleFavorite() async {
    final localController =
        Provider.of<LocalController>(context, listen: false);

    if (isFavorited) {
      await localController.removeFromFavoritos(widget.local.id);
    } else {
      await localController.addToFavoritos(widget.local);
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  void _addToItinerary() async {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    final itinerarioItem = ItinerarioItem(
      localId: widget.local.id,
      localName: widget.local.nome,
      visitDate: DateTime.now(),
      comment: 'Comentário opcional',
    );

    final itinerario = ItinerarioModel(
      id: '',
      userId: 'userId',
      titulo: 'Título do Itinerário',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 2)),
      observations: 'Observações sobre o itinerário',
      imageUrl: '',
      locais: [itinerarioItem],
    );

    try {
      await localController.itinerariosService
          .addItinerario(itinerario.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local adicionado ao itinerário!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar local: $e')),
      );
    }
  }

List<int> _calcularDistribuicaoEstrelas(List<Map<String, dynamic>> avaliacoes) {
  List<int> estrelasCount = List.filled(5, 0); 

  for (var avaliacao in avaliacoes) {
    int estrelas = avaliacao['estrelas'];
    if (estrelas >= 1 && estrelas <= 5) {
      estrelasCount[estrelas - 1]++;
    }
  }

  return estrelasCount;
}
@override
Widget build(BuildContext context) {
  final distribuicaoEstrelas = _calcularDistribuicaoEstrelas(avaliacoes);

  return Scaffold(
    body: CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocalHeader(),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 24),
                const Text(
                  'Avaliações',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                if (avaliacoes.isEmpty)
                  const Text(
                    'Nenhuma avaliação ainda. Adicione uma!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: avaliacoes.length,
                    itemBuilder: (context, index) {
                      final avaliacao = avaliacoes[index];
                      final podeExcluir = FirebaseAuth.instance.currentUser?.uid == avaliacao['userId'];

                      return Dismissible(
                        key: Key(avaliacao['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (!podeExcluir) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Você não tem permissão para excluir esta avaliação.')),
                            );
                            return false;
                          }
                          return true;
                        },
                        onDismissed: (direction) async {
                          await _excluirAvaliacao(index);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () => abrirTelaAvaliacao(index: index),
                            title: Text(
                              avaliacao['nomeUsuario'],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < avaliacao['estrelas']
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 15,
                                    );
                                  }),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                ),                                 
                                Text(
                                  avaliacao['comentario'],
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => abrirTelaAvaliacao(),
      backgroundColor: const Color(0xFF01A897),
      child: const Icon(Icons.add, color: Colors.white),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.local.imagem.isNotEmpty
            ? (widget.local.imagem.startsWith('http')
                ? Image.network(
                    widget.local.imagem,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 50, color: Colors.grey[700]);
                    },
                  )
                : Image.memory(
                    base64Decode(widget.local.imagem),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 50, color: Colors.grey[700]);
                    },
                  ))
            : Container(
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 50, color: Colors.grey[700]),
              ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildLocalHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: widget.local.imagem.isNotEmpty
              ? (widget.local.imagem.startsWith('http')
                  ? NetworkImage(widget.local.imagem)
                  : MemoryImage(base64Decode(widget.local.imagem)) as ImageProvider)
              : AssetImage('assets/placeholder.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.local.nome,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.local.cidade}, ${widget.local.estado}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.local.descricao,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: const Color.fromARGB(255, 1, 168, 151),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Home',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Itinerários',
          tooltip: 'Itinerários',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
          tooltip: 'Buscar',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gps_fixed),
          label: 'Mapa',
          tooltip: 'Mapa',
          backgroundColor: Colors.white,
        ),
      ],
      selectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
      unselectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/menu');
            break;
          case 1:
            Navigator.pushNamed(context, '/itinerario');
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ExplorePage(onSelectedLocal: (local) {
                        print("Local selecionado: ${local.nome}");
                      })),
            );
            break;
          case 3:
            Navigator.pushNamed(context, '/perfil');
            break;
        }
      },
    );
  }

  void _showItineraryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ItineraryBottomSheet(local: widget.local);
      },
    );
  }
}

class AvaliacaoFormPage extends StatefulWidget {
  final int? index;
  final Map<String, dynamic>? avaliacao;
  final String nomeUsuario; 
  final Function(Map<String, dynamic>) onSave;

  const AvaliacaoFormPage({
    super.key,
    this.index,
    this.avaliacao,
    required this.nomeUsuario,
    required this.onSave,
  });

  @override
  _AvaliacaoFormPageState createState() => _AvaliacaoFormPageState();
}

class _AvaliacaoFormPageState extends State<AvaliacaoFormPage> {
  TextEditingController comentarioController = TextEditingController();
  int estrelasSelecionadas = 0;

  @override
  void initState() {
    super.initState();
    if (widget.avaliacao != null) {
      comentarioController.text = widget.avaliacao!["comentario"];
      estrelasSelecionadas = widget.avaliacao!["estrelas"];
    }
  }

  void salvarAvaliacao() {
    if (comentarioController.text.isNotEmpty && estrelasSelecionadas > 0) {
      widget.onSave({
        "local": widget.nomeUsuario, 
        "comentario": comentarioController.text,
        "estrelas": estrelasSelecionadas,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.index != null ? "Editar Avaliação" : "Nova Avaliação",
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: comentarioController,
              decoration: InputDecoration(
                labelText: 'Tarefa',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF266B70),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      estrelasSelecionadas = index + 1;
                    });
                  },
                  icon: Icon(
                    index < estrelasSelecionadas
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF266B70), width: 2),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Color(0xFF266B70),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: salvarAvaliacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF266B70),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
