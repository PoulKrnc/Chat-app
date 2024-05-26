// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'package:pavli_text/start.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isProfileSet = false;
  var db = FirebaseFirestore.instance;
  final _nickNameController = TextEditingController();
  final _dateController = TextEditingController();
  String profilePicUrl = "";
  late Reference uploadRef;

  void setUserName() async {
    if (_nickNameController.text.trim().length > 15 ||
        _nickNameController.text.trim().length <= 5) {
      Utils.showSnackBar("Your username is either too long or too short.");
      return;
    } else {
      await db
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.email!)
          .set({
        "Nickname": _nickNameController.text.trim(),
        "DateOfBirth": _dateController.text.trim(),
      });
      await db
          .collection("nicknames")
          .doc(_nickNameController.text.trim())
          .set({
        "Nickname": _nickNameController.text.trim(),
        "DateOfBirth": _dateController.text.trim(),
        "Mail": FirebaseAuth.instance.currentUser!.email!,
        "ProfilePicUrl": profilePicUrl
      });
      setState(() {
        //refresh
      });
      checkIfExists();
    }
  }

  bool checked = false;

  void checkIfExists() async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email!)
        .get();
    if (!result.exists) {
      setState(() {
        isProfileSet = false;
        checked = true;
      });
      return;
    }
    var result1 = await FirebaseFirestore.instance
        .collection('nicknames')
        .doc(result.data()!["Nickname"])
        .get();
    if (result.exists && result1.exists) {
      setState(() {
        isProfileSet = result.exists;
      });
    }
    setState(() {
      checked = true;
    });
  }

  void uploadImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 65);
    if (file == null) {
      return;
    }

    String fileName = user.email!;
    Reference storageRef = FirebaseStorage.instance.ref();
    Reference imageRef = storageRef.child("profile_pictures");
    uploadRef = imageRef.child(fileName);

    printY(fileName);
    await uploadRef.putData(await file.readAsBytes());
    //await uploadRef.putFile(File(file.path));
    String picUrl = await uploadRef.getDownloadURL();
    printY(picUrl);
    setState(() {
      profilePicUrl = picUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfExists();
    _dateController.text = "";
  }

  @override
  Widget build(BuildContext context) =>
      isProfileSet ? const StartPage() : profileSetup();

  Widget profileSetup() {
    if (checked) {
      return Scaffold(
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Set up your profile",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 33,
                      color: Colors.blue),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                  padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Nickname"),
                    textAlign: TextAlign.center,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _nickNameController,
                  ),
                ),
                Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                    padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                        child: IntrinsicWidth(
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: _dateController,
                        decoration: const InputDecoration(
                            hintText: "Date of birth",
                            prefixIcon: Icon(Icons.calendar_today),
                            prefixIconColor: Colors.blue,
                            border: InputBorder.none),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100));

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          } else {}
                        },
                      ),
                    ))),
                GestureDetector(
                  onTap: uploadImage,
                  child: Container(
                      margin:
                          const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            const Spacer(),
                            CircleAvatar(
                                backgroundImage:
                                    Image.network(profilePicUrl).image),
                            const SizedBox(
                              width: 20,
                            ),
                            const Text("Upload Image",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            const Spacer(),
                          ],
                        ),
                      )),
                ),
                GestureDetector(
                  onTap: setUserName,
                  child: Container(
                      margin:
                          const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              "Next",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800]),
                            ),
                            const Icon(Icons.arrow_forward_outlined),
                            const Spacer()
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        )),
      );
    } else {
      return Utils.loadingScaffold();
    }
  }
}
