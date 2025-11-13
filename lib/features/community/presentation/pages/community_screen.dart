import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLiked = false;
  int _viewCount = 6578667;
  static const String _likeKey = 'post_liked';
  static const String _viewCountKey = 'post_view_count';

  @override
  void initState() {
    super.initState();
    _loadLikeState();
  }

  Future<void> _loadLikeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLiked = prefs.getBool(_likeKey) ?? false;
      _viewCount = prefs.getInt(_viewCountKey) ?? 6578667;
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _viewCount++;
      } else {
        _viewCount--;
      }
      prefs.setBool(_likeKey, _isLiked);
      prefs.setInt(_viewCountKey, _viewCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockEdge Social'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterChips(),
            _buildPostCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('Travel', isSelected: true),
            _buildChip('Movies'),
            _buildChip('Gaming'),
            _buildChip('Crypto'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Priyanshu Gupta',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Icon(Icons.check_circle, color: Colors.blue, size: 16),
                      ],
                    ),
                    Text('Posted on Trading Ideas',
                        style: theme.textTheme.bodySmall),
                    Text('3 hours ago', style: theme.textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Follow'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color, fontSize: 16),
                children: const [
                  TextSpan(
                      text: '\$Nifty 50 ',
                      style: TextStyle(color: Colors.blue)),
                  TextSpan(
                      text:
                          'fall was inversely proportional to DXY rise till mid of Jan, But DXY peaked out near 110 in Mid Jan. But now Nifty having positive correlation, not rising\n\nWill we see rise in Indian market and see natural inverse correlation to prevail ?'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset('assets/stock2.png'), // Placeholder
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    // ⭐ FIX: Use the theme's default icon color when not liked
                    color: _isLiked ? Colors.red : theme.iconTheme.color,
                  ),
                  onPressed: _toggleLike,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline),
                const SizedBox(width: 16),
                const Icon(Icons.send_outlined),
                const Spacer(),
                Text('${_viewCount.toString()} views',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
