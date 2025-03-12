import 'package:flutter/material.dart';

class StarRatingSlider extends StatelessWidget {
  final double rating;
  final Function(double) onChanged;

  const StarRatingSlider({
    Key? key,
    required this.rating,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),

        ),
        Slider(
          value: rating,
          activeColor: Color(0xFF01A897),
          inactiveColor: Colors.grey.withOpacity(0.4),
          min: 0,
          max: 5,
          divisions: 10,
          label: rating.round().toString(),
          onChanged: onChanged,
          thumbColor: Color(0xFF01A897),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical:2.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '★', 
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.amber,
                  ),
                ),
                TextSpan(
                  text: ' ${rating.toStringAsFixed(1)}', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontFamily: 'Poppins', 
                    fontWeight: FontWeight.bold, 
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}