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
    this.disposeAsync,
  })  : assert(
          !isSingleton || dispose == null,
          'Singleton factories cannot have a dispose method',
        ),
        assert(
          dispose == null || disposeAsync == null,
          "Service definitions can't have both dispose and disposeAsync",
        );

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

  ///The async dispose method that is called when you dispose the scope
  final Future<void> Function(T service)? disposeAsync;

  void _dispose(T instance) => dispose?.call(instance);

  Future<void> _disposeAsync(T instance) async => disposeAsync?.call(instance);
}

///A built Ioc Container. To create a new [IocContainer], use
///[IocContainerBuilder]. To get a service from the container, call
///[get], [getAsync], or [getAsyncSafe]
///Call [scoped] to get a scoped container
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

  ///Map of singletons or scoped services by type. This map is mutable
  ///so the container can store scope or singletons
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

  ///Adds an async [ServiceDefinition]
  void addAsync<T>(
    Future<T> Function(
      IocContainer container,
    )
        factory, {
    Future<void> Function(T service)? disposeAsync,
  }) =>
      addServiceDefinition<Future<T>>(
        ServiceDefinition<Future<T>>(
          (container) async => factory(container),
          disposeAsync: (service) async => disposeAsync?.call(await service),
        ),
      );

  ///Add an async singleton factory to the container. The container
  ///will only call the factory once throughout the lifespan of the container
  void addSingletonAsync<T>(
    Future<T> Function(
      IocContainer container,
    )
        factory,
  ) =>
      addServiceDefinition<Future<T>>(
        ServiceDefinition<Future<T>>(
          isSingleton: true,
          (container) async => factory(container),
        ),
      );
}

///Extensions for IocContainer
extension IocContainerExtensions on IocContainer {
  ///Dispose all singletons or scope. Warning: don't use this on your root
  ///container. You should only use this on scoped containers.
  Future<void> dispose() async {
    assert(isScoped, 'Only dispose scoped containers');
    for (final type in singletons.keys) {
      //Note: we don't need to check if the service is a singleton because
      //singleton service definitions never have dispose
      final serviceDefinition = serviceDefinitionsByType[type]!;

      //We can't do a null check here because if a Dart issue
      serviceDefinition._dispose.call(singletons[type]);

      await serviceDefinition._disposeAsync(singletons[type]);
    }
    singletons.clear();
  }

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
  ///get a reusable [IocContainer] and then call [get] or [getAsync] on that.
  T getScoped<T extends Object>() => scoped().get<T>();

  ///Creates a new Ioc Container for a particular scope. Does not use existing
  ///singletons/scope by default. Warning: if you use the existing singletons,
  ///calling [dispose] will dispose those singletons
  IocContainer scoped({
    bool useExistingSingletons = false,
  }) =>
      IocContainer(
        serviceDefinitionsByType,
        useExistingSingletons ? Map<Type, Object>.from(singletons) : {},
        isScoped: true,
      );

  ///Gets a service that requires async initialization. Add these services with
  ///[IocContainerBuilder.addAsync] or [IocContainerBuilder.addSingletonAsync]
  ///You can only use this on factories that return a Future<>.
  ///Warning: if the definition is singleton/scoped and the Future fails, the factory will never return a
  ///valid value, so use [getAsyncSafe] to ensure the container doesn't store
  ///failed singletons
  Future<T> getAsync<T>() async => get<Future<T>>();

  ///See [getAsync].
  ///Makes an async call by creating a temporary scoped container,
  ///attempting to make the async initialization and merging the result with the
  ///current container if there is success.
  ///
  ///Warning: allows reentrancy and does not do error handling.
  ///If you call this more than once in parallel it will create multiple
  ///Futures - i.e. make multiple async calls. You need to guard against this
  ///and perform retries on failure. Be aware that this may happen even if
  ///you only call this method in a single location in your app.
  ///You may need a an async lock.
  Future<T> getAsyncSafe<T>() async {
    final scope = scoped();

    final service = await scope.getAsync<T>();

    merge(scope);

    return service;
  }

  ///Merge the singletons or scope from a container into this container. This
  ///only moves singleton definitions by default, but you can override this
  ///with [mergeTest]
  void merge(
    IocContainer container, {
    bool overwrite = false,
    bool Function(
      Type type,
      ServiceDefinition<dynamic>? serviceDefinition,
      Object? singleton,
    )?
        mergeTest,
  }) {
    for (final key in container.singletons.keys.where(
      mergeTest != null
          ? (type) => mergeTest(
                type,
                serviceDefinitionsByType[type],
                container.singletons[type],
              )
          : (type) => serviceDefinitionsByType[type]?.isSingleton ?? false,
    )) {
      if (overwrite) {
        singletons[key] = container.singletons[key]!;
      } else {
        singletons.putIfAbsent(key, () => container.singletons[key]!);
      }
    }
  }
}
