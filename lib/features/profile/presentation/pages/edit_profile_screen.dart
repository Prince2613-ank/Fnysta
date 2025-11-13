import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

enum Gender { male, female }

class _EditProfileScreenState extends State<EditProfileScreen> {
  Gender? _selectedGender = Gender.male;

  @override
  Widget build(BuildContext context) {
    // ⭐ UPDATE: Detect if the device is in dark mode.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ⭐ UPDATE: Set background color based on the theme.
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Blue background (remains the same for both themes)
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
            // All page content, including the custom header
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
            // ⭐ UPDATE: Card color based on theme.
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
                    // ⭐ UPDATE: Text color based on theme.
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
          child: CircleAvatar(
            radius: 50,
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            child: const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/logoo.png'),
            ),
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
        _buildTextField('Name', '', isDarkMode),
        _buildTextField('Username', '', isDarkMode),
        _buildTextField('Phone Number', '', isDarkMode),
        _buildTextField('Email ID', '', isDarkMode),
        _buildTextField('Date of Birth', '', isDarkMode),
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
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        // ⭐ UPDATE: Text style for input.
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          filled: true,
          // ⭐ UPDATE: Field background color.
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
          labelText: label,
          // ⭐ UPDATE: Label text color.
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
          // ⭐ UPDATE: Restored a larger negative offset to pull the button up.
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
}
