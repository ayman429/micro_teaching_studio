class PaginationData {
  int total;
  int perPage;
  int currentPage;
  int pagesCount;
  PaginationData({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.pagesCount,
  });
  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      total: json['total'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      pagesCount: json['last_page'],
    );
  }
}
