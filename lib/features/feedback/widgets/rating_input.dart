import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RatingInput extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;

  const RatingInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
  });

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  String get _ratingLabel {
    if (_rating == 0) return 'Tap to rate';
    if (_rating <= 1) return 'Poor';
    if (_rating <= 2) return 'Fair';
    if (_rating <= 3) return 'Good';
    if (_rating <= 4) return 'Very Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1.0;
                });
                widget.onRatingChanged(_rating);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < _rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < _rating.floor() ? AppColors.secondary : Colors.grey.shade400,
                  size: index < _rating.floor() ? 52 : 44,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _ratingLabel,
            key: ValueKey<String>(_ratingLabel),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _rating == 0 ? Colors.grey : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
