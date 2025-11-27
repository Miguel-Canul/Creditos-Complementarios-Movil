import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String _imageUrlPlaceholder =
      'https://yt3.googleusercontent.com/K7DvodCSwUravld3sfWgVCF_uhWgmgYh5MLPDvv7htu5xxZbIJr_qXVkZT68mxgZTiAdXpM1GQk=s900-c-k-c0x00ffffff-no-rj';

  const CustomSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: const Color(Constants.primaryColor),
      elevation: 4,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16.0,
      title: _buildTitle(),
      actions: _buildActions(),
    );
  }

// 1. Método para construir el TÍTULO
// .
  Widget _buildTitle() {
    return const Text(
      'Créditos complementarios',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

// 2. Método para construir el AVATAR (Acciones)
  List<Widget> _buildActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: ClipOval(
          child: Image.network(
            _imageUrlPlaceholder,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  }
}
