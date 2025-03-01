import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/controller/auth_controller.dart';
import 'package:flutter_application_1/services/firestore/user.service.dart' as user_service;
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_application_1/services/firestore/checklist.service.dart';
import 'package:fl_chart/fl_chart.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? _profileImageBase64;
  final user_service.UserService _userService = user_service.UserService();
  final AuthController _authController = AuthController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  final maskFormatter = UtilBrasilFields.obterCpf;
  bool _isEditing = false;

  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalItinerarios = 0;
  List<int> monthlyItineraries = List.filled(12, 0);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItinerarioId();
      _loadInsightsData();
    });
  }

  Future<void> _loadUserData() async {
    var userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        _firstNameController.text = userData['nome'];
        _emailController.text = userData['email'];
        _cpfController.text = maskFormatter(userData['cpf']);
        _profileImageBase64 = userData['profilePicture'];
      });
    }
  }

  Future<void> _loadItinerarioId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final itinerarioSnapshot = await FirebaseFirestore.instance
          .collection('viajantes')
          .doc(user.uid)
          .collection('itinerarios')
          .get();
      if (itinerarioSnapshot.docs.isNotEmpty) {
        setState(() {
          _totalItinerarios = itinerarioSnapshot.docs.length;
        });
        _loadTaskData(itinerarioSnapshot.docs);
      }
    }
  }

  Future<void> _loadTaskData(List<QueryDocumentSnapshot> itinerarios) async {
    int totalTasks = 0;
    int completedTasks = 0;

    for (var itinerario in itinerarios) {
      int itineraryTotalTasks = await _userService.getTotalTasks(itinerario.id);
      int itineraryCompletedTasks = await _userService.getCompletedTasks(itinerario.id);

      totalTasks += itineraryTotalTasks;
      completedTasks += itineraryCompletedTasks;
    }

    setState(() {
      _totalTasks = totalTasks;
      _completedTasks = completedTasks;
    });
  }

  Future<void> _loadInsightsData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final itinerariosSnapshot = await FirebaseFirestore.instance
          .collection('viajantes')
          .doc(user.uid)
          .collection('itinerarios')
          .get();

      List<int> monthlyCounts = List.filled(12, 0);
      for (var doc in itinerariosSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime startDate = (data['startDate'] as Timestamp).toDate();
        DateTime endDate = (data['endDate'] as Timestamp).toDate();
        
        if (startDate.year == DateTime.now().year) {
          monthlyCounts[startDate.month - 1]++;
        }
        
        if (endDate.year == DateTime.now().year && endDate.month != startDate.month) {
          monthlyCounts[endDate.month - 1]++;
        }
      }

      setState(() {
        _totalItinerarios = itinerariosSnapshot.docs.length;
        monthlyItineraries = monthlyCounts;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await _updateProfileImage(bytes);
    }
  }

  Future<void> _updateProfileImage(Uint8List imageBytes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      String base64image = base64Encode(imageBytes);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profilePicture': base64image,
      });
      setState(() {
        _profileImageBase64 = base64image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagem atualizada com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar imagem: $e');
    }
  }

  Future<void> _updateProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'nome': _firstNameController.text,
        'email': _emailController.text,
        'cpf': _cpfController.text,
      });

      // Se a imagem do perfil foi alterada, atualiza a imagem também
      if (_profileImageBase64 != null) {
        await _updateProfileImage(base64Decode(_profileImageBase64!));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil. Tente novamente.')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await _userService.deleteUserAccount();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta excluída com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Erro ao excluir conta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir conta. Tente novamente.')),
      );
    }
  }

  Widget _buildLineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF266B70),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gráfico de Itinerários Mensais',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(months[value.toInt()],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Poppins')),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontFamily: 'Poppins'));
                            },
                            interval: 1,
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY: (monthlyItineraries.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                      lineBarsData: [
                        LineChartBarData(
                          spots: monthlyItineraries.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: Colors.white,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTaskDashboard(),
              _buildInsightCard('Total de Itinerários', _totalItinerarios.toString()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildLineChart(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImageBase64 != null
                          ? MemoryImage(base64Decode(_profileImageBase64!))
                          : null,
                      child: _profileImageBase64 == null
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20), // Reduced height from 30 to 20
                  _isEditing
                      ? _buildTextField(_firstNameController, 'Nome')
                      : _buildInfoText(_firstNameController.text),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _isEditing,
                    child: Column(
                      children: [
                        _buildTextField(_emailController, 'Email'),
                        const SizedBox(height: 16),
                        _buildTextField(_cpfController, 'CPF'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    Column(
                      children: [
                        _buildPasswordResetButton(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildOutlinedButton('Cancelar', () {
                              setState(() {
                                _isEditing = false;
                              });
                            }),
                            const SizedBox(width: 12),
                            _buildElevatedButton('Salvar', () async {
                              await _updateProfileData();
                              setState(() {
                                _isEditing = false;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 10), 
                  if (!_isEditing) _buildDashboard(),
                  const SizedBox(height: 10), 
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            child: _isEditing
                ? _buildDeleteButton('Excluir Conta', () async {
                    await _deleteAccount();
                  })
                : _buildExitButton('Sair', () async {
                    await _authController.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDashboard() {
    double completedPercentage = _totalTasks > 0 ? (_completedTasks / _totalTasks) * 100 : 0;
    double remainingPercentage = 100 - completedPercentage;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF266B70), // Verde água
      elevation: 4,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45, 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks concluídas',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.white, // Texto em branco para contraste
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.white, // Parte concluída em branco
                              value: completedPercentage,
                              title: '${completedPercentage.toStringAsFixed(1)}%',
                              radius: 25,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF266B70), // Verde água
                                fontFamily: 'Poppins',
                              ),
                            ),
                            PieChartSectionData(
                              color: const Color(0xFF266B70), // Parte restante em verde água
                              value: remainingPercentage,
                              title: '${remainingPercentage.toStringAsFixed(1)}%',
                              radius: 25,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF266B70), // Verde água
      elevation: 4,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45, // Aproximadamente metade da tela
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.white, // Texto em branco para contraste
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto em branco para contraste
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return SizedBox(
      width: 250, // Diminuir a largura
      height: 48,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontFamily: 'Poppins'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Poppins'),
          filled: true,
          fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String value) {
  return SizedBox(
    width: 300,
    child: Text(
      value, 
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18, 
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold, 
      ),
    ),
  );
}

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF266B70),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Poppins'),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildExitButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(
            255, 198, 113, 107), // Cor específica para o botão "Sair"
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Poppins'),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildDeleteButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(
            255, 198, 113, 107), // Cor específica para o botão "Excluir Conta"
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Poppins'),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
  
  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF266B70), width: 1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Poppins'),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF266B70))),
    );
  }
  Widget _buildPasswordResetButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/senha');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF266B70),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Poppins'),
      ),
      child: const Text('Redefinir Senha', style: TextStyle(fontSize: 16)),
    );
  }

}
