import '../../../core/services/api_service.dart';
import 'models/perumahan_model.dart';

class HomeRepository {
  final api = ApiService();

  Future<List<Perumahan>> getPerumahanList() async {
    final data = await api.fetchPerumahan();
    return data.map<Perumahan>((json) => Perumahan.fromJson(json)).toList();
  }
}
