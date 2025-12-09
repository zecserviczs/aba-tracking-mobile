import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';

class AdminMonitoringScreen extends StatefulWidget {
  const AdminMonitoringScreen({super.key});

  @override
  State<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();
}

class _AdminMonitoringScreenState extends State<AdminMonitoringScreen> {
  Map<String, dynamic>? _healthData;
  DateTime? _healthFetchedAt;
  bool _loadingHealth = false;
  String? _healthError;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    setState(() {
      _loadingHealth = true;
      _healthError = null;
    });
    try {
      final data = await ApiService.getActuatorHealth();
      if (!mounted) return;
      setState(() {
        _healthData = data;
        _healthFetchedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _healthError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingHealth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring & Métriques'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingHealth ? null : _loadHealth,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: 24.h),
            _buildMonitoringCards(),
            SizedBox(height: 24.h),
            _buildActuatorEndpoints(),
            SizedBox(height: 24.h),
            _buildSystemInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            colors: [Colors.orange.shade600, Colors.orange.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring du Système',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Surveillance des performances et métriques',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outils de Monitoring',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12.h),
        _buildMonitoringCard(
          'Grafana Dashboard',
          'Tableaux de bord et visualisations des métriques',
          Icons.dashboard,
          Colors.blue,
          'http://localhost:3000',
          'admin / admin123',
        ),
        SizedBox(height: 12.h),
        _buildMonitoringCard(
          'Prometheus',
          'Collecte et stockage des métriques',
          Icons.storage,
          Colors.red,
          'http://localhost:9090',
          null,
        ),
        SizedBox(height: 12.h),
        _buildMonitoringCard(
          'Node Exporter',
          'Métriques système et matériel',
          Icons.computer,
          Colors.green,
          'http://localhost:9100',
          null,
        ),
      ],
    );
  }

  Widget _buildMonitoringCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String url,
    String? credentials,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      url,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (credentials != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Identifiants: $credentials',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: Colors.grey.shade400, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActuatorEndpoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Endpoints Actuator',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12.h),
        _buildActuatorStatusCard(),
        SizedBox(height: 12.h),
        _buildEndpointCard(
          'Health Check',
          'État de santé de l\'application',
          Icons.health_and_safety,
          Colors.green,
          '/actuator/health',
        ),
        SizedBox(height: 8.h),
        _buildEndpointCard(
          'Métriques',
          'Métriques détaillées de l\'application',
          Icons.analytics,
          Colors.blue,
          '/actuator/metrics',
        ),
        SizedBox(height: 8.h),
        _buildEndpointCard(
          'Prometheus',
          'Métriques au format Prometheus',
          Icons.storage,
          Colors.red,
          '/actuator/prometheus',
        ),
        SizedBox(height: 8.h),
        _buildEndpointCard(
          'Informations',
          'Informations sur l\'application',
          Icons.info,
          Colors.orange,
          '/actuator/info',
        ),
      ],
    );
  }

  Widget _buildActuatorStatusCard() {
    Color statusColor = Colors.grey;
    String statusLabel = 'Inconnu';
    if (_healthData != null) {
      final status = (_healthData!['status'] as String? ?? '').toUpperCase();
      if (status == 'UP') {
        statusColor = Colors.green;
        statusLabel = 'UP';
      } else if (status == 'DOWN') {
        statusColor = Colors.red;
        statusLabel = 'DOWN';
      } else if (status.isNotEmpty) {
        statusLabel = status;
        statusColor = Colors.orange;
      }
    }

    final components = (_healthData?['components'] as Map<String, dynamic>?)
            ?.entries
            .toList() ??
        [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.health_and_safety, color: statusColor),
                    SizedBox(width: 8.w),
                    Text(
                      'Statut Actuator',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: _loadingHealth
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _loadingHealth ? null : _loadHealth,
                  tooltip: 'Rafraîchir',
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_loadingHealth)
              const Center(child: CircularProgressIndicator())
            else if (_healthError != null)
              Text(
                'Erreur : $_healthError',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13.sp,
                ),
              )
            else ...[
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Statut global : $statusLabel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              if (_healthFetchedAt != null) ...[
                SizedBox(height: 6.h),
                Text(
                  'Dernière mise à jour : '
                  '${_healthFetchedAt!.hour.toString().padLeft(2, '0')}:'
                  '${_healthFetchedAt!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              if (components.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  'Composants :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                ...components.map((entry) {
                  final compStatus =
                      (entry.value['status'] as String? ?? '').toUpperCase();
                  Color compColor;
                  if (compStatus == 'UP') {
                    compColor = Colors.green;
                  } else if (compStatus == 'DOWN') {
                    compColor = Colors.red;
                  } else {
                    compColor = Colors.orange;
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: compColor,
                          size: 10,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${entry.key} : $compStatus',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String endpoint,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => _launchUrl('http://localhost:8080$endpoint'),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'http://localhost:8080$endpoint',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: Colors.grey.shade400, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations Système',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _buildInfoRow('Application', 'ABA Tracking System'),
                _buildInfoRow('Backend', 'Spring Boot 3.4.3'),
                _buildInfoRow('Base de données', 'PostgreSQL'),
                _buildInfoRow('Message Broker', 'Apache Kafka'),
                _buildInfoRow('Monitoring', 'Grafana + Prometheus'),
                _buildInfoRow('Port Backend', '8080'),
                _buildInfoRow('Port Grafana', '3000'),
                _buildInfoRow('Port Prometheus', '9090'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: copier l'URL dans le presse-papiers
      // Clipboard.setData(ClipboardData(text: url));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('URL copiée: $url')),
      // );
    }
  }
}

