import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingBarWidget extends StatefulWidget {
  final bool enable;
  final double rating;
  final double? itemSize;
  final void Function(double rating)? onRatingUpdate;
  const RatingBarWidget(
      {super.key,
      this.enable = false,
      this.rating = 0,
      this.itemSize,
      this.onRatingUpdate});

  @override
  State<RatingBarWidget> createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.enable
        ? StatefulBuilder(builder: (context, setState) {
            return RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              itemCount: 5,
              allowHalfRating: true,
              itemSize: widget.itemSize ?? 22.r,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                widget.onRatingUpdate?.call(rating);
                setState(() {});
              },
            );
          })
        : RatingBarIndicator(
            rating: widget.rating,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: widget.itemSize ?? 22.r,
          );
  }
}
