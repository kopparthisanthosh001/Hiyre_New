import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String applicationId;
  final String jobTitle;
  final String companyName;
  final String? companyLogo;

  const ChatScreen({
    super.key,
    required this.applicationId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService.instance;
  
  Map<String, dynamic>? _conversation;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get or create conversation
      final conversation = await _chatService.getConversationForApplication(widget.applicationId);
      
      if (conversation != null) {
        setState(() {
          _conversation = conversation;
        });
        await _loadMessages();
      } else {
        // Handle case where conversation doesn't exist
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading conversation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_conversation == null) return;

    try {
      final messages = await _chatService.getMessages(_conversation!['id']);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversation == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      final message = await _chatService.sendTextMessage(
        conversationId: _conversation!['id'],
        content: messageText,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendFile() async {
    if (_conversation == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final message = await _chatService.pickAndSendFile(_conversation!['id']);

      if (message != null) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      print('Error sending file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send file. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openFile(String fileUrl, String fileName) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fileUrl';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: $fileName'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          children: [
            // Company logo
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: widget.companyLogo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        widget.companyLogo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.business, color: Colors.grey[400], size: 4.w);
                        },
                      ),
                    )
                  : Icon(Icons.business, color: Colors.grey[400], size: 4.w),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.companyName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.jobTitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show more options
            },
            icon: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(4.w),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
                ),
                
                // Message input
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 15.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Send a message to the recruiter about this position',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCurrentUser = message['sender']['id'] == _chatService.currentUser?.id;
    final messageType = message['message_type'] as String;
    final createdAt = DateTime.parse(message['created_at']);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            // Sender avatar
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: message['sender']['profile_image_url'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        message['sender']['profile_image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, color: Colors.grey[500], size: 4.w);
                        },
                      ),
                    )
                  : Icon(Icons.person, color: Colors.grey[500], size: 4.w),
            ),
            SizedBox(width: 2.w),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 70.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.green : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
                border: !isCurrentUser ? Border.all(color: Colors.grey[200]!) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageType == 'text')
                    Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                      ),
                    )
                  else if (messageType == 'image')
                    _buildImageMessage(message)
                  else if (messageType == 'file')
                    _buildFileMessage(message, isCurrentUser),
                  
                  SizedBox(height: 1.h),
                  
                  // Timestamp
                  Text(
                    _formatTime(createdAt),
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white70 : Colors.grey[500],
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isCurrentUser) SizedBox(width: 2.w),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () => _openFile(message['file_url'], message['file_name'] ?? 'Image'),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 60.w,
          maxHeight: 40.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message['file_url'],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 20.h,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 20.h,
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey[400]),
                      Text('Failed to load image', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFileMessage(Map<String, dynamic> message, bool isCurrentUser) {
    final fileName = message['file_name'] ?? 'Unknown file';
    final fileSize = message['file_size'] ?? 0;
    
    return GestureDetector(
      onTap: () => _openFile(message['file_url'], fileName),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.white.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: isCurrentUser ? Colors.white : Colors.grey[600],
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ChatService.formatFileSize(fileSize),
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white70 : Colors.grey[500],
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: _isUploading ? null : _sendFile,
            icon: _isUploading
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[400],
                    ),
                  )
                : Icon(Icons.attach_file, color: Colors.grey[600]),
          ),
          
          // Message input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          SizedBox(width: 2.w),
          
          // Send button
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _messageController.text.trim().isNotEmpty && !_isSending
                    ? Colors.green
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(25),
              ),
              child: _isSending
                  ? Center(
                      child: SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: _messageController.text.trim().isNotEmpty
                          ? Colors.white
                          : Colors.grey[500],
                      size: 5.w,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}