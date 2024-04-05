import "package:babylon_app/services/chat/chat_service.dart";
import "package:flutter/material.dart";
import "../../models/chat.dart";

class SearchGroupChatView extends StatefulWidget {
  @override
  _SearchGroupChatViewState createState() => _SearchGroupChatViewState();
}

class _SearchGroupChatViewState extends State<SearchGroupChatView> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> allChat = [];

  late List<Chat> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  void fetchChats()async{
    final List<Chat> allChatData = await ChatService.getAllGroupChats();
    setState(() {
      allChat = allChatData;
      _filteredChats = allChatData;
    });

  }

  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() => _filteredChats = allChat);
    } else {
      setState(() {
        _filteredChats = allChat.where((final aChat) =>
            aChat.chatName!.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Group Chat"),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
                hintText: "Search...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filterChats('');
                    });
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredChats.length,
        itemBuilder: (context, index) {
          var chat = _filteredChats[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: CircleAvatar(
                backgroundImage:
                NetworkImage(chat.iconPath!), // Placeholder for group snapshot.
                radius: 25,
            ),
            title: Text(chat.chatName!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat.lastMessage != null ? chat.lastMessage!.message! : ""),
            onTap: () {
              // Define la acción al tocar un chat de grupo
            },
          );
        },
      ),
    );
  }
}
