import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultsScreen extends StatelessWidget {
  final TestRecording recording;

  const ResultsScreen({
    Key? key,
    required this.recording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Performance Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareResults(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Card
            _buildScoreCard(),
            
            SizedBox(height: 20),
            
            // Performance Breakdown
            _buildPerformanceBreakdown(),
            
            SizedBox(height: 20),
            
            // Benchmark Comparison
            _buildBenchmarkComparison(),
            
            SizedBox(height: 20),
            
            // AI Insights
            _buildAIInsights(),
            
            SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final grade = recording.grade ?? 'N/A';
    final score = recording.finalScore ?? 0.0;
    final percentile = recording.percentile ?? 0.0;
    
    Color gradeColor = _getGradeColor(grade);
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradeColor.withOpacity(0.8), gradeColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Grade Display
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Your Score: ${score.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 8),
          
          Text(
            '${percentile.toStringAsFixed(1)}th Percentile',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Confidence indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'AI Confidence: ${((recording.aiConfidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Extract metrics from AI analysis data
          if (recording.aiAnalysisData != null)
            ..._buildMetricItems(recording.aiAnalysisData!),
        ],
      ),
    );
  }

  List<Widget> _buildMetricItems(Map<String, dynamic> analysisData) {
    List<Widget> items = [];
    
    // Example for vertical jump
    if (analysisData.containsKey('jump_height')) {
      items.add(_buildMetricItem(
        'Jump Height',
        '${analysisData['jump_height'].toStringAsFixed(1)} cm',
        Icons.trending_up,
        Colors.blue,
      ));
    }
    
    if (analysisData.containsKey('rep_count')) {
      items.add(_buildMetricItem(
        'Repetitions',
        '${analysisData['rep_count']} reps',
        Icons.repeat,
        Colors.green,
      ));
    }
    
    if (analysisData.containsKey('time_taken')) {
      items.add(_buildMetricItem(
        'Time Taken',
        '${analysisData['time_taken'].toStringAsFixed(2)}s',
        Icons.timer,
        Colors.orange,
      ));
    }
    
    return items;
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkComparison() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benchmark Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Radar chart showing performance across different aspects
          Container(
            height: 200,
            child: _buildRadarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            entryRadius: 3,
            dataEntries: [
              RadarEntry(value: (recording.finalScore ?? 0) / 10),
              RadarEntry(value: (recording.percentile ?? 0) / 100),
              RadarEntry(value: (recording.aiConfidence ?? 0)),
              RadarEntry(value: 0.8), // Form accuracy
              RadarEntry(value: 0.9), // Consistency
            ],
            borderColor: Colors.blue[800]!,
            fillColor: Colors.blue[800]!.withOpacity(0.2),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return RadarChartTitle(text: 'Score');
            case 1:
              return RadarChartTitle(text: 'Percentile');
            case 2:
              return RadarChartTitle(text: 'AI Confidence');
            case 3:
              return RadarChartTitle(text: 'Form');
            case 4:
              return RadarChartTitle(text: 'Consistency');
            default:
              return RadarChartTitle(text: '');
          }
        },
        tickCount: 4,
        ticksTextStyle: TextStyle(
          color: Colors.transparent,
          fontSize: 10,
        ),
        tickBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
        gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue[800]),
              SizedBox(width: 8),
              Text(
                'AI Insights & Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          _buildInsightItem(
            '✓ Excellent takeoff technique detected',
            Colors.green,
          ),
          _buildInsightItem(
            '⚠ Landing could be more controlled',
            Colors.orange,
          ),
          _buildInsightItem(
            '💡 Focus on explosive leg strength training',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _retakeTest(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Retake Test'),
        ),
        
        SizedBox(height: 12),
        
        ElevatedButton(
          onPressed: () => _viewDetailedAnalysis(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('View Detailed Analysis'),
        ),
        
        SizedBox(height: 12),
        
        ElevatedButton(
          onPressed: () => _continueAssessment(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Continue Assessment'),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green[600]!;
      case 'B+':
      case 'B':
        return Colors.blue[600]!;
      case 'C+':
      case 'C':
        return Colors.orange[600]!;
      default:
        return Colors.red[600]!;
    }
  }

  void _shareResults(BuildContext context) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing results...')),
    );
  }

  void _retakeTest(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CameraRecordingScreen(
          testCategoryId: recording.testCategoryId,
          sessionId: recording.sessionId,
        ),
      ),
    );
  }

  void _viewDetailedAnalysis(BuildContext context) {
    // Navigate to detailed analysis screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedAnalysisScreen(recording: recording),
      ),
    );
  }

  void _continueAssessment(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}