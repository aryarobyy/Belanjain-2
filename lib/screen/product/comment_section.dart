import 'package:belanjain/services/comment/comment_service.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String userId;
  final String productId;
  const CommentSection({
    super.key,
    required this.userId,
    required this.productId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _contentController = TextEditingController();

  void _handlePostComment( ) async {
    await CommentService().postComment(
      productId: widget.productId,
      content: _contentController.text.trim(),
      rating: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: dummyComments.length,
            itemBuilder: (BuildContext context, int index) {
              final comment = dummyComments[index];
              return ListTile(
                leading: const Icon(
                  Icons.person,
                  size: 40,
                ),
                title: Text(
                  comment['username'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                    ),
                    SizedBox(height: 4),
                    Text(comment['message1'] ?? ''),
                    SizedBox(height: 5,),
                    Text("Reply")
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // Handle send comment
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  final List<Map<String, String>> dummyComments = [
    {
      'username': 'Roby Aryanata',
      'date': 'Oct 2, 2024',
      'message1': 'Gimana ini 1 bulan baru sampe',
      'message2': 'You can add builder with map instead of list',
    },
    {
      'username': 'Firman',
      'date': 'Oct 3, 2024',
      'message1': 'Delicious',
      'message2': 'Helped me a lot with my project.',
    },
    {
      'username': 'Obud Item',
      'date': 'Oct 4, 2024',
      'message1': 'Enak',
      'message2': 'Looking forward to more content.',
    },
  ];


}
