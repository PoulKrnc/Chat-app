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
  bool isProfileSet = false;
  var db = FirebaseFirestore.instance;
  final _dateController = TextEditingController();
  //
  final _genderController = TextEditingController();
  final _quoteController = TextEditingController();
  String dropdownValue = "None";
  List<String> genders = ["Male", "Female", "None"];
  //
  String profilePicUrl = "";
  late Reference uploadRef;
  late Map<String, dynamic> data1;

  void editProfile() async {
    await db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email!)
        .update({
      "Date_born": _dateController.text.trim(),
    });
    await db.collection("nicknames").doc(widget.data["Nickname"]).update({
      "Date_born": _dateController.text.trim(),
      "Mail": FirebaseAuth.instance.currentUser!.email!,
      "ProfilePicUrl": profilePicUrl,
      "Gender": dropdownValue
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
        _dateController.text = data1["Date_born"];
        if (data1["Gender"] == "Male") {
          dropdownValue = "Male";
        } else if (data1["Gender"] == "Female") {
          dropdownValue = "Female";
        } else {
          dropdownValue = "None";
        }
      });
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
                            const EdgeInsetsDirectional.fromSTEB(25, 5, 5, 5),
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
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
                                border: InputBorder.none //label text of field
                                ),

                            readOnly: true,
                            //set it true, so that user will not able to edit text
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime.now());

                              if (pickedDate != null) {
                                //pickedDate output format => 2021-03-10 00:00:00.000
                                String formattedDate = DateFormat('yyyy-MM-dd')
                                    .format(
                                        pickedDate); //formatted date output using intl package =>  2021-03-16
                                setState(() {
                                  _dateController.text =
                                      formattedDate; //set output date to TextField value.
                                });
                              } else {}
                            },
                          ),
                        ))),
                  ),
                  //HHH
                  Expanded(
                    flex: 2,
                    child: Container(
                        margin:
                            const EdgeInsetsDirectional.fromSTEB(5, 5, 25, 5),
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: DropdownButton(
                            borderRadius: BorderRadius.circular(10),
                            items: genders.map((String gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            value: dropdownValue,
                          ),
                        )),
                  ),
                ],
              ),
              //HHH
              GestureDetector(
                onTap: uploadImage,
                child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
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
                              backgroundImage: profilePicUrl == ""
                                  ? const AssetImage(
                                      "assets/empty_profile_picture.jfif")
                                  : Image.network(profilePicUrl).image),
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
                      borderRadius: BorderRadius.circular(20),
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
