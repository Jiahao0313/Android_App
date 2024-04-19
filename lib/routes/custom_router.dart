import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/event.dart";
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
  static Route<dynamic>? generatePreLoginRoutes(final RouteSettings settings) {
    CustomPageRoute(builder: (final _) => const Launch());
    switch (settings.name) {
      case "launch":
        return CustomPageRoute(builder: (final _) => const Launch());
      case "registerForm":
        return CustomPageRoute(builder: (final _) => const RegisterForm());
      case "registerPicture":
        return CustomPageRoute(builder: (final _) => const RegisterPicture());
      case "registerAdditional":
        return CustomPageRoute(
            builder: (final _) => const RegisterAdditional());
      case "loginForm":
        return CustomPageRoute(builder: (final _) => const LoginForm());
      case "layout":
        return CustomPageRoute(builder: (final _) => const Layout());
    }
    return null;
  }

  static Route<dynamic>? generatePostLoginRoutes(final RouteSettings settings) {
    switch (settings.name) {
      case "home":
        return CustomPageRoute(
            builder: (final _) => Home(
                updateSelectedMenuIndexCallback:
                    settings.arguments as Function));
      case "events":
        return CustomPageRoute(builder: (final _) => const Events());
      case "eventDetail":
        return CustomPageRoute(
            builder: (final _) => EventDetail(
                  event: settings.arguments as Event,
                ));
      case "eventCreateForm":
        return CustomPageRoute(builder: (final _) => const EventCreateForm());
      case "eventUpdateForm":
        return CustomPageRoute(builder: (final _) => const EventUpdateForm());
      case "myProfile":
        return CustomPageRoute(builder: (final _) => const MyProfile());
      case "myAccount":
        return CustomPageRoute(builder: (final _) => const MyAccount());
      case "userProfile":
        return CustomPageRoute(
            builder: (final _) => UserProfile(
                  user: settings.arguments as BabylonUser,
                ));
      case "fullScreenPFP":
        return CustomPageRoute(builder: (final _) => const FullScreenPFP());
      case "offers":
        return CustomPageRoute(builder: (final _) => const Offers());
      case "news":
        return CustomPageRoute(builder: (final _) => const News());
      case "radio":
        return CustomPageRoute(builder: (final _) => const RadioScreen());
      case "forum":
        return CustomPageRoute(builder: (final _) => const Forum());
      case "forumTopic":
        return CustomPageRoute(builder: (final _) => const ForumTopic());
      case "community":
        return CustomPageRoute(builder: (final _) => const Community());
      case "chatting":
        return CustomPageRoute(builder: (final _) => const Chatting());
      case "groupchatInfo":
        return CustomPageRoute(builder: (final _) => const GroupchatInfo());
      case "groupchatCreateForm":
        return CustomPageRoute(
            builder: (final _) => const GroupchatCreateForm());
      case "groupchatUpdateForm":
        return CustomPageRoute(
            builder: (final _) => const GroupchatUpdateForm());
      case "groupchatSearch":
        return CustomPageRoute(builder: (final _) => const GroupchatSearch());
    }
    return null;
  }
}
