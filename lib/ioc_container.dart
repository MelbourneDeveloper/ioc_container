import 'package:meta/meta.dart';

///Defines a factory for the service and whether or not it is a singleton.
@immutable
class ServiceDefinition<T> {
  ///If true, only once instance of the service will be created and shared for
  ///for the lifespan of the app
  final bool isSingleton;

  ///The factory that creates the instance of the service and can access other
  ///services in this container
  final T Function(IocContainer container) factory;

  ServiceDefinition(this.factory, {this.isSingleton = false});
}

///A built Ioc Container. To create a new IocContainer, use
///[IocContainerBuilder]. To get a service from the container, call [get].
///Builders create immutable containers unless you specify the
///isLazy option on toContainer(). You can build your own container by injecting
///service definitions and singletons here
@immutable
class IocContainer {
  ///This is only here for testing and you should not use this in your code
  @visibleForTesting
  final Map<Type, ServiceDefinition> serviceDefinitionsByType;

  ///This is only here for testing and you should not use this in your code
  @visibleForTesting
  final Map<Type, Object> singletons;

  IocContainer(this.serviceDefinitionsByType, this.singletons);

  ///Get an instance of the service by type
  T get<T>() => singletons.containsKey(T)
      ? singletons[T] as T
      : serviceDefinitionsByType.containsKey(T)
          ? (serviceDefinitionsByType[T]!.isSingleton
              ? singletons.putIfAbsent(
                  T,
                  () =>
                      serviceDefinitionsByType[T]!.factory(this) as Object) as T
              : serviceDefinitionsByType[T]!.factory(this))
          : throw Exception('Service not found');
}

///A builder for creating an [IocContainer].
@immutable
class IocContainerBuilder {
  final Map<Type, ServiceDefinition> _serviceDefinitionsByType = {};

  ///Throw an error if a service is added more than once. Set this to true when
  ///you want to add mocks to set of services for a test.
  final bool allowOverrides;

  IocContainerBuilder({this.allowOverrides = false});

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
        //Note: this case allows the singletons to be mutable
        // ignore: prefer_const_literals_to_create_immutables
        <Type, Object>{});
  }
}

extension Extensions on IocContainerBuilder {
  ///Add a singleton service to the container.
  void addSingletonService<T>(T service) => addServiceDefinition(
      ServiceDefinition<T>((i) => service, isSingleton: true));

  ///Add a singleton factory to the container. The container
  ///will only call this once throughout the lifespan of the app
  void addSingleton<T>(T Function(IocContainer container) factory) =>
      addServiceDefinition(ServiceDefinition(factory, isSingleton: true));

  ///Add a factory to the container.
  void add<T>(T Function(IocContainer container) factory) =>
      addServiceDefinition(ServiceDefinition(factory));
}
