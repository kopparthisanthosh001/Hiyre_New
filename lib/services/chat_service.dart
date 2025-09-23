import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  static ChatService get instance => _instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add this public getter
  User? get currentUser => _supabase.auth.currentUser;

  // Get conversation for a job application
  Future<Map<String, dynamic>?> getConversationForApplication(String applicationId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('''
            *,
            job_seeker:job_seeker_id(id, full_name, profile_image_url),
            recruiter:recruiter_id(id, full_name, profile_image_url),
            job_application:job_application_id(
              id,
              job:job_id(
                id, title,
                company:company_id(id, name, logo_url)
              )
            )
          ''')
          .eq('job_application_id', applicationId)
          .single();

      return response;
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  // Create a new conversation
  Future<Map<String, dynamic>?> createConversation({
    required String jobApplicationId,
    required String jobSeekerId,
    required String recruiterId,
  }) async {
    try {
      final response = await _supabase
          .from('conversations')
          .insert({
            'job_application_id': jobApplicationId,
            'job_seeker_id': jobSeekerId,
            'recruiter_id': recruiterId,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  // Get messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            sender:sender_id(id, full_name, profile_image_url)
          ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response.reversed);
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Send a text message
  Future<Map<String, dynamic>?> sendTextMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': currentUser.id,
            'message_type': 'text',
            'content': content,
          })
          .select('''
            *,
            sender:sender_id(id, full_name, profile_image_url)
          ''')
          .single();

      return response;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Upload file and send file message
  Future<Map<String, dynamic>?> sendFileMessage({
    required String conversationId,
    required File file,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Check file size (10MB limit)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Generate unique file name
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName);
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${currentUser.id}$fileExtension';
      final filePath = 'chat_files/$conversationId/$uniqueFileName';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from('chat-files')
          .upload(filePath, file);

      // Get public URL
      final fileUrl = _supabase.storage
          .from('chat-files')
          .getPublicUrl(filePath);

      // Determine message type based on file extension
      final messageType = _isImageFile(fileExtension) ? 'image' : 'file';

      // Send message with file info
      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': currentUser.id,
            'message_type': messageType,
            'file_url': fileUrl,
            'file_name': fileName,
            'file_size': fileSize,
            'mime_type': _getMimeType(fileExtension),
          })
          .select('''
            *,
            sender:sender_id(id, full_name, profile_image_url)
          ''')
          .single();

      return response;
    } catch (e) {
      print('Error sending file message: $e');
      return null;
    }
  }

  // Pick and send file
  Future<Map<String, dynamic>?> pickAndSendFile(String conversationId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        return await sendFileMessage(
          conversationId: conversationId,
          file: file,
        );
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      await _supabase
          .from('message_read_status')
          .upsert({
            'message_id': messageId,
            'user_id': currentUser.id,
          });
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Get unread message count for a conversation
  Future<int> getUnreadMessageCount(String conversationId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return 0;

      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUser.id)
          .not('id', 'in', '(SELECT message_id FROM message_read_status WHERE user_id = ${currentUser.id})');

      return response.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Subscribe to new messages in a conversation
  Stream<List<Map<String, dynamic>>> subscribeToMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at');
  }

  // Subscribe to conversation updates
  Stream<List<Map<String, dynamic>>> subscribeToConversation(String conversationId) {
    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .eq('id', conversationId);
  }

  // Helper methods
  bool _isImageFile(String extension) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  // Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}