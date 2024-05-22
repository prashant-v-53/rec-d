import 'package:flutter/material.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/view_profile.dart';
import 'package:recd/pages/homepage/bookmarks/bookmark_details_screen.dart';
import 'package:recd/pages/homepage/bookmarks/show_more_bookmark_screen.dart';
import 'package:recd/pages/homepage/explore/category_list/category_info.dart';
import 'package:recd/pages/homepage/explore/contact/contacts_screen.dart';
import 'package:recd/pages/homepage/explore/contact/home_contacts_screen.dart';
import 'package:recd/pages/homepage/explore/rate_item/rate_item_screen.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/auth/forget_password_screen.dart';
import 'package:recd/pages/auth/otp_verification_screen.dart';
import 'package:recd/pages/auth/reset_password_screen.dart';
import 'package:recd/pages/auth/selection_screen.dart';
import 'package:recd/pages/auth/sign_in_screen.dart';
import 'package:recd/pages/auth/sign_up_screen.dart';
import 'package:recd/pages/auth/splash_screen.dart';
import 'package:recd/pages/homepage/bookmarks/add_to_bookmark_screen.dart';
import 'package:recd/pages/homepage/bookmarks/bookmarks_screen.dart';
import 'package:recd/pages/homepage/bookmarks/save_to_bookmark_screen.dart';
import 'package:recd/pages/homepage/explore/explore_screen.dart';
import 'package:recd/pages/homepage/explore/search/search_result_screen.dart';
import 'package:recd/pages/homepage/explore/see_all/see_all.dart';
import 'package:recd/pages/homepage/explore/send_reco/send_reco_screen.dart';
import 'package:recd/pages/homepage/explore/view_item/view_item_with_out_rate_screen.dart';
import 'package:recd/pages/homepage/explore/view_item/view_item_with_rate_screen.dart';
import 'package:recd/pages/homepage/home/add_friend/add_friend_screen.dart';
import 'package:recd/pages/homepage/home/group/create_group_screen.dart';
import 'package:recd/pages/homepage/home/group/group_participants_ev.dart';
import 'package:recd/pages/homepage/home/group/group_recommended_screen.dart';
import 'package:recd/pages/homepage/home/group/group_selection_screen.dart';
import 'package:recd/pages/homepage/bottombar_screen.dart';
import 'package:recd/pages/homepage/home/home_screen.dart';
import 'package:recd/pages/homepage/profile/edit_profile_screen.dart';
import 'package:recd/pages/homepage/profile/friends_request_screen.dart';
import 'package:recd/pages/homepage/profile/friends_screen.dart';
import 'package:recd/pages/homepage/profile/groups_screen.dart';
import 'package:recd/pages/homepage/profile/profile_screen.dart';
import 'package:recd/pages/homepage/profile/recdby_friends_list_screen.dart';
import 'package:recd/pages/homepage/profile/recs_deatils_screen.dart';
import 'package:recd/pages/homepage/trending/books/book_screen.dart';
import 'package:recd/pages/homepage/trending/podcast/podcast_screen.dart';
import 'package:recd/pages/homepage/trending/trending_screen.dart';
import 'package:recd/pages/homepage/trending/tv_show/tv_show_screen.dart';
import 'package:recd/pages/notification/notification_screen.dart';
import 'package:recd/pages/user/add_bio_screen.dart';
import 'package:recd/pages/user/select_profile.dart';
import 'package:recd/pages/user/user_contact.dart';

class RouteGenrator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case RouteKeys.SPLASH:
        return MaterialPageRoute(builder: (_) => SplashScreen());
        break;
      case RouteKeys.SLECTION_SIGN_IN_UP:
        return MaterialPageRoute(builder: (_) => SignInUpSelection());
        break;
      case RouteKeys.SIGN_IN:
        return MaterialPageRoute(builder: (_) => SignInScreen());
        break;
      case RouteKeys.SIGN_UP:
        return MaterialPageRoute(builder: (_) => SignUpScreen());
        break;
      case RouteKeys.SELECT_PROFILE:
        return MaterialPageRoute(builder: (_) => SelectProfileScreen());
        break;
      case RouteKeys.ADD_BIO:
        return MaterialPageRoute(builder: (_) => AddBioScreen());
        break;
      case RouteKeys.FORGET_PASSWORD:
        return MaterialPageRoute(builder: (_) => ForgetPasswordScreen());
        break;
      case RouteKeys.OTP_VERIFICATION:
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            routeArgument: args as RouteArgument,
          ),
        );
        break;
      case RouteKeys.RESET_PASSWORD:
        return MaterialPageRoute(
            builder: (_) =>
                ResetPasswordScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.BOTTOMBAR:
        return MaterialPageRoute(
            builder: (_) =>
                BottomBarScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.TRENDING:
        return MaterialPageRoute(builder: (_) => TrendingScreen());
        break;
      case RouteKeys.BOOKMARKS:
        return MaterialPageRoute(
            builder: (_) =>
                BookMarksScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.PROFILE:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
        break;
      case RouteKeys.EDIT_PROFILE:
        return MaterialPageRoute(
            builder: (_) =>
                EditProfileScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.CREATE_BOOKMARK:
        return MaterialPageRoute(
            builder: (_) =>
                CreateBookmarkScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.BOOKMARK_LIST:
        return MaterialPageRoute(
            builder: (_) =>
                SaveToBookmarkScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.HOME:
        //786
        return MaterialPageRoute(builder: (_) => HomeScreen());
        // return MaterialPageRoute(builder: (_) => NewHomeScreen());
        break;
      case RouteKeys.HOME_CONTACT:
        return MaterialPageRoute(builder: (_) => HomeContactScreen());
        break;
      case RouteKeys.NOTIFICATION:
        return MaterialPageRoute(builder: (_) => NotificationScreen());
        break;
      case RouteKeys.GROUP_SELECTION:
        return MaterialPageRoute(builder: (_) => GroupSelectionScreen());
        break;
      case RouteKeys.GROUP_PARTICIPANTS_EV:
        return MaterialPageRoute(
          builder: (_) => GroupParticipantsEVScreen(
            routeArgument: args as RouteArgument,
          ),
        );
        break;
      case RouteKeys.ADD_FRIENDS:
        return MaterialPageRoute(
            builder: (_) =>
                AddFriendScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.EXPLORE:
        return MaterialPageRoute(builder: (_) => ExploreScreen());
        break;
      case RouteKeys.CREATE_GROUP:
        return MaterialPageRoute(
            builder: (_) =>
                CreateGroupScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.GROUP_RECOMMENDED:
        return MaterialPageRoute(
            builder: (_) =>
                GroupRecommendedScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.SEND_RECO:
        return MaterialPageRoute(
            builder: (_) =>
                SendRecommendationScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.RATEITEM:
        return MaterialPageRoute(
          builder: (_) => RateItemScreen(routeArgument: args as RouteArgument),
        );
        break;
      case RouteKeys.CONTACT:
        return MaterialPageRoute(
            builder: (_) =>
                ContactScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.SEE_ALL:
        return MaterialPageRoute(
          builder: (_) => SeeAllScreen(routeArgument: args as RouteArgument),
        );
        break;
      case RouteKeys.VIEW_ITEM_WITH_RATE:
        return MaterialPageRoute(
          builder: (_) =>
              ViewItemWithRateScreen(routeArgument: args as RouteArgument),
        );
        break;
      case RouteKeys.VIEW_ITEM_WITH_OUT_RATE:
        return MaterialPageRoute(
            builder: (_) => ViewItemWithOutRateScreen(
                routeArgument: args as RouteArgument));
        break;

      case RouteKeys.SHOW_MORE:
        return MaterialPageRoute(builder: (_) => ShowMoreBookMarkScreen());
        break;

      case RouteKeys.BOOKMARKDETAILS:
        return MaterialPageRoute(
            builder: (_) =>
                BookMarkDetailScreen(routeArgument: args as RouteArgument));
        break;

      case RouteKeys.VIEW_TVSHOW_WITH_RATE:
        return MaterialPageRoute(
            builder: (_) =>
                ViewTvShowScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.RECD_BY_FRIEND_LIST:
        return MaterialPageRoute(
            builder: (_) =>
                RecdByFriendListScreen(routeArgument: args as RouteArgument));
        break;

      case RouteKeys.VIEW_PODCAST_WITH_RATE:
        return MaterialPageRoute(
          builder: (_) =>
              ViewPodCastScreen(routeArgument: args as RouteArgument),
        );
        break;
      case RouteKeys.VIEW_BOOK_WITH_RATE:
        return MaterialPageRoute(
            builder: (_) =>
                ViewBookScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.SEARCH:
        return MaterialPageRoute(
            builder: (_) =>
                SearchResultScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.VIEW_PROFILE:
        return MaterialPageRoute(
            builder: (_) => ViewProfile(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.FRIEND_REQUEST:
        return MaterialPageRoute(
            builder: (_) =>
                FriendRequestScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.GET_FRIENDS:
        return MaterialPageRoute(
            builder: (_) =>
                FriendsScreen(routeArgument: args as RouteArgument));
        break;
      case RouteKeys.GET_GROUPS:
        return MaterialPageRoute(builder: (_) => GroupScreen());
        break;

      case RouteKeys.GET_RECS:
        return MaterialPageRoute(builder: (_) => RecsScreen());
        break;
      case RouteKeys.USER_CONTACT:
        return MaterialPageRoute(builder: (_) => UserContactScreen());
        break;

      case RouteKeys.CATEGORY_INFO:
        return MaterialPageRoute(
          builder: (_) =>
              CategoryInfoScreen(routeArgument: args as RouteArgument),
        );
        break;

      default:
        return MaterialPageRoute(
          builder: (_) => oops(),
        );
    }
  }
}
