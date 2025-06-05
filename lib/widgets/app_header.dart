// lib/widgets/app_header.dart
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    required this.title,
    this.imageUrl,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // <— garante não ficar embaixo da status bar
      bottom: false, // não adiciona padding na parte de baixo
      child: Container(
        height: kToolbarHeight,
        color: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                child:
                    imageUrl == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
