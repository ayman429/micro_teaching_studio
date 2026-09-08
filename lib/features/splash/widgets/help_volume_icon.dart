import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HelpVolumeIcon extends StatelessWidget {
  const HelpVolumeIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.083,
            right: size * 0.333,
            top: size * 0.25,
            bottom: size * 0.25,
            child: SvgPicture.asset(
              Assets.assetsIconsHelpVolumeBody,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: size * 0.667,
            right: size * 0.083,
            top: size * 0.307,
            bottom: size * 0.31,
            child: SvgPicture.asset(
              Assets.assetsIconsHelpVolumeWave,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}
