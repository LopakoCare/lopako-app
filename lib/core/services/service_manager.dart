// service_manager.dart
abstract class BaseService {
  late final ServiceManager serviceManager;
  void init(ServiceManager manager) => serviceManager = manager;
}

class ServiceManager {
  ServiceManager._internal();
  static final ServiceManager _instance = ServiceManager._internal();
  static ServiceManager get instance => _instance;

  final Map<String, dynamic> _services = {};

  /// Registra un servicio con clave única.
  void add(String key, dynamic service) {
    if (_services.containsKey(key)) {
      throw Exception("Service '$key' ya registrado.");
    }
    _services[key] = service;
    if (service is BaseService) service.init(this);
  }

  /// Recupera un servicio por clave casteándolo al tipo deseado.
  T getService<T>(String key) {
    final svc = _services[key];
    if (svc == null) {
      throw Exception("Service '$key' no encontrado — ¿lo registraste en main()?");
    }
    return svc as T;
  }
}
