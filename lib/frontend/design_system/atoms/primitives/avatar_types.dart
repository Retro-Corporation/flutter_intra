import 'package:flutter/material.dart';

enum AvatarSize { xs, sm, md, lg, xl }

sealed class AvatarContent {
  const AvatarContent();
}

class AvatarImage extends AvatarContent {
  final ImageProvider image;
  const AvatarImage(this.image);
}

class AvatarInitials extends AvatarContent {
  final String initials;
  const AvatarInitials(this.initials);
}

class AvatarUpload extends AvatarContent {
  const AvatarUpload();
}
