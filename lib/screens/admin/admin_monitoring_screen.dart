import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminMonitoringScreen extends StatelessWidget {
  const AdminMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring & Métriques'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
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


