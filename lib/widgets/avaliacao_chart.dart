import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AvaliacoesChart extends StatelessWidget {
  final List<int> estrelasCount;

  const AvaliacoesChart({super.key, required this.estrelasCount});

  @override
  Widget build(BuildContext context) {
    int totalAvaliacoes = (estrelasCount.reduce((a, b) => a + b)); 
    double meioY;
    if (totalAvaliacoes == 1) {
      meioY = 1;  
    } else if (totalAvaliacoes % 2 == 0) {
      meioY = totalAvaliacoes / 2;  
    } else {
      meioY = (totalAvaliacoes / 2).floorToDouble();  
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),  
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: totalAvaliacoes.toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String label = (6 - value.toInt()).toString();
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '★',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                          ),
                        ),
                        TextSpan(
                          text: label,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF266B70),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                reservedSize: 15,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,  
                getTitlesWidget: (value, meta) {
                  
                  if (value == 0) {
                    return Text(
                      '0',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF266B70),
                      ),
                    );
                  } else if (value == meioY) {
                    return Text(
                      meioY.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF266B70),
                      ),
                    );
                  } else if (value == totalAvaliacoes) {
                    return Text(
                      totalAvaliacoes.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF266B70),
                      ),
                    );
                  } else {
                    return Container(); 
                  }
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: List.generate(5, (index) {
            int quantidade = estrelasCount[4 - index];

            return BarChartGroupData(
              x: index + 1,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: quantidade.toDouble(),
                  color: Colors.amber.withOpacity(0.5),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: Colors.amber, 
                    width: 2, 
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}