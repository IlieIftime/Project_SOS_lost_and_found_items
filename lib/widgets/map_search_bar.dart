import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget {
  final Function(String) onSubmitted;

  const MapSearchBar({super.key, required this.onSubmitted});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: 'Search...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              widget.onSubmitted(_textController.text);
            },
          ),
        ),
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
