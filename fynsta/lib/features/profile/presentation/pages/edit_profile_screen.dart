import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fynsta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:fynsta/features/profile/data/models/user_update_model.dart';
import 'package:fynsta/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fynsta/features/profile/domain/usecases/update_user_profile.dart';
import 'package:fynsta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fynsta/features/profile/presentation/bloc/profile_event.dart';
import 'package:fynsta/features/profile/presentation/bloc/profile_state.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        updateUserProfile: UpdateUserProfile(
          ProfileRepositoryImpl(
            remoteDataSource:
                ProfileRemoteDataSourceImpl(client: http.Client()),
          ),
        ),
      ),
      child: const _EditProfileScreenView(),
    );
  }
}

class _EditProfileScreenView extends StatefulWidget {
  const _EditProfileScreenView();

  @override
  State<_EditProfileScreenView> createState() => _EditProfileScreenViewState();
}

enum Gender { male, female }

class _EditProfileScreenViewState extends State<_EditProfileScreenView> {
  Gender? _selectedGender = Gender.male;
  File? _profileImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Pop the screen and return 'true' to signal a successful update
            Navigator.of(context).pop(true);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildCustomAppBar(context),
                    const SizedBox(height: 70), // Space between header and card
                    _buildProfileHeaderCard(isDarkMode),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 34.0),
                      child: _buildForm(isDarkMode),
                    ),
                    _buildMoreInfo(isDarkMode),
                    _buildFeedbackSection(isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          const SizedBox(width: 58),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard(bool isDarkMode) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(45, 60, 45, 30),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                'Last Seen Today 3 PM',
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatItem(label: 'Followers', value: '23K'),
                      const SizedBox(width: 14),
                      _buildStatItem(label: 'Coins', value: '300'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -50,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) as ImageProvider
                      : const AssetImage('assets/logoo.png'),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[900]! : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    bool isCoin = label == 'Coins';
    bool isFollower = label == 'Followers';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 9),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 217, 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFollower)
                const Icon(Icons.person, color: Colors.black87, size: 18),
              if (isFollower) const SizedBox(width: 4),
              if (isCoin)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.circle,
                        color: const Color.fromARGB(255, 230, 115, 0),
                        size: 18),
                    const Text('₹',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              if (isCoin) const SizedBox(width: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildForm(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Name', 'Enter your name', _nameController, isDarkMode),
        _buildTextField(
            'Username', 'Enter your username', _usernameController, isDarkMode),
        _buildTextField('Phone Number', 'Enter your phone number',
            _phoneController, isDarkMode),
        _buildTextField(
            'Email ID', 'Enter your email', _emailController, isDarkMode),
        _buildTextField('Date of Birth', 'Enter your date of birth',
            _dobController, isDarkMode),
        Text('Gender',
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
        Row(
          children: [
            Radio<Gender>(
              value: Gender.male,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            Text('Male',
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            Radio<Gender>(
              value: Gender.female,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            Text('Female',
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ElevatedButton(
                onPressed: () {
                  final userUpdateModel = UserUpdateModel(
                    email: _emailController.text,
                    username: _usernameController.text,
                    phoneNumber: _phoneController.text,
                    dob: _dobController.text,
                    gender: _selectedGender == Gender.male ? 'M' : 'F',
                  );
                  context.read<ProfileBloc>().add(
                      UpdateProfileEvent(userUpdateModel: userUpdateModel));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Submit',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hintText,
      TextEditingController controller, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
          labelText: label,
          hintText: hintText,
          labelStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildMoreInfo(bool isDarkMode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('More info',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  color: isDarkMode ? Colors.white : Colors.black)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoButton('Rewards')),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoButton('Leaderboard')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoButton('Responsible Play')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildInfoButton(
                      'More Policies\nT&C, Disclaimer,\nPrivacy Policy,\nContest')),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -42),
            child: Row(
              children: [
                Expanded(child: _buildInfoButton('Legality')),
                const SizedBox(width: 10),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        alignment: Alignment.center,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildFeedbackSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('Feedback',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black)),
          const SizedBox(height: 10),
          Text('Give us a feedback!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDarkMode ? Colors.white : Colors.black)),
          const Text(
            'Your input is important for us. We take customer feedback very seriously.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.sentiment_very_dissatisfied,
                  size: 40, color: isDarkMode ? Colors.grey[600] : Colors.grey),
              Icon(Icons.sentiment_dissatisfied,
                  size: 40, color: isDarkMode ? Colors.grey[600] : Colors.grey),
              Icon(Icons.sentiment_neutral,
                  size: 40, color: isDarkMode ? Colors.grey[600] : Colors.grey),
              Icon(Icons.sentiment_satisfied,
                  size: 40, color: isDarkMode ? Colors.grey[600] : Colors.grey),
              Icon(Icons.sentiment_very_satisfied,
                  size: 40, color: isDarkMode ? Colors.grey[600] : Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Add a comment',
              hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54),
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit Feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
