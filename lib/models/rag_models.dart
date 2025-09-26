class RAGQuery {
  final String query;
  final String userType;
  final int? childId;
  final String? context;
  final int maxResults;
  final double similarityThreshold;

  RAGQuery({
    required this.query,
    required this.userType,
    this.childId,
    this.context,
    this.maxResults = 5,
    this.similarityThreshold = 0.7,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'userType': userType,
      'childId': childId,
      'context': context,
      'maxResults': maxResults,
      'similarityThreshold': similarityThreshold,
    };
  }
}

class RAGResponse {
  final String answer;
  final List<DocumentChunk> relevantChunks;
  final List<String> sources;
  final double confidence;
  final String query;
  final String timestamp;
  final String model;
  final int tokensUsed;

  RAGResponse({
    required this.answer,
    required this.relevantChunks,
    required this.sources,
    required this.confidence,
    required this.query,
    required this.timestamp,
    required this.model,
    required this.tokensUsed,
  });

  factory RAGResponse.fromJson(Map<String, dynamic> json) {
    return RAGResponse(
      answer: json['answer'] ?? '',
      relevantChunks: (json['relevantChunks'] as List<dynamic>?)
          ?.map((chunk) => DocumentChunk.fromJson(chunk))
          .toList() ?? [],
      sources: (json['sources'] as List<dynamic>?)?.cast<String>() ?? [],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      query: json['query'] ?? '',
      timestamp: json['timestamp'] ?? '',
      model: json['model'] ?? '',
      tokensUsed: json['tokensUsed'] ?? 0,
    );
  }
}

class DocumentChunk {
  final int id;
  final int documentId;
  final String content;
  final int chunkIndex;
  final int startPosition;
  final int endPosition;
  final String embeddingId;
  final String timestamp;
  final Document document;

  DocumentChunk({
    required this.id,
    required this.documentId,
    required this.content,
    required this.chunkIndex,
    required this.startPosition,
    required this.endPosition,
    required this.embeddingId,
    required this.timestamp,
    required this.document,
  });

  factory DocumentChunk.fromJson(Map<String, dynamic> json) {
    return DocumentChunk(
      id: json['id'] ?? 0,
      documentId: json['documentId'] ?? 0,
      content: json['content'] ?? '',
      chunkIndex: json['chunkIndex'] ?? 0,
      startPosition: json['startPosition'] ?? 0,
      endPosition: json['endPosition'] ?? 0,
      embeddingId: json['embeddingId'] ?? '',
      timestamp: json['timestamp'] ?? '',
      document: Document.fromJson(json['document'] ?? {}),
    );
  }
}

class Document {
  final int id;
  final String title;
  final String content;
  final String documentType;
  final String? sourceUrl;
  final String? author;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final String? metadata;

  Document({
    required this.id,
    required this.title,
    required this.content,
    required this.documentType,
    this.sourceUrl,
    this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      documentType: json['documentType'] ?? '',
      sourceUrl: json['sourceUrl'],
      author: json['author'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }
}


