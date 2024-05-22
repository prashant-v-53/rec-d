import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/user/user_contact_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/pages/common/common_widgets.dart';

class UserContactScreen extends StatefulWidget {
  UserContactScreen({Key key}) : super(key: key);

  @override
  _UserContactScreenState createState() => _UserContactScreenState();
}

class _UserContactScreenState extends StateMVC<UserContactScreen> {
  UserContactController _con;
  _UserContactScreenState() : super(UserContactController()) {
    _con = controller;
  }
  Iterable<Contact> userContacts;

  @override
  void initState() {
    super.initState();
    setState(() => _con.isContactLoading = true);
    getContacts();
  }

  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      userContacts = contacts;
      _con.isContactLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.PRIMARY_COLOR,
            ),
            onPressed: () {
              setState(() => _con.isContactLoading = true);
              getContacts();
            },
          )
        ],
        leading: leadingIcon(context: context),
        centerTitle: true,
        title: Text(
          'Contacts',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _con.isContactLoading
          ? Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    hBox(5.0),
                    Text("Contact sync"),
                  ],
                ),
              ),
            )
          : userContacts == null
              ? commonMsgFunc("No Contact")
              : ListView.builder(
                  itemCount: userContacts?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    Contact contact = userContacts?.elementAt(index);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 18),
                      leading: (contact.avatar != null &&
                              contact.avatar.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contact.avatar),
                            )
                          : CircleAvatar(
                              child: Text(contact.initials()),
                              backgroundColor: Theme.of(context).accentColor,
                            ),
                      title: Text(contact.displayName ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          InkWell(
                            onTap: () => shareInfo(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Invite",
                                style: TextStyle(
                                  color: AppColors.PRIMARY_COLOR,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
