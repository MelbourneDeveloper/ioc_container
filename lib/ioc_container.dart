///An immutable collection of factories keyed by type.
class IocContainer {
  final Map<Type, Object Function(IocContainer container)> _map;
  IocContainer(this._map);

  ///Get an instance of your dependency
  T get<T>() {
    final object = _map[T]!(this);

    if (object is T Function(IocContainer container)) {
      return object(this);
    }

    return object as T;
  }
}

///A builder for creating an [IocContainer].
class IocContainerBuilder {
  final Map<Type, Object Function(IocContainer container)> _map = {};

  ///Add a factory to the container.
  void add<T>(T Function(IocContainer container) get) =>
      _map.putIfAbsent(T, () => get as Object Function(IocContainer container));

  ///Create an [IocContainer] from the [IocContainerBuilder].
  IocContainer toContainer() => IocContainer(
      Map<Type, Object Function(IocContainer container)>.unmodifiable(_map));
}

extension Extensions on IocContainerBuilder {
  ///Add a singleton object dependency to the container.
  void addSingletonObject<T>(T service) => add((i) => service);

  ///Add a singleton factory dependency to the container.
  void addSingleton<T>(T Function(IocContainer container) func) =>
      _map.putIfAbsent(T, () => (c) => func);
}
