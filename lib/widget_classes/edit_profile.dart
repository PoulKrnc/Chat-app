// ignore_for_file: use_build_context_synchronously

import 'package:pavli_text/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditProfile({super.key, required this.data});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final user = FirebaseAuth.instance.currentUser!;
  final storage = FirebaseStorage.instance;
  bool isProfileSet = false;
  var db = FirebaseFirestore.instance;
  final _dateController = TextEditingController();
  final _genderController = TextEditingController();
  final _quoteController = TextEditingController();
  String dropdownValue = "None";
  List<String> genders = ["Male", "Female", "None"];
  String profilePicUrl = "";
  late Reference uploadRef;
  late Map<String, dynamic> data1;
  bool setupReady = false;

  void editProfile() async {
    await db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email!)
        .update({
      "DateOfBirth": _dateController.text.trim(),
    });
    await db.collection("nicknames").doc(widget.data["Nickname"]).update({
      "DateOfBirth": _dateController.text.trim(),
      "Mail": FirebaseAuth.instance.currentUser!.email!,
      "ProfilePicUrl": profilePicUrl,
    });
    Navigator.pop(context);
  }

  void uploadImage() async {
    printY("uploadImge");
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 65);
    if (file == null) {
      printY("null");
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

  void setups() async {
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .get()
        .then((value) {
      setState(() {
        data1 = value.data()!;
        profilePicUrl = data1["ProfilePicUrl"];
        _dateController.text = data1["DateOfBirth"];
      });
    });
    setState(() {
      setupReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = "";
    _genderController.text = "";
    _quoteController.text = "";
    setups();
  }

  @override
  Widget build(BuildContext context) {
    if (!setupReady) {
      return Utils.loadingScaffold();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit profile"),
      ),
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                        margin:
                            const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(13),
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
                                  lastDate: DateTime.now());

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
                  ),
                ],
              ),
              GestureDetector(
                onTap: uploadImage,
                child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(13),
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
                onTap: editProfile,
                child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Center(
                      child: Row(
                        children: [
                          Spacer(),
                          Text(
                            "Update",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          Icon(Icons.arrow_forward_outlined),
                          Spacer()
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
