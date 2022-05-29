///An immutable collection of factories keyed by type.
import 'package:meta/meta.dart';

class ServiceDefinition<T> {
  bool isSingleton;
  T Function(IocContainer container) factory;

  ServiceDefinition(this.isSingleton, this.factory);
}

class IocContainer {
  @visibleForTesting
  final Map<Type, ServiceDefinition> serviceDefinitionsByType;
  @visibleForTesting
  final Map<Type, Object> singletons;

  IocContainer(this.serviceDefinitionsByType, this.singletons);

  ///Get an instance of your dependency
  T get<T>() {
    if (singletons.containsKey(T)) {
      return singletons[T] as T;
    }

    final serviceDefinition = serviceDefinitionsByType[T];

    if (serviceDefinition == null) {
      throw Exception('Service not found');
    }

    final service = serviceDefinition.factory(this) as T;

    if (serviceDefinition.isSingleton) {
      singletons.putIfAbsent(T, () => service as Object);
    }

    return service;
  }
}

///A builder for creating an [IocContainer].
class IocContainerBuilder {
  final Map<Type, ServiceDefinition> _serviceDefinitionsByType = {};

  ///Throw an error if a service is added more than once
  final bool allowOverrides;

  IocContainerBuilder({this.allowOverrides = true});

  ///Add a factory to the container.
  void addServiceDefinition<T>(

      ///Add a factory and whether or not this service is a singleton
      ServiceDefinition<T> serviceDefinition) {
    if (_serviceDefinitionsByType.containsKey(T)) {
      if (allowOverrides) {
        _serviceDefinitionsByType.remove(T);
      } else {
        throw Exception('Service already exists');
      }
    }

    _serviceDefinitionsByType.putIfAbsent(T, () => serviceDefinition);
  }

  ///Create an [IocContainer] from the [IocContainerBuilder].
  ///This will create an instance of each singleton service and store it
  ///in an immutable list unless you specify [isLazy] as true.
  IocContainer toContainer(
      {

      ///If this is true the services will be created when they are requested
      ///and this container will not technically be immutable.
      bool isLazy = false}) {
    if (!isLazy) {
      final singletons = <Type, Object>{};
      final tempContainer = IocContainer(_serviceDefinitionsByType, singletons);
      _serviceDefinitionsByType.forEach((type, serviceDefinition) {
        if (serviceDefinition.isSingleton) {
          singletons.putIfAbsent(
              type, () => serviceDefinition.factory(tempContainer));
        }
      });

      return IocContainer(
          Map<Type, ServiceDefinition>.unmodifiable(_serviceDefinitionsByType),
          Map<Type, Object>.unmodifiable(singletons));
    }
    return IocContainer(
        Map<Type, ServiceDefinition>.unmodifiable(_serviceDefinitionsByType),
        <Type, Object>{});
  }
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
