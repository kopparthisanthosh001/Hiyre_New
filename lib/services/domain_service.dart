import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class DomainService {
  static DomainService? _instance;
  static DomainService get instance => _instance ??= DomainService._();
  DomainService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all active domains
  Future<List<Map<String, dynamic>>> getDomains() async {
    try {
      final response = await _client
          .from('domains')
          .select('*')
          .eq('is_active', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch domains: $error');
    }
  }

  // Get domains by names (for matching UI selections with database)
  Future<List<Map<String, dynamic>>> getDomainsByNames(
    List<String> domainNames,
  ) async {
    try {
      // Handle name mappings between UI and database
      final mappedNames =
          domainNames
              .map((name) {
                switch (name) {
                  case 'Engineering':
                    return ['Engineering', 'Technology']; // Check both names
                  default:
                    return [name];
                }
              })
              .expand((names) => names)
              .toList();

      final response = await _client
          .from('domains')
          .select('*')
          .inFilter('name', mappedNames)
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch domains by names: $error');
    }
  }

  // Get domain by ID
  Future<Map<String, dynamic>?> getDomainById(String domainId) async {
    try {
      final response =
          await _client
              .from('domains')
              .select('*')
              .eq('id', domainId)
              .eq('is_active', true)
              .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch domain: $error');
    }
  }

  // Save user's selected domains
  Future<void> saveUserDomains(List<String> domainIds) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // First, remove existing user domains
      await _client.from('user_domains').delete().eq('user_id', userId);

      // Then insert new selections
      if (domainIds.isNotEmpty) {
        final userDomains =
            domainIds
                .map((domainId) => {'user_id': userId, 'domain_id': domainId})
                .toList();

        await _client.from('user_domains').insert(userDomains);
      }
    } catch (error) {
      throw Exception('Failed to save user domains: $error');
    }
  }

  // Get user's selected domains
  Future<List<Map<String, dynamic>>> getUserDomains() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_domains')
          .select('''
            domain_id,
            domains (
              id,
              name,
              description
            )
          ''')
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch user domains: $error');
    }
  }

  // Create a new domain (admin function)
  Future<Map<String, dynamic>> createDomain({
    required String name,
    String? description,
    String? iconUrl,
  }) async {
    try {
      final response =
          await _client
              .from('domains')
              .insert({
                'name': name,
                'description': description,
                'icon_url': iconUrl,
              })
              .select()
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create domain: $error');
    }
  }

  // Update domain (admin function)
  Future<Map<String, dynamic>> updateDomain({
    required String domainId,
    String? name,
    String? description,
    String? iconUrl,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (iconUrl != null) updates['icon_url'] = iconUrl;
      if (isActive != null) updates['is_active'] = isActive;

      final response =
          await _client
              .from('domains')
              .update(updates)
              .eq('id', domainId)
              .select()
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update domain: $error');
    }
  }

  // Delete domain (admin function)
  Future<void> deleteDomain(String domainId) async {
    try {
      await _client.from('domains').delete().eq('id', domainId);
    } catch (error) {
      throw Exception('Failed to delete domain: $error');
    }
  }

  // Search domains
  Future<List<Map<String, dynamic>>> searchDomains(String query) async {
    try {
      final response = await _client
          .from('domains')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search domains: $error');
    }
  }

  // Get domain with job count
  Future<List<Map<String, dynamic>>> getDomainsWithJobCount() async {
    try {
      final response = await _client.rpc('get_domains_with_job_count');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      // Fallback to regular domains if function doesn't exist
      return getDomains();
    }
  }

  // Get popular domains (based on job count)
  Future<List<Map<String, dynamic>>> getPopularDomains({int limit = 10}) async {
    try {
      final domains = await getDomainsWithJobCount();
      domains.sort(
        (a, b) => (b['job_count'] ?? 0).compareTo(a['job_count'] ?? 0),
      );
      return domains.take(limit).toList();
    } catch (error) {
      // Fallback to regular domains
      final response = await _client
          .from('domains')
          .select()
          .eq('is_active', true)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    }
  }
}
