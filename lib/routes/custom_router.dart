import "package:babylon_app/routes/custom_page_route.dart";
import "package:babylon_app/views/authentication/login_form.dart";
import "package:babylon_app/views/authentication/register_additional.dart";
import "package:babylon_app/views/authentication/register_form.dart";
import "package:babylon_app/views/authentication/register_picture.dart";
import "package:babylon_app/views/chats/chat_info.dart";
import "package:babylon_app/views/chats/chatting.dart";
import "package:babylon_app/views/chats/groupchat_create_form.dart";
import "package:babylon_app/views/chats/groupchat_edit_form.dart";
import "package:babylon_app/views/chats/groupchat_search.dart";
import "package:babylon_app/views/community/community.dart";
import "package:babylon_app/views/events/event_create_form.dart";
import "package:babylon_app/views/events/event_detail.dart";
import "package:babylon_app/views/events/event_update_form.dart";
import "package:babylon_app/views/events/events.dart";
import "package:babylon_app/views/forum/forum.dart";
import "package:babylon_app/views/forum/forum_topic.dart";
import "package:babylon_app/views/home.dart";
import "package:babylon_app/views/launch.dart";
import "package:babylon_app/views/layout.dart";
import "package:babylon_app/views/news/news.dart";
import "package:babylon_app/views/offers/offers.dart";
import "package:babylon_app/views/profile/full_screen_pfp.dart";
import "package:babylon_app/views/profile/my_account.dart";
import "package:babylon_app/views/profile/my_profile.dart";
import "package:babylon_app/views/profile/user_profile.dart";
import "package:babylon_app/views/radio/radio_screen.dart";
import "package:flutter/material.dart";

class CustomRouter {
  static Route<dynamic> generatePreLoginRoutes(final RouteSettings settings) {
    late Map<dynamic, dynamic>? arguments;
    if (settings.arguments != null) arguments = settings.arguments as Map;
    Route<dynamic> newRoute =
        CustomPageRoute(builder: (final _) => const Launch());
    switch (settings.name) {
      case "launch":
        newRoute = CustomPageRoute(builder: (final _) => const Launch());
      case "registerForm":
        newRoute = CustomPageRoute(builder: (final _) => const RegisterForm());
      case "registerPicture":
        newRoute =
            CustomPageRoute(builder: (final _) => const RegisterPicture());
      case "registerAdditional":
        newRoute =
            CustomPageRoute(builder: (final _) => const RegisterAdditional());
      case "loginForm":
        newRoute = CustomPageRoute(builder: (final _) => const LoginForm());
      case "layout":
        newRoute = CustomPageRoute(builder: (final _) => const Layout());
    }
    return newRoute;
  }

  static Route<dynamic> generatePostLoginRoutes(final RouteSettings settings) {
    late Map<dynamic, dynamic>? arguments;
    if (settings.arguments != null) arguments = settings.arguments as Map;
    Route<dynamic> newRoute =
        CustomPageRoute(builder: (final _) => const Home());
    switch (settings.name) {
      case "home":
        newRoute = CustomPageRoute(builder: (final _) => const Home());
      case "events":
        newRoute = CustomPageRoute(builder: (final _) => const Events());
      case "eventDetail":
        newRoute = CustomPageRoute(builder: (final _) => const EventDetail());
      case "eventCreateForm":
        newRoute =
            CustomPageRoute(builder: (final _) => const EventCreateForm());
      case "eventUpdateForm":
        newRoute =
            CustomPageRoute(builder: (final _) => const EventUpdateForm());
      case "myProfile":
        newRoute = CustomPageRoute(builder: (final _) => const MyProfile());
      case "myAccount":
        newRoute = CustomPageRoute(builder: (final _) => const MyAccount());
      case "userProfile":
        newRoute = CustomPageRoute(builder: (final _) => const UserProfile());
      case "fullScreenPFP":
        newRoute = CustomPageRoute(builder: (final _) => const FullScreenPFP());
      case "offers":
        newRoute = CustomPageRoute(builder: (final _) => const Offers());
      case "news":
        newRoute = CustomPageRoute(builder: (final _) => const News());
      case "radio":
        newRoute = CustomPageRoute(builder: (final _) => const RadioScreen());
      case "forum":
        newRoute = CustomPageRoute(builder: (final _) => const Forum());
      case "forumTopic":
        newRoute = CustomPageRoute(builder: (final _) => const ForumTopic());
      case "community":
        newRoute = CustomPageRoute(builder: (final _) => const Community());
      case "chatting":
        newRoute = CustomPageRoute(builder: (final _) => const Chatting());
      case "groupchatInfo":
        newRoute = CustomPageRoute(builder: (final _) => const GroupchatInfo());
      case "groupchatCreateForm":
        CustomPageRoute(builder: (final _) => const GroupchatCreateForm());
      case "groupchatUpdateForm":
        CustomPageRoute(builder: (final _) => const GroupchatUpdateForm());
      case "groupchatSearch":
        newRoute =
            CustomPageRoute(builder: (final _) => const GroupchatSearch());
    }

    return newRoute;
  }
}
