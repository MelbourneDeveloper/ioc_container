///An immutable collection of factories keyed by type.

class ServiceDefinition<T> {
  bool isSingleton;
  T Function(IocContainer container) factory;

  ServiceDefinition(this.isSingleton, this.factory);
}

class IocContainer {
  final Map<Type, ServiceDefinition> _serviceDefinitionsByType;
  final Map<Type, Object> _singletons = {};

  IocContainer(this._serviceDefinitionsByType);

  ///Get an instance of your dependency
  T get<T>() {
    final serviceDefinition = _serviceDefinitionsByType[T];

    if (serviceDefinition == null) {
      throw Exception('Service not found');
    }

    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    final service = serviceDefinition.factory(this) as T;

    if (serviceDefinition.isSingleton) {
      _singletons.putIfAbsent(T, () => service as Object);
    }

    return service;
  }
}

///A builder for creating an [IocContainer].
class IocContainerBuilder {
  final Map<Type, ServiceDefinition> _map = {};

  ///Add a factory to the container.
  void addServiceDefinition<T>(ServiceDefinition<T> get) =>
      _map.putIfAbsent(T, () => get);

  ///Create an [IocContainer] from the [IocContainerBuilder].
  IocContainer toContainer() =>
      IocContainer(Map<Type, ServiceDefinition>.unmodifiable(_map));
}

extension Extensions on IocContainerBuilder {
  ///Add a singleton object dependency to the container.
  void addSingletonService<T>(T service) =>
      addServiceDefinition(ServiceDefinition(true, (i) => service));

  void addSingleton<T>(T Function(IocContainer container) factory) =>
      addServiceDefinition(ServiceDefinition(true, factory));

  void add<T>(T Function(IocContainer container) factory) =>
      addServiceDefinition(ServiceDefinition(false, factory));
}
