import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<Map<String, dynamic>> messages = [
    {'from': 'bot', 'text': 'Hello! How can I help you today?'},
  ];

  final List<String> _suggestedQuestions = [
    'Where is the parking slot?',
    'Who are the creators of this app?',
    'What are the app features?',
    'How to update my profile?',
    'Can I register multiple vehicles?',
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  void _handleSend() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({'from': 'user', 'text': input});
      _isTyping = true;
    });

    _controller.clear();

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    await Future.delayed(const Duration(seconds: 3));

    final lowerInput = input.toLowerCase();
    String reply;

    if (lowerInput.contains('hi') || lowerInput.contains('hello') || lowerInput.contains('hey')) {
      reply = 'Good day ma\'am or sir!';
    } else if (lowerInput.contains('how to use') ||
        lowerInput.contains('how do i use') ||
        lowerInput.contains('instructions') ||
        lowerInput.contains('what are the app features')) {
      reply = 'To use this app, you can register your vehicle, check parking slots, and get support right here. Feel free to explore the menu options!';
    } else if (lowerInput.contains('creator') || lowerInput.contains('who made') || lowerInput.contains('who are the creators')) {
      reply = 'This app was created by Looren, Carlo, and Abel.';
    } else if (lowerInput.contains('how to register a vehicle')) {
      reply = 'To register a vehicle, navigate to the Home screen and tap on "Register Vehicle". Follow the steps provided to input your details.';
    } else if (lowerInput.contains('where is the parking slot')) {
      reply = 'You can view available parking slots by going to the "Parking Slot" section in the bottom navigation bar.';
    } else if (lowerInput.contains('how to update my profile')) {
      reply = 'To update your profile, tap on the profile icon in the top-left corner of the home screen to open the drawer. You can view and potentially edit your details there.';
    } else if (lowerInput.contains('can i register multiple vehicles')) {
      reply = 'Yes, you can register multiple vehicles under your account. Follow the vehicle registration process for each vehicle.';
    } else {
      reply = 'We are currently updating our system. Please try again later.';
    }

    setState(() {
      _isTyping = false;
      messages.add({'from': 'bot', 'text': reply});
    });

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleSuggestedQuestionTap(String question) {
    _controller.text = question;
    _handleSend();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Support',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF004A8F),
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Column(
            children: [
              Image.asset('assets/valper_logo.png', height: 60),
              const SizedBox(height: 5),
              Text(
                'AI Chat Support',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/valper_logo.png'),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004A8F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const AnimatedDots(),
                        ),
                      ],
                    ),
                  );
                }

                final msg = messages[index];
                final isUser = msg['from'] == 'user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/valper_logo.png'),
                          radius: 16,
                        ),
                      if (!isUser) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.grey[400] : const Color(0xFF004A8F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['text'],
                            style: GoogleFonts.poppins(
                              color: isUser ? Colors.black : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                      if (isUser)
                        const CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          radius: 16,
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You may want to ask:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _suggestedQuestions.length,
              itemBuilder: (context, index) {
                final question = _suggestedQuestions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    onPressed: () => _handleSuggestedQuestionTap(question),
                    label: Text(
                      question,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF004A8F),
                      ),
                    ),
                    backgroundColor: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: const Color(0xFF004A8F).withOpacity(0.5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: GoogleFonts.poppins(),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotAnimation = StepTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (context, child) {
        final dots = '.' * _dotAnimation.value;
        return Text(
          'Typing$dots',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }
}