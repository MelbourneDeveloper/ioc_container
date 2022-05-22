class IocContainer {
  final Map<Type, Object Function(IocContainer container)> _map;
  IocContainer(this._map);

  T get<T>() => _map[T]!(this) as T;
}

class IocContainerBuilder {
  final Map<Type, Object Function(IocContainer container)> _map = {};
  IocContainerBuilder add<T>(T Function(IocContainer container) get) {
    _map.putIfAbsent(T, () => get as Object Function(IocContainer container));
    return this;
  }

  IocContainer toContainer() => IocContainer(
      Map<Type, Object Function(IocContainer container)>.unmodifiable(_map));
}

extension Extensions on IocContainerBuilder {
  IocContainerBuilder addSingleton<T>(T service) => add((i) => service);
}
