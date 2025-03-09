import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AvaliacoesChart extends StatelessWidget {
  final List<int> estrelasCount; 

  const AvaliacoesChart({super.key, required this.estrelasCount});

  @override
  Widget build(BuildContext context) {
    int totalAvaliacoes = (estrelasCount.reduce((a, b) => a + b)); 
    int qtd = estrelasCount.length;
    int total = qtd + totalAvaliacoes;
    print(totalAvaliacoes
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, 
          width: 1.0, 
        ),
        borderRadius: BorderRadius.circular(8), 
      ),
      padding: const EdgeInsets.all(16), 
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: totalAvaliacoes.toDouble(), 
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
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
                          text: '${value.toInt()}', 
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, 
                          ),
                        ),
                      ],
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false), 
          gridData: FlGridData(show: false), 
          barGroups: List.generate(5, (index) {
            int quantidade = estrelasCount[index];

            return BarChartGroupData(
              x: index + 1,
              barRods: [
                
                BarChartRodData(
                  fromY: 0, 
                  toY: quantidade.toDouble(), 
                  color: Color(0xFF01A897), 
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}