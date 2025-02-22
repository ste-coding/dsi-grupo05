import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import 'explore.page.dart';
import '../models/itinerario_model.dart';
import '../services/firestore/itinerarios.service.dart';
import '../widgets/itinerary_bottom_sheet.dart';
import '../services/firestore/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // FirebaseFirestore

class LocalDetailsPage extends StatefulWidget {
  final LocalModel local;

  const LocalDetailsPage({super.key, required this.local});

  @override
  _LocalDetailsPageState createState() => _LocalDetailsPageState();
}

class _LocalDetailsPageState extends State<LocalDetailsPage> {
  bool isFavorited = false;
  List<Map<String, dynamic>> avaliacoes = []; // Lista de avaliações
  String? nomeUsuario; // Nome do usuário logado

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _carregarAvaliacoes(); // Carregar avaliações ao iniciar
    _carregarNomeUsuario(); // Carregar o nome do usuário
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

  Future<void> _checkIfFavorited() async {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    bool favoritado = await localController.favoritosService
        .checkIfFavoritoExists(widget.local.id);
    setState(() {
      isFavorited = favoritado;
    });
  }

  Future<void> _salvarAvaliacaoNoFirestore(Map<String, dynamic> avaliacao,
      {String? docId}) async {
    final user = await _verificarUsuarioAutenticado();
    if (user == null) return;

    final avaliacoesRef = _obterReferenciasAvaliacoes();

    try {
      await _salvarOuAtualizarAvaliacao(
          avaliacoesRef, avaliacao, docId, user.uid);
      _exibirMensagemSucesso();
    } catch (e) {
      _exibirMensagemErro(e);
    }
  }

  /// Verifica se o usuário está autenticado.
  Future<User?> _verificarUsuarioAutenticado() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _exibirMensagemErro('Usuário não autenticado.');
    }
    return user;
  }

  /// Obtém a referência do Firestore para a coleção de avaliações.
  CollectionReference<Map<String, dynamic>> _obterReferenciasAvaliacoes() {
    final localId = widget.local.id;
    return FirebaseFirestore.instance
        .collection('locais')
        .doc(localId)
        .collection('avaliacoes');
  }

  /// Salva ou atualiza a avaliação no Firestore.
  Future<void> _salvarOuAtualizarAvaliacao(
    CollectionReference<Map<String, dynamic>> avaliacoesRef,
    Map<String, dynamic> avaliacao,
    String? docId,
    String userId,
  ) async {
    final data = {
      'userId': userId,
      'nomeUsuario': avaliacao['local'],
      'comentario': avaliacao['comentario'],
      'estrelas': avaliacao['estrelas'],
      'data': FieldValue.serverTimestamp(),
    };

    if (docId != null) {
      // Atualiza a avaliação existente
      await avaliacoesRef.doc(docId).update(data);
    } else {
      // Adiciona uma nova avaliação
      await avaliacoesRef.add(data);
    }
  }

  /// Exibe uma mensagem de sucesso.
  void _exibirMensagemSucesso() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação salva!')),
    );
  }

  /// Exibe uma mensagem de erro.
  void _exibirMensagemErro(dynamic erro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao salvar avaliação: $erro')),
    );
  }

  Future<void> _carregarAvaliacoes() async {
    final localId = widget.local.id;
    final avaliacoesRef = FirebaseFirestore.instance
        .collection('locais')
        .doc(localId)
        .collection('avaliacoes');

    try {
      final querySnapshot = await avaliacoesRef.get();
      setState(() {
        avaliacoes = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "local": data['nomeUsuario'],
            "comentario": data['comentario'],
            "estrelas": data['estrelas'],
          };
        }).toList();
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
    final avaliacoesRef = FirebaseFirestore.instance
        .collection('locais')
        .doc(localId)
        .collection('avaliacoes');

    // Consulta para verificar se o usuário já avaliou este local
    final querySnapshot =
        await avaliacoesRef.where('userId', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty && index == null) {
      // Se já existe uma avaliação e o usuário tenta adicionar outra, bloqueia
      final avaliacaoExistente = querySnapshot.docs.first;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Você já avaliou este local.'),
        ),
      );
      return;
    }

    if (index != null) {
      final avaliacao = avaliacoes[index];
      final nomeUsuarioAvaliacao = avaliacao['local'];

      if (nomeUsuario != nomeUsuarioAvaliacao) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Você não tem permissão para editar esta avaliação.')),
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
              final localId = widget.local.id;
              final avaliacoesRef = FirebaseFirestore.instance
                  .collection('locais')
                  .doc(localId)
                  .collection('avaliacoes');

              if (index != null) {
                // Obtém o ID do documento existente
                final querySnapshot = await avaliacoesRef
                    .where('comentario',
                        isEqualTo: avaliacoes[index]["comentario"])
                    .where('nomeUsuario', isEqualTo: avaliacoes[index]["local"])
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  final docId = querySnapshot.docs.first.id;
                  await _salvarAvaliacaoNoFirestore(avaliacao, docId: docId);
                }
              } else {
                await _salvarAvaliacaoNoFirestore(avaliacao);
              }

              setState(() {
                if (index != null) {
                  avaliacoes[index] = avaliacao;
                } else {
                  avaliacoes.add(avaliacao);
                }
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
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
                  _buildAddToItineraryButton(),
                  const SizedBox(height: 24),
                  // Seção de avaliações
                  const Text(
                    'Avaliações',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        return Dismissible(
                          key: Key(avaliacao[
                              "comentario"]), // Chave única para cada avaliação
                          direction: DismissDirection
                              .endToStart, // Deslize da direita para a esquerda
                          background: Container(
                            color: Colors.red, // Fundo vermelho
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          /// **Novo: confirmDismiss impede remoção indevida**
                          confirmDismiss: (direction) async {
                            if (nomeUsuario == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Erro: Nome do usuário não encontrado.')),
                              );
                              return false; // Impede a remoção
                            }

                            final nomeUsuarioAvaliacao = avaliacao["local"];

                            if (nomeUsuario != nomeUsuarioAvaliacao) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Você não tem permissão para excluir esta avaliação.')),
                              );
                              return false; // Impede a remoção
                            }

                            return true; // Permite a remoção
                          },

                          /// **onDismissed só será chamado se confirmDismiss retornar true**
                          onDismissed: (direction) async {
                            setState(() {
                              avaliacoes.removeAt(index);
                            });

                            final localId = widget.local.id;
                            final avaliacoesRef = FirebaseFirestore.instance
                                .collection('locais')
                                .doc(localId)
                                .collection('avaliacoes');

                            try {
                              final querySnapshot = await avaliacoesRef
                                  .where('comentario',
                                      isEqualTo: avaliacao["comentario"])
                                  .where('nomeUsuario',
                                      isEqualTo: avaliacao["local"])
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                await querySnapshot.docs.first.reference
                                    .delete();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Avaliação excluída.'),
                                  action: SnackBarAction(
                                    label: 'Desfazer',
                                    onPressed: () async {
                                      setState(() {
                                        avaliacoes.insert(index, avaliacao);
                                      });

                                      await avaliacoesRef.add({
                                        'userId': FirebaseAuth
                                            .instance.currentUser!.uid,
                                        'nomeUsuario': avaliacao["local"],
                                        'comentario': avaliacao["comentario"],
                                        'estrelas': avaliacao["estrelas"],
                                        'data': FieldValue.serverTimestamp(),
                                      });
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Erro ao excluir avaliação: $e')),
                              );
                            }
                          },

                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              onTap: () => abrirTelaAvaliacao(index: index),
                              title: Text(
                                avaliacao["local"],
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    avaliacao["comentario"],
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < avaliacao["estrelas"]
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  // Botão para adicionar avaliação
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
        background: Image.network(
          widget.local.imagem,
          fit: BoxFit.cover,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
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
          backgroundImage: NetworkImage(widget.local.imagem),
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

  Widget _buildAddToItineraryButton() {
    return ElevatedButton(
      onPressed: () {
        _showItineraryBottomSheet(context);
      },
      style: ElevatedButton.styleFrom(
        side: BorderSide(color: Color(0xFF266B70), width: 2),
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Color(0xFF266B70),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Adicionar a Itinerário',
        style: TextStyle(color: Colors.white),
      ),
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
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
          tooltip: 'Perfil',
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
  final String nomeUsuario; // Nome do usuário
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
        "local": widget.nomeUsuario, // Usar o nome do usuário
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
