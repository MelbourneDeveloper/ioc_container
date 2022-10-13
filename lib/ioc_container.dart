///An exception that occurs when the service is not found
class ServiceNotFoundException<T> implements Exception {
  ///Creates a new instance of [ServiceNotFoundException]
  const ServiceNotFoundException(this.message);

  ///The exception message
  final String message;
  @override
  String toString() => 'ServiceNotFoundException: $message';
}

///Defines a factory for the service and whether or not it is a singleton.
class ServiceDefinition<T> {
  ///Defines a factory for the service and whether or not it is a singleton.
  const ServiceDefinition(
    this.factory, {
    this.isSingleton = false,
    this.dispose,
  });

  ///If true, only one instance of the service will be created and shared for
  ///for the lifespan of the container.
  final bool isSingleton;

  ///The factory that creates the instance of the service and can access other
  ///services in this container
  final T Function(
    IocContainer container,
  ) factory;

  ///The dispose method that is called when you dispose the scope
  final void Function(T service)? dispose;

  void _dispose(T instance) {
    dispose?.call(instance);
  }
}

///A built Ioc Container. To create a new IocContainer, use
///[IocContainerBuilder]. To get a service from the container, call [get].
///Call scoped to get a container that mints scoped services.
class IocContainer {
  ///Creates an IocContainer. You can build your own container by injecting
  ///service definitions and singletons here, but you should probably use
  ///[IocContainerBuilder] instead.
  const IocContainer(
    this.serviceDefinitionsByType,
    this.singletons, {
    this.isScoped = false,
  });

  ///The service definitions by type
  final Map<Type, ServiceDefinition<dynamic>> serviceDefinitionsByType;

  ///Map of singletons or scoped services by type. This map is probably mutable
  ///so the container can store scope or singletons, so don't put anything in
  ///here
  final Map<Type, Object> singletons;

  ///If true, this container is a scoped container. Scoped containers never
  ///create more than one instance of a service
  final bool isScoped;

  ///Get an instance of the service by type
  T get<T extends Object>() {
    final serviceDefinition = serviceDefinitionsByType[T];

    if (serviceDefinition == null) {
      throw ServiceNotFoundException<T>(
        'Service ${(T).toString()} not found',
      );
    }

    if (serviceDefinition.isSingleton || isScoped) {
      final singletonValue = singletons[T];

      if (singletonValue != null) {
        return singletonValue as T;
      }
    }

    final service = serviceDefinition.factory(this) as T;

    if (serviceDefinition.isSingleton || isScoped) {
      singletons[T] = service;
    }

    return service;
  }

  ///This is a shortcut for [get]
  T call<T extends Object>() => get<T>();

  ///Dispose all singletons or scope. Warning: don't use this on your root
  ///container. You should only use this on scoped containers
  void dispose() {
    assert(isScoped, 'Only dispose scoped containers');
    for (final type in singletons.keys) {
      serviceDefinitionsByType[type]!._dispose(singletons[type]);
    }
    singletons.clear();
  }
}

///A builder for creating an [IocContainer].
class IocContainerBuilder {
  ///Creates a container builder
  IocContainerBuilder({this.allowOverrides = false});
  final Map<Type, ServiceDefinition<dynamic>> _serviceDefinitionsByType = {};

  ///Throw an error if a service is added more than once. Set this to true when
  ///you want to add mocks to set of services for a test.
  final bool allowOverrides;

  ///Add a factory to the container.
  void addServiceDefinition<T>(
    ///Add a factory and whether or not this service is a singleton
    ServiceDefinition<T> serviceDefinition,
  ) {
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
  IocContainer toContainer() => IocContainer(
        Map<Type, ServiceDefinition<dynamic>>.unmodifiable(
          _serviceDefinitionsByType,
        ),
        <Type, Object>{},
      );

  ///Add a singleton service to the container.
  void addSingletonService<T>(T service) => addServiceDefinition(
        ServiceDefinition<T>(
          (container) => service,
          isSingleton: true,
        ),
      );

  ///Add a singleton factory to the container. The container
  ///will only call this once throughout the lifespan of the container
  void addSingleton<T>(
    T Function(
      IocContainer container,
    )
        factory,
  ) =>
      addServiceDefinition<T>(
        ServiceDefinition<T>(
          (container) => factory(container),
          isSingleton: true,
        ),
      );

  ///Add a factory to the container.
  void add<T>(
    T Function(
      IocContainer container,
    )
        factory, {
    void Function(T service)? dispose,
  }) =>
      addServiceDefinition<T>(
        ServiceDefinition<T>(
          (container) => factory(container),
          dispose: dispose,
        ),
      );
}

///Extensions for IocContainer
extension IocContainerExtensions on IocContainer {
  ///Initalizes and stores each singleton in case you want a zealous container
  ///instead of a lazy one
  void initializeSingletons() {
    serviceDefinitionsByType.forEach((type, serviceDefinition) {
      if (serviceDefinition.isSingleton) {
        singletons.putIfAbsent(
          type,
          () => serviceDefinition.factory(
            this,
          ) as Object,
        );
      }
    });
  }

  ///Gets a service, but each service in the object mesh will have only one
  ///instance. If you want to get multiple scoped objects, call [scoped] to
  ///get a reusable [IocContainer] and then call [get] on that.
  T getScoped<T extends Object>() => scoped().get<T>();

  ///Creates a new Ioc Container for a particular scope
  IocContainer scoped() => IocContainer(
        serviceDefinitionsByType,
        Map<Type, Object>.from(singletons),
        isScoped: true,
      );

  ///Gets a dependency that requires async initialization. You can only use
  ///this on factories that return a Future<>. Warning: if the definition is
  ///singleton/scoped and the Future fails, the factory will never return a
  ///valid value. Use [initSafe] to ensure the container doesn't store failed
  /// singletons
  Future<T> init<T>() async => get<Future<T>>();

  ///See [init].
  ///Safely makes an async call by creating a temporary scoped container,
  ///attempting to make the async initialization and merging the result with the
  ///current container if there is success. Warning: this does not do error
  ///handling and this also allows reentrancy. If you call this more than once
  ///in parallel it will create multiple Futures - i.e. make multiple async
  ///calls. You should execute this in a queue or use a lock to prevent this,
  ///and perform retries on failure.
  Future<T> initSafe<T>() async {
    final scope = scoped();

    final service = scoped().init<T>();

    merge(scope);

    return service;
  }

  ///Merge the singletons or scope from a container into this container. This
  ///only moves singleton definitions by default, but you can override this
  ///with [whereTest]
  void merge(
    IocContainer container, {
    bool overwrite = false,
    bool Function(Type type)? whereTest,
  }) {
    for (final key in container.singletons.keys.where(
      whereTest ??
          (type) => serviceDefinitionsByType[type]?.isSingleton ?? false,
    )) {
      if (overwrite) {
        singletons[key] = container.singletons[key]!;
      } else {
        singletons.putIfAbsent(key, () => container.singletons[key]!);
      }
    }
  }
}
