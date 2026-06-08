import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RatingStars extends StatefulWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void didUpdateWidget(RatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating && !widget.interactive) {
      _currentRating = widget.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: widget.interactive
              ? () {
                  setState(() {
                    _currentRating = index + 1.0;
                  });
                  widget.onRatingChanged?.call(_currentRating);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              index < _currentRating.floor()
                  ? Icons.star_rounded
                  : (index < _currentRating
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded),
              color: AppColors.secondary,
              size: widget.interactive && index < _currentRating 
                  ? widget.size * 1.2 
                  : widget.size,
            ),
          ),
        );
      }),
    );
  }
}
