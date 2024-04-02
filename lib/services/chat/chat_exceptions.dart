import "dart:io";

class ChatException {
  static void validateUpdateOrCreateForm(
      {final String? adminUID,
      final List<String>? usersUID,
      final String? chatDescription,
      required final String chatName,
      final File? image}) {
    if (chatName == "") {
      throw ("The chat name is missing");
    }
    if(image == null){
      throw("The image is missing");
    }
  }
}
