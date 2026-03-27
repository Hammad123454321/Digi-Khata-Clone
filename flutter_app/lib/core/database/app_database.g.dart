// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
      'balance', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        name,
        phone,
        email,
        address,
        isActive,
        balance,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;
  final String? balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const Customer(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.name,
      this.phone,
      this.email,
      this.address,
      required this.isActive,
      this.balance,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || balance != null) {
      map['balance'] = Variable<String>(balance);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isActive: Value(isActive),
      balance: balance == null && nullToAbsent
          ? const Value.absent()
          : Value(balance),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      balance: serializer.fromJson<String?>(json['balance']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'isActive': serializer.toJson<bool>(isActive),
      'balance': serializer.toJson<String?>(balance),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Customer copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> address = const Value.absent(),
          bool? isActive,
          Value<String?> balance = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      Customer(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        address: address.present ? address.value : this.address,
        isActive: isActive ?? this.isActive,
        balance: balance.present ? balance.value : this.balance,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      balance: data.balance.present ? data.balance.value : this.balance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('balance: $balance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, clientId, name, phone, email,
      address, isActive, balance, createdAt, updatedAt, isSynced, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.isActive == this.isActive &&
          other.balance == this.balance &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<bool> isActive;
  final Value<String?> balance;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.balance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.balance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<bool>? isActive,
    Expression<String>? balance,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
      if (balance != null) 'balance': balance,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  CustomersCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? address,
      Value<bool>? isActive,
      Value<String?>? balance,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return CustomersCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('balance: $balance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
      'balance', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        name,
        phone,
        email,
        address,
        isActive,
        balance,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<Supplier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;
  final String? balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const Supplier(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.name,
      this.phone,
      this.email,
      this.address,
      required this.isActive,
      this.balance,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || balance != null) {
      map['balance'] = Variable<String>(balance);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isActive: Value(isActive),
      balance: balance == null && nullToAbsent
          ? const Value.absent()
          : Value(balance),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      balance: serializer.fromJson<String?>(json['balance']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'isActive': serializer.toJson<bool>(isActive),
      'balance': serializer.toJson<String?>(balance),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Supplier copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> address = const Value.absent(),
          bool? isActive,
          Value<String?> balance = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      Supplier(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        address: address.present ? address.value : this.address,
        isActive: isActive ?? this.isActive,
        balance: balance.present ? balance.value : this.balance,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      balance: data.balance.present ? data.balance.value : this.balance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('balance: $balance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, clientId, name, phone, email,
      address, isActive, balance, createdAt, updatedAt, isSynced, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.isActive == this.isActive &&
          other.balance == this.balance &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<bool> isActive;
  final Value<String?> balance;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.balance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  SuppliersCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.balance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Supplier> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<bool>? isActive,
    Expression<String>? balance,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
      if (balance != null) 'balance': balance,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  SuppliersCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? address,
      Value<bool>? isActive,
      Value<String?>? balance,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return SuppliersCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('balance: $balance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        name,
        description,
        isActive,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const ExpenseCategory(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.name,
      this.description,
      required this.isActive,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ExpenseCategory copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? name,
          Value<String?> description = const Value.absent(),
          bool? isActive,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      ExpenseCategory(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, clientId, name, description,
      isActive, createdAt, updatedAt, isSynced, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ExpenseCategory> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  ExpenseCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? name,
      Value<String?>? description,
      Value<bool>? isActive,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityLocalIdMeta =
      const VerificationMeta('entityLocalId');
  @override
  late final GeneratedColumn<int> entityLocalId = GeneratedColumn<int>(
      'entity_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _entityServerIdMeta =
      const VerificationMeta('entityServerId');
  @override
  late final GeneratedColumn<String> entityServerId = GeneratedColumn<String>(
      'entity_server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDeadLetterMeta =
      const VerificationMeta('isDeadLetter');
  @override
  late final GeneratedColumn<bool> isDeadLetter = GeneratedColumn<bool>(
      'is_dead_letter', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_dead_letter" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityLocalId,
        entityServerId,
        action,
        payload,
        createdAt,
        lastAttemptAt,
        nextAttemptAt,
        retryCount,
        lastError,
        isDeadLetter
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_local_id')) {
      context.handle(
          _entityLocalIdMeta,
          entityLocalId.isAcceptableOrUnknown(
              data['entity_local_id']!, _entityLocalIdMeta));
    }
    if (data.containsKey('entity_server_id')) {
      context.handle(
          _entityServerIdMeta,
          entityServerId.isAcceptableOrUnknown(
              data['entity_server_id']!, _entityServerIdMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('is_dead_letter')) {
      context.handle(
          _isDeadLetterMeta,
          isDeadLetter.isAcceptableOrUnknown(
              data['is_dead_letter']!, _isDeadLetterMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entity_local_id']),
      entityServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entity_server_id']),
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      isDeadLetter: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dead_letter'])!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String entityType;
  final int? entityLocalId;
  final String? entityServerId;
  final String action;
  final String payload;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? nextAttemptAt;
  final int retryCount;
  final String? lastError;
  final bool isDeadLetter;
  const SyncQueueEntry(
      {required this.id,
      required this.entityType,
      this.entityLocalId,
      this.entityServerId,
      required this.action,
      required this.payload,
      required this.createdAt,
      this.lastAttemptAt,
      this.nextAttemptAt,
      required this.retryCount,
      this.lastError,
      required this.isDeadLetter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityLocalId != null) {
      map['entity_local_id'] = Variable<int>(entityLocalId);
    }
    if (!nullToAbsent || entityServerId != null) {
      map['entity_server_id'] = Variable<String>(entityServerId);
    }
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['is_dead_letter'] = Variable<bool>(isDeadLetter);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityLocalId: entityLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityLocalId),
      entityServerId: entityServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityServerId),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      isDeadLetter: Value(isDeadLetter),
    );
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityLocalId: serializer.fromJson<int?>(json['entityLocalId']),
      entityServerId: serializer.fromJson<String?>(json['entityServerId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      isDeadLetter: serializer.fromJson<bool>(json['isDeadLetter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityLocalId': serializer.toJson<int?>(entityLocalId),
      'entityServerId': serializer.toJson<String?>(entityServerId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'isDeadLetter': serializer.toJson<bool>(isDeadLetter),
    };
  }

  SyncQueueEntry copyWith(
          {int? id,
          String? entityType,
          Value<int?> entityLocalId = const Value.absent(),
          Value<String?> entityServerId = const Value.absent(),
          String? action,
          String? payload,
          DateTime? createdAt,
          Value<DateTime?> lastAttemptAt = const Value.absent(),
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          bool? isDeadLetter}) =>
      SyncQueueEntry(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityLocalId:
            entityLocalId.present ? entityLocalId.value : this.entityLocalId,
        entityServerId:
            entityServerId.present ? entityServerId.value : this.entityServerId,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        isDeadLetter: isDeadLetter ?? this.isDeadLetter,
      );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityLocalId: data.entityLocalId.present
          ? data.entityLocalId.value
          : this.entityLocalId,
      entityServerId: data.entityServerId.present
          ? data.entityServerId.value
          : this.entityServerId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      isDeadLetter: data.isDeadLetter.present
          ? data.isDeadLetter.value
          : this.isDeadLetter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('entityServerId: $entityServerId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('isDeadLetter: $isDeadLetter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entityType,
      entityLocalId,
      entityServerId,
      action,
      payload,
      createdAt,
      lastAttemptAt,
      nextAttemptAt,
      retryCount,
      lastError,
      isDeadLetter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityLocalId == this.entityLocalId &&
          other.entityServerId == this.entityServerId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.isDeadLetter == this.isDeadLetter);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int?> entityLocalId;
  final Value<String?> entityServerId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<bool> isDeadLetter;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLocalId = const Value.absent(),
    this.entityServerId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isDeadLetter = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    this.entityLocalId = const Value.absent(),
    this.entityServerId = const Value.absent(),
    required String action,
    required String payload,
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isDeadLetter = const Value.absent(),
  })  : entityType = Value(entityType),
        action = Value(action),
        payload = Value(payload);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityLocalId,
    Expression<String>? entityServerId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<bool>? isDeadLetter,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityLocalId != null) 'entity_local_id': entityLocalId,
      if (entityServerId != null) 'entity_server_id': entityServerId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (isDeadLetter != null) 'is_dead_letter': isDeadLetter,
    });
  }

  SyncQueueEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<int?>? entityLocalId,
      Value<String?>? entityServerId,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastAttemptAt,
      Value<DateTime?>? nextAttemptAt,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<bool>? isDeadLetter}) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityLocalId: entityLocalId ?? this.entityLocalId,
      entityServerId: entityServerId ?? this.entityServerId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      isDeadLetter: isDeadLetter ?? this.isDeadLetter,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityLocalId.present) {
      map['entity_local_id'] = Variable<int>(entityLocalId.value);
    }
    if (entityServerId.present) {
      map['entity_server_id'] = Variable<String>(entityServerId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (isDeadLetter.present) {
      map['is_dead_letter'] = Variable<bool>(isDeadLetter.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('entityServerId: $entityServerId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('isDeadLetter: $isDeadLetter')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceTypeMeta =
      const VerificationMeta('invoiceType');
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
      'invoice_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<String> subtotal = GeneratedColumn<String>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<String> taxAmount = GeneratedColumn<String>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<String> discountAmount = GeneratedColumn<String>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<String> totalAmount = GeneratedColumn<String>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<String> paidAmount = GeneratedColumn<String>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pdfPathMeta =
      const VerificationMeta('pdfPath');
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
      'pdf_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        invoiceNumber,
        customerId,
        invoiceType,
        date,
        subtotal,
        taxAmount,
        discountAmount,
        totalAmount,
        paidAmount,
        remarks,
        pdfPath,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
          _invoiceTypeMeta,
          invoiceType.isAcceptableOrUnknown(
              data['invoice_type']!, _invoiceTypeMeta));
    } else if (isInserting) {
      context.missing(_invoiceTypeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    } else if (isInserting) {
      context.missing(_discountAmountMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    } else if (isInserting) {
      context.missing(_paidAmountMeta);
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('pdf_path')) {
      context.handle(_pdfPathMeta,
          pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      invoiceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_type'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtotal'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tax_amount'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}discount_amount'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}total_amount'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paid_amount'])!,
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      pdfPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pdf_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final int id;
  final String serverId;
  final String invoiceNumber;
  final String? customerId;
  final String invoiceType;
  final DateTime date;
  final String subtotal;
  final String taxAmount;
  final String discountAmount;
  final String totalAmount;
  final String paidAmount;
  final String? remarks;
  final String? pdfPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const Invoice(
      {required this.id,
      required this.serverId,
      required this.invoiceNumber,
      this.customerId,
      required this.invoiceType,
      required this.date,
      required this.subtotal,
      required this.taxAmount,
      required this.discountAmount,
      required this.totalAmount,
      required this.paidAmount,
      this.remarks,
      this.pdfPath,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_id'] = Variable<String>(serverId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['invoice_type'] = Variable<String>(invoiceType);
    map['date'] = Variable<DateTime>(date);
    map['subtotal'] = Variable<String>(subtotal);
    map['tax_amount'] = Variable<String>(taxAmount);
    map['discount_amount'] = Variable<String>(discountAmount);
    map['total_amount'] = Variable<String>(totalAmount);
    map['paid_amount'] = Variable<String>(paidAmount);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || pdfPath != null) {
      map['pdf_path'] = Variable<String>(pdfPath);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      serverId: Value(serverId),
      invoiceNumber: Value(invoiceNumber),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      invoiceType: Value(invoiceType),
      date: Value(date),
      subtotal: Value(subtotal),
      taxAmount: Value(taxAmount),
      discountAmount: Value(discountAmount),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      pdfPath: pdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfPath),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      invoiceType: serializer.fromJson<String>(json['invoiceType']),
      date: serializer.fromJson<DateTime>(json['date']),
      subtotal: serializer.fromJson<String>(json['subtotal']),
      taxAmount: serializer.fromJson<String>(json['taxAmount']),
      discountAmount: serializer.fromJson<String>(json['discountAmount']),
      totalAmount: serializer.fromJson<String>(json['totalAmount']),
      paidAmount: serializer.fromJson<String>(json['paidAmount']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      pdfPath: serializer.fromJson<String?>(json['pdfPath']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String>(serverId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'customerId': serializer.toJson<String?>(customerId),
      'invoiceType': serializer.toJson<String>(invoiceType),
      'date': serializer.toJson<DateTime>(date),
      'subtotal': serializer.toJson<String>(subtotal),
      'taxAmount': serializer.toJson<String>(taxAmount),
      'discountAmount': serializer.toJson<String>(discountAmount),
      'totalAmount': serializer.toJson<String>(totalAmount),
      'paidAmount': serializer.toJson<String>(paidAmount),
      'remarks': serializer.toJson<String?>(remarks),
      'pdfPath': serializer.toJson<String?>(pdfPath),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Invoice copyWith(
          {int? id,
          String? serverId,
          String? invoiceNumber,
          Value<String?> customerId = const Value.absent(),
          String? invoiceType,
          DateTime? date,
          String? subtotal,
          String? taxAmount,
          String? discountAmount,
          String? totalAmount,
          String? paidAmount,
          Value<String?> remarks = const Value.absent(),
          Value<String?> pdfPath = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      Invoice(
        id: id ?? this.id,
        serverId: serverId ?? this.serverId,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        customerId: customerId.present ? customerId.value : this.customerId,
        invoiceType: invoiceType ?? this.invoiceType,
        date: date ?? this.date,
        subtotal: subtotal ?? this.subtotal,
        taxAmount: taxAmount ?? this.taxAmount,
        discountAmount: discountAmount ?? this.discountAmount,
        totalAmount: totalAmount ?? this.totalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        remarks: remarks.present ? remarks.value : this.remarks,
        pdfPath: pdfPath.present ? pdfPath.value : this.pdfPath,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      invoiceType:
          data.invoiceType.present ? data.invoiceType.value : this.invoiceType,
      date: data.date.present ? data.date.value : this.date,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('customerId: $customerId, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('date: $date, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('remarks: $remarks, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      invoiceNumber,
      customerId,
      invoiceType,
      date,
      subtotal,
      taxAmount,
      discountAmount,
      totalAmount,
      paidAmount,
      remarks,
      pdfPath,
      createdAt,
      updatedAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.customerId == this.customerId &&
          other.invoiceType == this.invoiceType &&
          other.date == this.date &&
          other.subtotal == this.subtotal &&
          other.taxAmount == this.taxAmount &&
          other.discountAmount == this.discountAmount &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.remarks == this.remarks &&
          other.pdfPath == this.pdfPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<int> id;
  final Value<String> serverId;
  final Value<String> invoiceNumber;
  final Value<String?> customerId;
  final Value<String> invoiceType;
  final Value<DateTime> date;
  final Value<String> subtotal;
  final Value<String> taxAmount;
  final Value<String> discountAmount;
  final Value<String> totalAmount;
  final Value<String> paidAmount;
  final Value<String?> remarks;
  final Value<String?> pdfPath;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.date = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.remarks = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    required String serverId,
    required String invoiceNumber,
    this.customerId = const Value.absent(),
    required String invoiceType,
    required DateTime date,
    required String subtotal,
    required String taxAmount,
    required String discountAmount,
    required String totalAmount,
    required String paidAmount,
    this.remarks = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : serverId = Value(serverId),
        invoiceNumber = Value(invoiceNumber),
        invoiceType = Value(invoiceType),
        date = Value(date),
        subtotal = Value(subtotal),
        taxAmount = Value(taxAmount),
        discountAmount = Value(discountAmount),
        totalAmount = Value(totalAmount),
        paidAmount = Value(paidAmount);
  static Insertable<Invoice> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? invoiceNumber,
    Expression<String>? customerId,
    Expression<String>? invoiceType,
    Expression<DateTime>? date,
    Expression<String>? subtotal,
    Expression<String>? taxAmount,
    Expression<String>? discountAmount,
    Expression<String>? totalAmount,
    Expression<String>? paidAmount,
    Expression<String>? remarks,
    Expression<String>? pdfPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (customerId != null) 'customer_id': customerId,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (date != null) 'date': date,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (remarks != null) 'remarks': remarks,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  InvoicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverId,
      Value<String>? invoiceNumber,
      Value<String?>? customerId,
      Value<String>? invoiceType,
      Value<DateTime>? date,
      Value<String>? subtotal,
      Value<String>? taxAmount,
      Value<String>? discountAmount,
      Value<String>? totalAmount,
      Value<String>? paidAmount,
      Value<String?>? remarks,
      Value<String?>? pdfPath,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      invoiceType: invoiceType ?? this.invoiceType,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remarks: remarks ?? this.remarks,
      pdfPath: pdfPath ?? this.pdfPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<String>(subtotal.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<String>(taxAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<String>(discountAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<String>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<String>(paidAmount.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('customerId: $customerId, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('date: $date, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('remarks: $remarks, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _invoiceServerIdMeta =
      const VerificationMeta('invoiceServerId');
  @override
  late final GeneratedColumn<String> invoiceServerId = GeneratedColumn<String>(
      'invoice_server_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<String> totalPrice = GeneratedColumn<String>(
      'total_price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        invoiceServerId,
        itemId,
        itemName,
        quantity,
        unitPrice,
        totalPrice
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('invoice_server_id')) {
      context.handle(
          _invoiceServerIdMeta,
          invoiceServerId.isAcceptableOrUnknown(
              data['invoice_server_id']!, _invoiceServerIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceServerIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      invoiceServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}invoice_server_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id']),
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_price'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}total_price'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final int id;
  final String? serverId;
  final String invoiceServerId;
  final String? itemId;
  final String itemName;
  final String quantity;
  final String unitPrice;
  final String totalPrice;
  const InvoiceItem(
      {required this.id,
      this.serverId,
      required this.invoiceServerId,
      this.itemId,
      required this.itemName,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['invoice_server_id'] = Variable<String>(invoiceServerId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['item_name'] = Variable<String>(itemName);
    map['quantity'] = Variable<String>(quantity);
    map['unit_price'] = Variable<String>(unitPrice);
    map['total_price'] = Variable<String>(totalPrice);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      invoiceServerId: Value(invoiceServerId),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      itemName: Value(itemName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      invoiceServerId: serializer.fromJson<String>(json['invoiceServerId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unitPrice: serializer.fromJson<String>(json['unitPrice']),
      totalPrice: serializer.fromJson<String>(json['totalPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'invoiceServerId': serializer.toJson<String>(invoiceServerId),
      'itemId': serializer.toJson<String?>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'quantity': serializer.toJson<String>(quantity),
      'unitPrice': serializer.toJson<String>(unitPrice),
      'totalPrice': serializer.toJson<String>(totalPrice),
    };
  }

  InvoiceItem copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          String? invoiceServerId,
          Value<String?> itemId = const Value.absent(),
          String? itemName,
          String? quantity,
          String? unitPrice,
          String? totalPrice}) =>
      InvoiceItem(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        invoiceServerId: invoiceServerId ?? this.invoiceServerId,
        itemId: itemId.present ? itemId.value : this.itemId,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      invoiceServerId: data.invoiceServerId.present
          ? data.invoiceServerId.value
          : this.invoiceServerId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('invoiceServerId: $invoiceServerId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, invoiceServerId, itemId,
      itemName, quantity, unitPrice, totalPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.invoiceServerId == this.invoiceServerId &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> invoiceServerId;
  final Value<String?> itemId;
  final Value<String> itemName;
  final Value<String> quantity;
  final Value<String> unitPrice;
  final Value<String> totalPrice;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.invoiceServerId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String invoiceServerId,
    this.itemId = const Value.absent(),
    required String itemName,
    required String quantity,
    required String unitPrice,
    required String totalPrice,
  })  : invoiceServerId = Value(invoiceServerId),
        itemName = Value(itemName),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice),
        totalPrice = Value(totalPrice);
  static Insertable<InvoiceItem> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? invoiceServerId,
    Expression<String>? itemId,
    Expression<String>? itemName,
    Expression<String>? quantity,
    Expression<String>? unitPrice,
    Expression<String>? totalPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (invoiceServerId != null) 'invoice_server_id': invoiceServerId,
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String>? invoiceServerId,
      Value<String?>? itemId,
      Value<String>? itemName,
      Value<String>? quantity,
      Value<String>? unitPrice,
      Value<String>? totalPrice}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      invoiceServerId: invoiceServerId ?? this.invoiceServerId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (invoiceServerId.present) {
      map['invoice_server_id'] = Variable<String>(invoiceServerId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<String>(totalPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('invoiceServerId: $invoiceServerId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }
}

class $StockItemsTable extends StockItems
    with TableInfo<$StockItemsTable, StockItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<String> purchasePrice = GeneratedColumn<String>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<String> salePrice = GeneratedColumn<String>(
      'sale_price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentStockMeta =
      const VerificationMeta('currentStock');
  @override
  late final GeneratedColumn<String> currentStock = GeneratedColumn<String>(
      'current_stock', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        name,
        purchasePrice,
        salePrice,
        unit,
        currentStock,
        description,
        isActive,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_items';
  @override
  VerificationContext validateIntegrity(Insertable<StockItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    } else if (isInserting) {
      context.missing(_salePriceMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('current_stock')) {
      context.handle(
          _currentStockMeta,
          currentStock.isAcceptableOrUnknown(
              data['current_stock']!, _currentStockMeta));
    } else if (isInserting) {
      context.missing(_currentStockMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_price'])!,
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_price'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      currentStock: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}current_stock'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $StockItemsTable createAlias(String alias) {
    return $StockItemsTable(attachedDatabase, alias);
  }
}

class StockItem extends DataClass implements Insertable<StockItem> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String name;
  final String purchasePrice;
  final String salePrice;
  final String unit;
  final String currentStock;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const StockItem(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.name,
      required this.purchasePrice,
      required this.salePrice,
      required this.unit,
      required this.currentStock,
      this.description,
      required this.isActive,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['name'] = Variable<String>(name);
    map['purchase_price'] = Variable<String>(purchasePrice);
    map['sale_price'] = Variable<String>(salePrice);
    map['unit'] = Variable<String>(unit);
    map['current_stock'] = Variable<String>(currentStock);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  StockItemsCompanion toCompanion(bool nullToAbsent) {
    return StockItemsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      name: Value(name),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      unit: Value(unit),
      currentStock: Value(currentStock),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory StockItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockItem(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      purchasePrice: serializer.fromJson<String>(json['purchasePrice']),
      salePrice: serializer.fromJson<String>(json['salePrice']),
      unit: serializer.fromJson<String>(json['unit']),
      currentStock: serializer.fromJson<String>(json['currentStock']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'name': serializer.toJson<String>(name),
      'purchasePrice': serializer.toJson<String>(purchasePrice),
      'salePrice': serializer.toJson<String>(salePrice),
      'unit': serializer.toJson<String>(unit),
      'currentStock': serializer.toJson<String>(currentStock),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  StockItem copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? name,
          String? purchasePrice,
          String? salePrice,
          String? unit,
          String? currentStock,
          Value<String?> description = const Value.absent(),
          bool? isActive,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      StockItem(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        name: name ?? this.name,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        unit: unit ?? this.unit,
        currentStock: currentStock ?? this.currentStock,
        description: description.present ? description.value : this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  StockItem copyWithCompanion(StockItemsCompanion data) {
    return StockItem(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      unit: data.unit.present ? data.unit.value : this.unit,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockItem(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      name,
      purchasePrice,
      salePrice,
      unit,
      currentStock,
      description,
      isActive,
      createdAt,
      updatedAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockItem &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.purchasePrice == this.purchasePrice &&
          other.salePrice == this.salePrice &&
          other.unit == this.unit &&
          other.currentStock == this.currentStock &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class StockItemsCompanion extends UpdateCompanion<StockItem> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> name;
  final Value<String> purchasePrice;
  final Value<String> salePrice;
  final Value<String> unit;
  final Value<String> currentStock;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const StockItemsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.unit = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  StockItemsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String name,
    required String purchasePrice,
    required String salePrice,
    required String unit,
    required String currentStock,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : name = Value(name),
        purchasePrice = Value(purchasePrice),
        salePrice = Value(salePrice),
        unit = Value(unit),
        currentStock = Value(currentStock);
  static Insertable<StockItem> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? purchasePrice,
    Expression<String>? salePrice,
    Expression<String>? unit,
    Expression<String>? currentStock,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (unit != null) 'unit': unit,
      if (currentStock != null) 'current_stock': currentStock,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  StockItemsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? name,
      Value<String>? purchasePrice,
      Value<String>? salePrice,
      Value<String>? unit,
      Value<String>? currentStock,
      Value<String?>? description,
      Value<bool>? isActive,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return StockItemsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<String>(purchasePrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<String>(salePrice.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<String>(currentStock.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockItemsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $InventoryTransactionsTable extends InventoryTransactions
    with TableInfo<$InventoryTransactionsTable, InventoryTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
      'unit_price', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        itemId,
        transactionType,
        quantity,
        unitPrice,
        date,
        referenceId,
        referenceType,
        remarks,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<InventoryTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_price']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $InventoryTransactionsTable createAlias(String alias) {
    return $InventoryTransactionsTable(attachedDatabase, alias);
  }
}

class InventoryTransaction extends DataClass
    implements Insertable<InventoryTransaction> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String itemId;
  final String transactionType;
  final String quantity;
  final String? unitPrice;
  final DateTime date;
  final String? referenceId;
  final String? referenceType;
  final String? remarks;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const InventoryTransaction(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.itemId,
      required this.transactionType,
      required this.quantity,
      this.unitPrice,
      required this.date,
      this.referenceId,
      this.referenceType,
      this.remarks,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['item_id'] = Variable<String>(itemId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['quantity'] = Variable<String>(quantity);
    if (!nullToAbsent || unitPrice != null) {
      map['unit_price'] = Variable<String>(unitPrice);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InventoryTransactionsCompanion toCompanion(bool nullToAbsent) {
    return InventoryTransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      itemId: Value(itemId),
      transactionType: Value(transactionType),
      quantity: Value(quantity),
      unitPrice: unitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPrice),
      date: Value(date),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory InventoryTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryTransaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unitPrice: serializer.fromJson<String?>(json['unitPrice']),
      date: serializer.fromJson<DateTime>(json['date']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'itemId': serializer.toJson<String>(itemId),
      'transactionType': serializer.toJson<String>(transactionType),
      'quantity': serializer.toJson<String>(quantity),
      'unitPrice': serializer.toJson<String?>(unitPrice),
      'date': serializer.toJson<DateTime>(date),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'remarks': serializer.toJson<String?>(remarks),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  InventoryTransaction copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? itemId,
          String? transactionType,
          String? quantity,
          Value<String?> unitPrice = const Value.absent(),
          DateTime? date,
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      InventoryTransaction(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        itemId: itemId ?? this.itemId,
        transactionType: transactionType ?? this.transactionType,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice.present ? unitPrice.value : this.unitPrice,
        date: date ?? this.date,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        remarks: remarks.present ? remarks.value : this.remarks,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  InventoryTransaction copyWithCompanion(InventoryTransactionsCompanion data) {
    return InventoryTransaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      date: data.date.present ? data.date.value : this.date,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('itemId: $itemId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('date: $date, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      itemId,
      transactionType,
      quantity,
      unitPrice,
      date,
      referenceId,
      referenceType,
      remarks,
      createdAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryTransaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.itemId == this.itemId &&
          other.transactionType == this.transactionType &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.date == this.date &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.remarks == this.remarks &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class InventoryTransactionsCompanion
    extends UpdateCompanion<InventoryTransaction> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> itemId;
  final Value<String> transactionType;
  final Value<String> quantity;
  final Value<String?> unitPrice;
  final Value<DateTime> date;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<String?> remarks;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const InventoryTransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.date = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  InventoryTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String itemId,
    required String transactionType,
    required String quantity,
    this.unitPrice = const Value.absent(),
    required DateTime date,
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : itemId = Value(itemId),
        transactionType = Value(transactionType),
        quantity = Value(quantity),
        date = Value(date);
  static Insertable<InventoryTransaction> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? itemId,
    Expression<String>? transactionType,
    Expression<String>? quantity,
    Expression<String>? unitPrice,
    Expression<DateTime>? date,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<String>? remarks,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (itemId != null) 'item_id': itemId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (date != null) 'date': date,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  InventoryTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? itemId,
      Value<String>? transactionType,
      Value<String>? quantity,
      Value<String?>? unitPrice,
      Value<DateTime>? date,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<String?>? remarks,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return InventoryTransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      itemId: itemId ?? this.itemId,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      date: date ?? this.date,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('itemId: $itemId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('date: $date, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $CustomerTransactionsTable extends CustomerTransactions
    with TableInfo<$CustomerTransactionsTable, CustomerTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        customerId,
        transactionType,
        amount,
        date,
        referenceId,
        referenceType,
        remarks,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomerTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $CustomerTransactionsTable createAlias(String alias) {
    return $CustomerTransactionsTable(attachedDatabase, alias);
  }
}

class CustomerTransaction extends DataClass
    implements Insertable<CustomerTransaction> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String customerId;
  final String transactionType;
  final String amount;
  final DateTime date;
  final String? referenceId;
  final String? referenceType;
  final String? remarks;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const CustomerTransaction(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.customerId,
      required this.transactionType,
      required this.amount,
      required this.date,
      this.referenceId,
      this.referenceType,
      this.remarks,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['amount'] = Variable<String>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CustomerTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CustomerTransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      customerId: Value(customerId),
      transactionType: Value(transactionType),
      amount: Value(amount),
      date: Value(date),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory CustomerTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerTransaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      amount: serializer.fromJson<String>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'customerId': serializer.toJson<String>(customerId),
      'transactionType': serializer.toJson<String>(transactionType),
      'amount': serializer.toJson<String>(amount),
      'date': serializer.toJson<DateTime>(date),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'remarks': serializer.toJson<String?>(remarks),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CustomerTransaction copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? customerId,
          String? transactionType,
          String? amount,
          DateTime? date,
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      CustomerTransaction(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        customerId: customerId ?? this.customerId,
        transactionType: transactionType ?? this.transactionType,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        remarks: remarks.present ? remarks.value : this.remarks,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  CustomerTransaction copyWithCompanion(CustomerTransactionsCompanion data) {
    return CustomerTransaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerTransaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('customerId: $customerId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      customerId,
      transactionType,
      amount,
      date,
      referenceId,
      referenceType,
      remarks,
      createdAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerTransaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.customerId == this.customerId &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.remarks == this.remarks &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class CustomerTransactionsCompanion
    extends UpdateCompanion<CustomerTransaction> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> customerId;
  final Value<String> transactionType;
  final Value<String> amount;
  final Value<DateTime> date;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<String?> remarks;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const CustomerTransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  CustomerTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String customerId,
    required String transactionType,
    required String amount,
    required DateTime date,
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : customerId = Value(customerId),
        transactionType = Value(transactionType),
        amount = Value(amount),
        date = Value(date);
  static Insertable<CustomerTransaction> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? customerId,
    Expression<String>? transactionType,
    Expression<String>? amount,
    Expression<DateTime>? date,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<String>? remarks,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (customerId != null) 'customer_id': customerId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  CustomerTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? customerId,
      Value<String>? transactionType,
      Value<String>? amount,
      Value<DateTime>? date,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<String?>? remarks,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return CustomerTransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      customerId: customerId ?? this.customerId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('customerId: $customerId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $SupplierTransactionsTable extends SupplierTransactions
    with TableInfo<$SupplierTransactionsTable, SupplierTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        supplierId,
        transactionType,
        amount,
        date,
        referenceId,
        referenceType,
        remarks,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<SupplierTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SupplierTransactionsTable createAlias(String alias) {
    return $SupplierTransactionsTable(attachedDatabase, alias);
  }
}

class SupplierTransaction extends DataClass
    implements Insertable<SupplierTransaction> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String supplierId;
  final String transactionType;
  final String amount;
  final DateTime date;
  final String? referenceId;
  final String? referenceType;
  final String? remarks;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const SupplierTransaction(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.supplierId,
      required this.transactionType,
      required this.amount,
      required this.date,
      this.referenceId,
      this.referenceType,
      this.remarks,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['supplier_id'] = Variable<String>(supplierId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['amount'] = Variable<String>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SupplierTransactionsCompanion toCompanion(bool nullToAbsent) {
    return SupplierTransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      supplierId: Value(supplierId),
      transactionType: Value(transactionType),
      amount: Value(amount),
      date: Value(date),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory SupplierTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierTransaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      amount: serializer.fromJson<String>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'supplierId': serializer.toJson<String>(supplierId),
      'transactionType': serializer.toJson<String>(transactionType),
      'amount': serializer.toJson<String>(amount),
      'date': serializer.toJson<DateTime>(date),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'remarks': serializer.toJson<String?>(remarks),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SupplierTransaction copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? supplierId,
          String? transactionType,
          String? amount,
          DateTime? date,
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      SupplierTransaction(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        supplierId: supplierId ?? this.supplierId,
        transactionType: transactionType ?? this.transactionType,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        remarks: remarks.present ? remarks.value : this.remarks,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  SupplierTransaction copyWithCompanion(SupplierTransactionsCompanion data) {
    return SupplierTransaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierTransaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('supplierId: $supplierId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      supplierId,
      transactionType,
      amount,
      date,
      referenceId,
      referenceType,
      remarks,
      createdAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierTransaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.supplierId == this.supplierId &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.remarks == this.remarks &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class SupplierTransactionsCompanion
    extends UpdateCompanion<SupplierTransaction> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> supplierId;
  final Value<String> transactionType;
  final Value<String> amount;
  final Value<DateTime> date;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<String?> remarks;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const SupplierTransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  SupplierTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String supplierId,
    required String transactionType,
    required String amount,
    required DateTime date,
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : supplierId = Value(supplierId),
        transactionType = Value(transactionType),
        amount = Value(amount),
        date = Value(date);
  static Insertable<SupplierTransaction> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? supplierId,
    Expression<String>? transactionType,
    Expression<String>? amount,
    Expression<DateTime>? date,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<String>? remarks,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  SupplierTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? supplierId,
      Value<String>? transactionType,
      Value<String>? amount,
      Value<DateTime>? date,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<String?>? remarks,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return SupplierTransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      supplierId: supplierId ?? this.supplierId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('supplierId: $supplierId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
      'payment_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        categoryId,
        amount,
        date,
        paymentMode,
        description,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
          _paymentModeMeta,
          paymentMode.isAcceptableOrUnknown(
              data['payment_mode']!, _paymentModeMeta));
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      paymentMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_mode'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String categoryId;
  final String amount;
  final DateTime date;
  final String paymentMode;
  final String? description;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const Expense(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.categoryId,
      required this.amount,
      required this.date,
      required this.paymentMode,
      this.description,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['category_id'] = Variable<String>(categoryId);
    map['amount'] = Variable<String>(amount);
    map['date'] = Variable<DateTime>(date);
    map['payment_mode'] = Variable<String>(paymentMode);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      date: Value(date),
      paymentMode: Value(paymentMode),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amount: serializer.fromJson<String>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'categoryId': serializer.toJson<String>(categoryId),
      'amount': serializer.toJson<String>(amount),
      'date': serializer.toJson<DateTime>(date),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Expense copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? categoryId,
          String? amount,
          DateTime? date,
          String? paymentMode,
          Value<String?> description = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      Expense(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        paymentMode: paymentMode ?? this.paymentMode,
        description: description.present ? description.value : this.description,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, clientId, categoryId, amount,
      date, paymentMode, description, createdAt, isSynced, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.paymentMode == this.paymentMode &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> categoryId;
  final Value<String> amount;
  final Value<DateTime> date;
  final Value<String> paymentMode;
  final Value<String?> description;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String categoryId,
    required String amount,
    required DateTime date,
    required String paymentMode,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : categoryId = Value(categoryId),
        amount = Value(amount),
        date = Value(date),
        paymentMode = Value(paymentMode);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? categoryId,
    Expression<String>? amount,
    Expression<DateTime>? date,
    Expression<String>? paymentMode,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  ExpensesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? categoryId,
      Value<String>? amount,
      Value<DateTime>? date,
      Value<String>? paymentMode,
      Value<String?>? description,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $CashTransactionsTable extends CashTransactions
    with TableInfo<$CashTransactionsTable, CashTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        transactionType,
        amount,
        date,
        source,
        remarks,
        referenceId,
        referenceType,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<CashTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $CashTransactionsTable createAlias(String alias) {
    return $CashTransactionsTable(attachedDatabase, alias);
  }
}

class CashTransaction extends DataClass implements Insertable<CashTransaction> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String transactionType;
  final String amount;
  final DateTime date;
  final String? source;
  final String? remarks;
  final String? referenceId;
  final String? referenceType;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const CashTransaction(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.transactionType,
      required this.amount,
      required this.date,
      this.source,
      this.remarks,
      this.referenceId,
      this.referenceType,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['transaction_type'] = Variable<String>(transactionType);
    map['amount'] = Variable<String>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CashTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CashTransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      transactionType: Value(transactionType),
      amount: Value(amount),
      date: Value(date),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory CashTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashTransaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      amount: serializer.fromJson<String>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      source: serializer.fromJson<String?>(json['source']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'transactionType': serializer.toJson<String>(transactionType),
      'amount': serializer.toJson<String>(amount),
      'date': serializer.toJson<DateTime>(date),
      'source': serializer.toJson<String?>(source),
      'remarks': serializer.toJson<String?>(remarks),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CashTransaction copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? transactionType,
          String? amount,
          DateTime? date,
          Value<String?> source = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      CashTransaction(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        transactionType: transactionType ?? this.transactionType,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        source: source.present ? source.value : this.source,
        remarks: remarks.present ? remarks.value : this.remarks,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  CashTransaction copyWithCompanion(CashTransactionsCompanion data) {
    return CashTransaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      source: data.source.present ? data.source.value : this.source,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashTransaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('remarks: $remarks, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      transactionType,
      amount,
      date,
      source,
      remarks,
      referenceId,
      referenceType,
      createdAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashTransaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.source == this.source &&
          other.remarks == this.remarks &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class CashTransactionsCompanion extends UpdateCompanion<CashTransaction> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> transactionType;
  final Value<String> amount;
  final Value<DateTime> date;
  final Value<String?> source;
  final Value<String?> remarks;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const CashTransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.source = const Value.absent(),
    this.remarks = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  CashTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String transactionType,
    required String amount,
    required DateTime date,
    this.source = const Value.absent(),
    this.remarks = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : transactionType = Value(transactionType),
        amount = Value(amount),
        date = Value(date);
  static Insertable<CashTransaction> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? transactionType,
    Expression<String>? amount,
    Expression<DateTime>? date,
    Expression<String>? source,
    Expression<String>? remarks,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (source != null) 'source': source,
      if (remarks != null) 'remarks': remarks,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  CashTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? transactionType,
      Value<String>? amount,
      Value<DateTime>? date,
      Value<String?>? source,
      Value<String?>? remarks,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return CashTransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      source: source ?? this.source,
      remarks: remarks ?? this.remarks,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('remarks: $remarks, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $BankAccountsTable extends BankAccounts
    with TableInfo<$BankAccountsTable, BankAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountHolderNameMeta =
      const VerificationMeta('accountHolderName');
  @override
  late final GeneratedColumn<String> accountHolderName =
      GeneratedColumn<String>('account_holder_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
      'branch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ifscCodeMeta =
      const VerificationMeta('ifscCode');
  @override
  late final GeneratedColumn<String> ifscCode = GeneratedColumn<String>(
      'ifsc_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountTypeMeta =
      const VerificationMeta('accountType');
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
      'account_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<String> openingBalance = GeneratedColumn<String>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<String> currentBalance = GeneratedColumn<String>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        bankName,
        accountNumber,
        accountHolderName,
        branch,
        ifscCode,
        accountType,
        openingBalance,
        currentBalance,
        isActive,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<BankAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    } else if (isInserting) {
      context.missing(_accountNumberMeta);
    }
    if (data.containsKey('account_holder_name')) {
      context.handle(
          _accountHolderNameMeta,
          accountHolderName.isAcceptableOrUnknown(
              data['account_holder_name']!, _accountHolderNameMeta));
    }
    if (data.containsKey('branch')) {
      context.handle(_branchMeta,
          branch.isAcceptableOrUnknown(data['branch']!, _branchMeta));
    }
    if (data.containsKey('ifsc_code')) {
      context.handle(_ifscCodeMeta,
          ifscCode.isAcceptableOrUnknown(data['ifsc_code']!, _ifscCodeMeta));
    }
    if (data.containsKey('account_type')) {
      context.handle(
          _accountTypeMeta,
          accountType.isAcceptableOrUnknown(
              data['account_type']!, _accountTypeMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    } else if (isInserting) {
      context.missing(_openingBalanceMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    } else if (isInserting) {
      context.missing(_currentBalanceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      accountHolderName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_holder_name']),
      branch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch']),
      ifscCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ifsc_code']),
      accountType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_type']),
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}opening_balance'])!,
      currentBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_balance'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $BankAccountsTable createAlias(String alias) {
    return $BankAccountsTable(attachedDatabase, alias);
  }
}

class BankAccount extends DataClass implements Insertable<BankAccount> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String bankName;
  final String accountNumber;
  final String? accountHolderName;
  final String? branch;
  final String? ifscCode;
  final String? accountType;
  final String openingBalance;
  final String currentBalance;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const BankAccount(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.bankName,
      required this.accountNumber,
      this.accountHolderName,
      this.branch,
      this.ifscCode,
      this.accountType,
      required this.openingBalance,
      required this.currentBalance,
      required this.isActive,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['bank_name'] = Variable<String>(bankName);
    map['account_number'] = Variable<String>(accountNumber);
    if (!nullToAbsent || accountHolderName != null) {
      map['account_holder_name'] = Variable<String>(accountHolderName);
    }
    if (!nullToAbsent || branch != null) {
      map['branch'] = Variable<String>(branch);
    }
    if (!nullToAbsent || ifscCode != null) {
      map['ifsc_code'] = Variable<String>(ifscCode);
    }
    if (!nullToAbsent || accountType != null) {
      map['account_type'] = Variable<String>(accountType);
    }
    map['opening_balance'] = Variable<String>(openingBalance);
    map['current_balance'] = Variable<String>(currentBalance);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  BankAccountsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      bankName: Value(bankName),
      accountNumber: Value(accountNumber),
      accountHolderName: accountHolderName == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHolderName),
      branch:
          branch == null && nullToAbsent ? const Value.absent() : Value(branch),
      ifscCode: ifscCode == null && nullToAbsent
          ? const Value.absent()
          : Value(ifscCode),
      accountType: accountType == null && nullToAbsent
          ? const Value.absent()
          : Value(accountType),
      openingBalance: Value(openingBalance),
      currentBalance: Value(currentBalance),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory BankAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccount(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      bankName: serializer.fromJson<String>(json['bankName']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      accountHolderName:
          serializer.fromJson<String?>(json['accountHolderName']),
      branch: serializer.fromJson<String?>(json['branch']),
      ifscCode: serializer.fromJson<String?>(json['ifscCode']),
      accountType: serializer.fromJson<String?>(json['accountType']),
      openingBalance: serializer.fromJson<String>(json['openingBalance']),
      currentBalance: serializer.fromJson<String>(json['currentBalance']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'bankName': serializer.toJson<String>(bankName),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'accountHolderName': serializer.toJson<String?>(accountHolderName),
      'branch': serializer.toJson<String?>(branch),
      'ifscCode': serializer.toJson<String?>(ifscCode),
      'accountType': serializer.toJson<String?>(accountType),
      'openingBalance': serializer.toJson<String>(openingBalance),
      'currentBalance': serializer.toJson<String>(currentBalance),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  BankAccount copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? bankName,
          String? accountNumber,
          Value<String?> accountHolderName = const Value.absent(),
          Value<String?> branch = const Value.absent(),
          Value<String?> ifscCode = const Value.absent(),
          Value<String?> accountType = const Value.absent(),
          String? openingBalance,
          String? currentBalance,
          bool? isActive,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      BankAccount(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        bankName: bankName ?? this.bankName,
        accountNumber: accountNumber ?? this.accountNumber,
        accountHolderName: accountHolderName.present
            ? accountHolderName.value
            : this.accountHolderName,
        branch: branch.present ? branch.value : this.branch,
        ifscCode: ifscCode.present ? ifscCode.value : this.ifscCode,
        accountType: accountType.present ? accountType.value : this.accountType,
        openingBalance: openingBalance ?? this.openingBalance,
        currentBalance: currentBalance ?? this.currentBalance,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  BankAccount copyWithCompanion(BankAccountsCompanion data) {
    return BankAccount(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      accountHolderName: data.accountHolderName.present
          ? data.accountHolderName.value
          : this.accountHolderName,
      branch: data.branch.present ? data.branch.value : this.branch,
      ifscCode: data.ifscCode.present ? data.ifscCode.value : this.ifscCode,
      accountType:
          data.accountType.present ? data.accountType.value : this.accountType,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccount(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('accountHolderName: $accountHolderName, ')
          ..write('branch: $branch, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('accountType: $accountType, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      bankName,
      accountNumber,
      accountHolderName,
      branch,
      ifscCode,
      accountType,
      openingBalance,
      currentBalance,
      isActive,
      createdAt,
      updatedAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccount &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.bankName == this.bankName &&
          other.accountNumber == this.accountNumber &&
          other.accountHolderName == this.accountHolderName &&
          other.branch == this.branch &&
          other.ifscCode == this.ifscCode &&
          other.accountType == this.accountType &&
          other.openingBalance == this.openingBalance &&
          other.currentBalance == this.currentBalance &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class BankAccountsCompanion extends UpdateCompanion<BankAccount> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> bankName;
  final Value<String> accountNumber;
  final Value<String?> accountHolderName;
  final Value<String?> branch;
  final Value<String?> ifscCode;
  final Value<String?> accountType;
  final Value<String> openingBalance;
  final Value<String> currentBalance;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const BankAccountsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.accountHolderName = const Value.absent(),
    this.branch = const Value.absent(),
    this.ifscCode = const Value.absent(),
    this.accountType = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  BankAccountsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String bankName,
    required String accountNumber,
    this.accountHolderName = const Value.absent(),
    this.branch = const Value.absent(),
    this.ifscCode = const Value.absent(),
    this.accountType = const Value.absent(),
    required String openingBalance,
    required String currentBalance,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : bankName = Value(bankName),
        accountNumber = Value(accountNumber),
        openingBalance = Value(openingBalance),
        currentBalance = Value(currentBalance);
  static Insertable<BankAccount> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? bankName,
    Expression<String>? accountNumber,
    Expression<String>? accountHolderName,
    Expression<String>? branch,
    Expression<String>? ifscCode,
    Expression<String>? accountType,
    Expression<String>? openingBalance,
    Expression<String>? currentBalance,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      if (branch != null) 'branch': branch,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (accountType != null) 'account_type': accountType,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  BankAccountsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? bankName,
      Value<String>? accountNumber,
      Value<String?>? accountHolderName,
      Value<String?>? branch,
      Value<String?>? ifscCode,
      Value<String?>? accountType,
      Value<String>? openingBalance,
      Value<String>? currentBalance,
      Value<bool>? isActive,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return BankAccountsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      branch: branch ?? this.branch,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (accountHolderName.present) {
      map['account_holder_name'] = Variable<String>(accountHolderName.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (ifscCode.present) {
      map['ifsc_code'] = Variable<String>(ifscCode.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<String>(openingBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<String>(currentBalance.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('accountHolderName: $accountHolderName, ')
          ..write('branch: $branch, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('accountType: $accountType, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $BankTransactionsTable extends BankTransactions
    with TableInfo<$BankTransactionsTable, BankTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceNumberMeta =
      const VerificationMeta('referenceNumber');
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
      'reference_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        accountId,
        transactionType,
        amount,
        date,
        referenceNumber,
        remarks,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<BankTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
          _referenceNumberMeta,
          referenceNumber.isAcceptableOrUnknown(
              data['reference_number']!, _referenceNumberMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      referenceNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_number']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $BankTransactionsTable createAlias(String alias) {
    return $BankTransactionsTable(attachedDatabase, alias);
  }
}

class BankTransaction extends DataClass implements Insertable<BankTransaction> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String accountId;
  final String transactionType;
  final String amount;
  final DateTime date;
  final String? referenceNumber;
  final String? remarks;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const BankTransaction(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.accountId,
      required this.transactionType,
      required this.amount,
      required this.date,
      this.referenceNumber,
      this.remarks,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['account_id'] = Variable<String>(accountId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['amount'] = Variable<String>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  BankTransactionsCompanion toCompanion(bool nullToAbsent) {
    return BankTransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      accountId: Value(accountId),
      transactionType: Value(transactionType),
      amount: Value(amount),
      date: Value(date),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory BankTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankTransaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      amount: serializer.fromJson<String>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'accountId': serializer.toJson<String>(accountId),
      'transactionType': serializer.toJson<String>(transactionType),
      'amount': serializer.toJson<String>(amount),
      'date': serializer.toJson<DateTime>(date),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'remarks': serializer.toJson<String?>(remarks),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  BankTransaction copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? accountId,
          String? transactionType,
          String? amount,
          DateTime? date,
          Value<String?> referenceNumber = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      BankTransaction(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        accountId: accountId ?? this.accountId,
        transactionType: transactionType ?? this.transactionType,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        referenceNumber: referenceNumber.present
            ? referenceNumber.value
            : this.referenceNumber,
        remarks: remarks.present ? remarks.value : this.remarks,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  BankTransaction copyWithCompanion(BankTransactionsCompanion data) {
    return BankTransaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankTransaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('accountId: $accountId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      accountId,
      transactionType,
      amount,
      date,
      referenceNumber,
      remarks,
      createdAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankTransaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.accountId == this.accountId &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.referenceNumber == this.referenceNumber &&
          other.remarks == this.remarks &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class BankTransactionsCompanion extends UpdateCompanion<BankTransaction> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> accountId;
  final Value<String> transactionType;
  final Value<String> amount;
  final Value<DateTime> date;
  final Value<String?> referenceNumber;
  final Value<String?> remarks;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const BankTransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  BankTransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String accountId,
    required String transactionType,
    required String amount,
    required DateTime date,
    this.referenceNumber = const Value.absent(),
    this.remarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : accountId = Value(accountId),
        transactionType = Value(transactionType),
        amount = Value(amount),
        date = Value(date);
  static Insertable<BankTransaction> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? accountId,
    Expression<String>? transactionType,
    Expression<String>? amount,
    Expression<DateTime>? date,
    Expression<String>? referenceNumber,
    Expression<String>? remarks,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (accountId != null) 'account_id': accountId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  BankTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? accountId,
      Value<String>? transactionType,
      Value<String>? amount,
      Value<DateTime>? date,
      Value<String?>? referenceNumber,
      Value<String?>? remarks,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return BankTransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      accountId: accountId ?? this.accountId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('accountId: $accountId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('remarks: $remarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $StaffsTable extends Staffs with TableInfo<$StaffsTable, Staff> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        name,
        phone,
        email,
        role,
        address,
        isActive,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staffs';
  @override
  VerificationContext validateIntegrity(Insertable<Staff> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Staff map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Staff(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $StaffsTable createAlias(String alias) {
    return $StaffsTable(attachedDatabase, alias);
  }
}

class Staff extends DataClass implements Insertable<Staff> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String name;
  final String? phone;
  final String? email;
  final String? role;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const Staff(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.name,
      this.phone,
      this.email,
      this.role,
      this.address,
      required this.isActive,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  StaffsCompanion toCompanion(bool nullToAbsent) {
    return StaffsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Staff.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Staff(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      role: serializer.fromJson<String?>(json['role']),
      address: serializer.fromJson<String?>(json['address']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'role': serializer.toJson<String?>(role),
      'address': serializer.toJson<String?>(address),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Staff copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> role = const Value.absent(),
          Value<String?> address = const Value.absent(),
          bool? isActive,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      Staff(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        role: role.present ? role.value : this.role,
        address: address.present ? address.value : this.address,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Staff copyWithCompanion(StaffsCompanion data) {
    return Staff(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      address: data.address.present ? data.address.value : this.address,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Staff(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, clientId, name, phone, email,
      role, address, isActive, createdAt, updatedAt, isSynced, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Staff &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.role == this.role &&
          other.address == this.address &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class StaffsCompanion extends UpdateCompanion<Staff> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> role;
  final Value<String?> address;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const StaffsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  StaffsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.address = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Staff> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? address,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (address != null) 'address': address,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  StaffsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? role,
      Value<String?>? address,
      Value<bool>? isActive,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return StaffsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('address: $address, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $StaffSalariesTable extends StaffSalaries
    with TableInfo<$StaffSalariesTable, StaffSalary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffSalariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _staffIdMeta =
      const VerificationMeta('staffId');
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
      'staff_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentModeMeta =
      const VerificationMeta('paymentMode');
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
      'payment_mode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        staffId,
        amount,
        date,
        paymentMode,
        remarks,
        referenceId,
        referenceType,
        createdAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_salaries';
  @override
  VerificationContext validateIntegrity(Insertable<StaffSalary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('staff_id')) {
      context.handle(_staffIdMeta,
          staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta));
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
          _paymentModeMeta,
          paymentMode.isAcceptableOrUnknown(
              data['payment_mode']!, _paymentModeMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffSalary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffSalary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      staffId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      paymentMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_mode']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $StaffSalariesTable createAlias(String alias) {
    return $StaffSalariesTable(attachedDatabase, alias);
  }
}

class StaffSalary extends DataClass implements Insertable<StaffSalary> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String staffId;
  final String amount;
  final DateTime date;
  final String? paymentMode;
  final String? remarks;
  final String? referenceId;
  final String? referenceType;
  final DateTime? createdAt;
  final bool isSynced;
  final String syncStatus;
  const StaffSalary(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.staffId,
      required this.amount,
      required this.date,
      this.paymentMode,
      this.remarks,
      this.referenceId,
      this.referenceType,
      this.createdAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['staff_id'] = Variable<String>(staffId);
    map['amount'] = Variable<String>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || paymentMode != null) {
      map['payment_mode'] = Variable<String>(paymentMode);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  StaffSalariesCompanion toCompanion(bool nullToAbsent) {
    return StaffSalariesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      staffId: Value(staffId),
      amount: Value(amount),
      date: Value(date),
      paymentMode: paymentMode == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMode),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory StaffSalary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffSalary(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      staffId: serializer.fromJson<String>(json['staffId']),
      amount: serializer.fromJson<String>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      paymentMode: serializer.fromJson<String?>(json['paymentMode']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'staffId': serializer.toJson<String>(staffId),
      'amount': serializer.toJson<String>(amount),
      'date': serializer.toJson<DateTime>(date),
      'paymentMode': serializer.toJson<String?>(paymentMode),
      'remarks': serializer.toJson<String?>(remarks),
      'referenceId': serializer.toJson<String?>(referenceId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  StaffSalary copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? staffId,
          String? amount,
          DateTime? date,
          Value<String?> paymentMode = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          Value<String?> referenceId = const Value.absent(),
          Value<String?> referenceType = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      StaffSalary(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        staffId: staffId ?? this.staffId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        paymentMode: paymentMode.present ? paymentMode.value : this.paymentMode,
        remarks: remarks.present ? remarks.value : this.remarks,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        referenceType:
            referenceType.present ? referenceType.value : this.referenceType,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  StaffSalary copyWithCompanion(StaffSalariesCompanion data) {
    return StaffSalary(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffSalary(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('staffId: $staffId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('remarks: $remarks, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      staffId,
      amount,
      date,
      paymentMode,
      remarks,
      referenceId,
      referenceType,
      createdAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffSalary &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.staffId == this.staffId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.paymentMode == this.paymentMode &&
          other.remarks == this.remarks &&
          other.referenceId == this.referenceId &&
          other.referenceType == this.referenceType &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class StaffSalariesCompanion extends UpdateCompanion<StaffSalary> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> staffId;
  final Value<String> amount;
  final Value<DateTime> date;
  final Value<String?> paymentMode;
  final Value<String?> remarks;
  final Value<String?> referenceId;
  final Value<String?> referenceType;
  final Value<DateTime?> createdAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const StaffSalariesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.staffId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.remarks = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  StaffSalariesCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String staffId,
    required String amount,
    required DateTime date,
    this.paymentMode = const Value.absent(),
    this.remarks = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : staffId = Value(staffId),
        amount = Value(amount),
        date = Value(date);
  static Insertable<StaffSalary> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? staffId,
    Expression<String>? amount,
    Expression<DateTime>? date,
    Expression<String>? paymentMode,
    Expression<String>? remarks,
    Expression<String>? referenceId,
    Expression<String>? referenceType,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (staffId != null) 'staff_id': staffId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (remarks != null) 'remarks': remarks,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  StaffSalariesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? staffId,
      Value<String>? amount,
      Value<DateTime>? date,
      Value<String?>? paymentMode,
      Value<String?>? remarks,
      Value<String?>? referenceId,
      Value<String?>? referenceType,
      Value<DateTime?>? createdAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return StaffSalariesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      staffId: staffId ?? this.staffId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      remarks: remarks ?? this.remarks,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffSalariesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('staffId: $staffId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('remarks: $remarks, ')
          ..write('referenceId: $referenceId, ')
          ..write('referenceType: $referenceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityDisplayNameMeta =
      const VerificationMeta('entityDisplayName');
  @override
  late final GeneratedColumn<String> entityDisplayName =
      GeneratedColumn<String>('entity_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entityPhoneMeta =
      const VerificationMeta('entityPhone');
  @override
  late final GeneratedColumn<String> entityPhone = GeneratedColumn<String>(
      'entity_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isResolvedMeta =
      const VerificationMeta('isResolved');
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
      'is_resolved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_resolved" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _resolvedAtMeta =
      const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
      'resolved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        clientId,
        entityType,
        entityId,
        entityDisplayName,
        entityPhone,
        amount,
        dueDate,
        message,
        isResolved,
        resolvedAt,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_name')) {
      context.handle(
          _entityDisplayNameMeta,
          entityDisplayName.isAcceptableOrUnknown(
              data['entity_name']!, _entityDisplayNameMeta));
    }
    if (data.containsKey('entity_phone')) {
      context.handle(
          _entityPhoneMeta,
          entityPhone.isAcceptableOrUnknown(
              data['entity_phone']!, _entityPhoneMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
          _isResolvedMeta,
          isResolved.isAcceptableOrUnknown(
              data['is_resolved']!, _isResolvedMeta));
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
          _resolvedAtMeta,
          resolvedAt.isAcceptableOrUnknown(
              data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      entityDisplayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_name']),
      entityPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_phone']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message']),
      isResolved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_resolved'])!,
      resolvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String? serverId;
  final String? clientId;
  final String entityType;
  final String entityId;
  final String? entityDisplayName;
  final String? entityPhone;
  final String amount;
  final DateTime? dueDate;
  final String? message;
  final bool isResolved;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String syncStatus;
  const Reminder(
      {required this.id,
      this.serverId,
      this.clientId,
      required this.entityType,
      required this.entityId,
      this.entityDisplayName,
      this.entityPhone,
      required this.amount,
      this.dueDate,
      this.message,
      required this.isResolved,
      this.resolvedAt,
      this.createdAt,
      this.updatedAt,
      required this.isSynced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || entityDisplayName != null) {
      map['entity_name'] = Variable<String>(entityDisplayName);
    }
    if (!nullToAbsent || entityPhone != null) {
      map['entity_phone'] = Variable<String>(entityPhone);
    }
    map['amount'] = Variable<String>(amount);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['is_resolved'] = Variable<bool>(isResolved);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      entityDisplayName: entityDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(entityDisplayName),
      entityPhone: entityPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(entityPhone),
      amount: Value(amount),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      isResolved: Value(isResolved),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      entityDisplayName:
          serializer.fromJson<String?>(json['entityDisplayName']),
      entityPhone: serializer.fromJson<String?>(json['entityPhone']),
      amount: serializer.fromJson<String>(json['amount']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      message: serializer.fromJson<String?>(json['message']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'clientId': serializer.toJson<String?>(clientId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'entityDisplayName': serializer.toJson<String?>(entityDisplayName),
      'entityPhone': serializer.toJson<String?>(entityPhone),
      'amount': serializer.toJson<String>(amount),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'message': serializer.toJson<String?>(message),
      'isResolved': serializer.toJson<bool>(isResolved),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Reminder copyWith(
          {int? id,
          Value<String?> serverId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? entityType,
          String? entityId,
          Value<String?> entityDisplayName = const Value.absent(),
          Value<String?> entityPhone = const Value.absent(),
          String? amount,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<String?> message = const Value.absent(),
          bool? isResolved,
          Value<DateTime?> resolvedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isSynced,
          String? syncStatus}) =>
      Reminder(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId.present ? clientId.value : this.clientId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        entityDisplayName: entityDisplayName.present
            ? entityDisplayName.value
            : this.entityDisplayName,
        entityPhone: entityPhone.present ? entityPhone.value : this.entityPhone,
        amount: amount ?? this.amount,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        message: message.present ? message.value : this.message,
        isResolved: isResolved ?? this.isResolved,
        resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityDisplayName: data.entityDisplayName.present
          ? data.entityDisplayName.value
          : this.entityDisplayName,
      entityPhone:
          data.entityPhone.present ? data.entityPhone.value : this.entityPhone,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      message: data.message.present ? data.message.value : this.message,
      isResolved:
          data.isResolved.present ? data.isResolved.value : this.isResolved,
      resolvedAt:
          data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('entityDisplayName: $entityDisplayName, ')
          ..write('entityPhone: $entityPhone, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('message: $message, ')
          ..write('isResolved: $isResolved, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      clientId,
      entityType,
      entityId,
      entityDisplayName,
      entityPhone,
      amount,
      dueDate,
      message,
      isResolved,
      resolvedAt,
      createdAt,
      updatedAt,
      isSynced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.entityDisplayName == this.entityDisplayName &&
          other.entityPhone == this.entityPhone &&
          other.amount == this.amount &&
          other.dueDate == this.dueDate &&
          other.message == this.message &&
          other.isResolved == this.isResolved &&
          other.resolvedAt == this.resolvedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncStatus == this.syncStatus);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String?> clientId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> entityDisplayName;
  final Value<String?> entityPhone;
  final Value<String> amount;
  final Value<DateTime?> dueDate;
  final Value<String?> message;
  final Value<bool> isResolved;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSynced;
  final Value<String> syncStatus;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityDisplayName = const Value.absent(),
    this.entityPhone = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.message = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String entityType,
    required String entityId,
    this.entityDisplayName = const Value.absent(),
    this.entityPhone = const Value.absent(),
    required String amount,
    this.dueDate = const Value.absent(),
    this.message = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncStatus = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        amount = Value(amount);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? clientId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? entityDisplayName,
    Expression<String>? entityPhone,
    Expression<String>? amount,
    Expression<DateTime>? dueDate,
    Expression<String>? message,
    Expression<bool>? isResolved,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (entityDisplayName != null) 'entity_name': entityDisplayName,
      if (entityPhone != null) 'entity_phone': entityPhone,
      if (amount != null) 'amount': amount,
      if (dueDate != null) 'due_date': dueDate,
      if (message != null) 'message': message,
      if (isResolved != null) 'is_resolved': isResolved,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<String?>? serverId,
      Value<String?>? clientId,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String?>? entityDisplayName,
      Value<String?>? entityPhone,
      Value<String>? amount,
      Value<DateTime?>? dueDate,
      Value<String?>? message,
      Value<bool>? isResolved,
      Value<DateTime?>? resolvedAt,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isSynced,
      Value<String>? syncStatus}) {
    return RemindersCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityDisplayName: entityDisplayName ?? this.entityDisplayName,
      entityPhone: entityPhone ?? this.entityPhone,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      message: message ?? this.message,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityDisplayName.present) {
      map['entity_name'] = Variable<String>(entityDisplayName.value);
    }
    if (entityPhone.present) {
      map['entity_phone'] = Variable<String>(entityPhone.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('entityDisplayName: $entityDisplayName, ')
          ..write('entityPhone: $entityPhone, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('message: $message, ')
          ..write('isResolved: $isResolved, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries =
      $SyncQueueEntriesTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $StockItemsTable stockItems = $StockItemsTable(this);
  late final $InventoryTransactionsTable inventoryTransactions =
      $InventoryTransactionsTable(this);
  late final $CustomerTransactionsTable customerTransactions =
      $CustomerTransactionsTable(this);
  late final $SupplierTransactionsTable supplierTransactions =
      $SupplierTransactionsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $CashTransactionsTable cashTransactions =
      $CashTransactionsTable(this);
  late final $BankAccountsTable bankAccounts = $BankAccountsTable(this);
  late final $BankTransactionsTable bankTransactions =
      $BankTransactionsTable(this);
  late final $StaffsTable staffs = $StaffsTable(this);
  late final $StaffSalariesTable staffSalaries = $StaffSalariesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        customers,
        suppliers,
        expenseCategories,
        syncQueueEntries,
        invoices,
        invoiceItems,
        stockItems,
        inventoryTransactions,
        customerTransactions,
        supplierTransactions,
        expenses,
        cashTransactions,
        bankAccounts,
        bankTransactions,
        staffs,
        staffSalaries,
        reminders
      ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<bool> isActive,
  Value<String?> balance,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<bool> isActive,
  Value<String?> balance,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> balance = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            phone: phone,
            email: email,
            address: address,
            isActive: isActive,
            balance: balance,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> balance = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            phone: phone,
            email: email,
            address: address,
            isActive: isActive,
            balance: balance,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()>;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<bool> isActive,
  Value<String?> balance,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<bool> isActive,
  Value<String?> balance,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$SuppliersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()> {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> balance = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              SuppliersCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            phone: phone,
            email: email,
            address: address,
            isActive: isActive,
            balance: balance,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> balance = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              SuppliersCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            phone: phone,
            email: email,
            address: address,
            isActive: isActive,
            balance: balance,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SuppliersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()>;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder
    = ExpenseCategoriesCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String name,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder
    = ExpenseCategoriesCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> name,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$ExpenseCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseCategoriesTable,
    ExpenseCategory,
    $$ExpenseCategoriesTableFilterComposer,
    $$ExpenseCategoriesTableOrderingComposer,
    $$ExpenseCategoriesTableAnnotationComposer,
    $$ExpenseCategoriesTableCreateCompanionBuilder,
    $$ExpenseCategoriesTableUpdateCompanionBuilder,
    (
      ExpenseCategory,
      BaseReferences<_$AppDatabase, $ExpenseCategoriesTable, ExpenseCategory>
    ),
    ExpenseCategory,
    PrefetchHooks Function()> {
  $$ExpenseCategoriesTableTableManager(
      _$AppDatabase db, $ExpenseCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              ExpenseCategoriesCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              ExpenseCategoriesCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpenseCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseCategoriesTable,
    ExpenseCategory,
    $$ExpenseCategoriesTableFilterComposer,
    $$ExpenseCategoriesTableOrderingComposer,
    $$ExpenseCategoriesTableAnnotationComposer,
    $$ExpenseCategoriesTableCreateCompanionBuilder,
    $$ExpenseCategoriesTableUpdateCompanionBuilder,
    (
      ExpenseCategory,
      BaseReferences<_$AppDatabase, $ExpenseCategoriesTable, ExpenseCategory>
    ),
    ExpenseCategory,
    PrefetchHooks Function()>;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder
    = SyncQueueEntriesCompanion Function({
  Value<int> id,
  required String entityType,
  Value<int?> entityLocalId,
  Value<String?> entityServerId,
  required String action,
  required String payload,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> nextAttemptAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<bool> isDeadLetter,
});
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder
    = SyncQueueEntriesCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<int?> entityLocalId,
  Value<String?> entityServerId,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> nextAttemptAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<bool> isDeadLetter,
});

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityServerId => $composableBuilder(
      column: $table.entityServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeadLetter => $composableBuilder(
      column: $table.isDeadLetter, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityServerId => $composableBuilder(
      column: $table.entityServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeadLetter => $composableBuilder(
      column: $table.isDeadLetter,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<int> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId, builder: (column) => column);

  GeneratedColumn<String> get entityServerId => $composableBuilder(
      column: $table.entityServerId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get isDeadLetter => $composableBuilder(
      column: $table.isDeadLetter, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueEntriesTable,
    SyncQueueEntry,
    $$SyncQueueEntriesTableFilterComposer,
    $$SyncQueueEntriesTableOrderingComposer,
    $$SyncQueueEntriesTableAnnotationComposer,
    $$SyncQueueEntriesTableCreateCompanionBuilder,
    $$SyncQueueEntriesTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()> {
  $$SyncQueueEntriesTableTableManager(
      _$AppDatabase db, $SyncQueueEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int?> entityLocalId = const Value.absent(),
            Value<String?> entityServerId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<bool> isDeadLetter = const Value.absent(),
          }) =>
              SyncQueueEntriesCompanion(
            id: id,
            entityType: entityType,
            entityLocalId: entityLocalId,
            entityServerId: entityServerId,
            action: action,
            payload: payload,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
            nextAttemptAt: nextAttemptAt,
            retryCount: retryCount,
            lastError: lastError,
            isDeadLetter: isDeadLetter,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            Value<int?> entityLocalId = const Value.absent(),
            Value<String?> entityServerId = const Value.absent(),
            required String action,
            required String payload,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<bool> isDeadLetter = const Value.absent(),
          }) =>
              SyncQueueEntriesCompanion.insert(
            id: id,
            entityType: entityType,
            entityLocalId: entityLocalId,
            entityServerId: entityServerId,
            action: action,
            payload: payload,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
            nextAttemptAt: nextAttemptAt,
            retryCount: retryCount,
            lastError: lastError,
            isDeadLetter: isDeadLetter,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueEntriesTable,
    SyncQueueEntry,
    $$SyncQueueEntriesTableFilterComposer,
    $$SyncQueueEntriesTableOrderingComposer,
    $$SyncQueueEntriesTableAnnotationComposer,
    $$SyncQueueEntriesTableCreateCompanionBuilder,
    $$SyncQueueEntriesTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  Value<int> id,
  required String serverId,
  required String invoiceNumber,
  Value<String?> customerId,
  required String invoiceType,
  required DateTime date,
  required String subtotal,
  required String taxAmount,
  required String discountAmount,
  required String totalAmount,
  required String paidAmount,
  Value<String?> remarks,
  Value<String?> pdfPath,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<int> id,
  Value<String> serverId,
  Value<String> invoiceNumber,
  Value<String?> customerId,
  Value<String> invoiceType,
  Value<DateTime> date,
  Value<String> subtotal,
  Value<String> taxAmount,
  Value<String> discountAmount,
  Value<String> totalAmount,
  Value<String> paidAmount,
  Value<String?> remarks,
  Value<String?> pdfPath,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceType => $composableBuilder(
      column: $table.invoiceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceType => $composableBuilder(
      column: $table.invoiceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get invoiceType => $composableBuilder(
      column: $table.invoiceType, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<String> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<String> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverId = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String> invoiceType = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> subtotal = const Value.absent(),
            Value<String> taxAmount = const Value.absent(),
            Value<String> discountAmount = const Value.absent(),
            Value<String> totalAmount = const Value.absent(),
            Value<String> paidAmount = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String?> pdfPath = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            serverId: serverId,
            invoiceNumber: invoiceNumber,
            customerId: customerId,
            invoiceType: invoiceType,
            date: date,
            subtotal: subtotal,
            taxAmount: taxAmount,
            discountAmount: discountAmount,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            remarks: remarks,
            pdfPath: pdfPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverId,
            required String invoiceNumber,
            Value<String?> customerId = const Value.absent(),
            required String invoiceType,
            required DateTime date,
            required String subtotal,
            required String taxAmount,
            required String discountAmount,
            required String totalAmount,
            required String paidAmount,
            Value<String?> remarks = const Value.absent(),
            Value<String?> pdfPath = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            serverId: serverId,
            invoiceNumber: invoiceNumber,
            customerId: customerId,
            invoiceType: invoiceType,
            date: date,
            subtotal: subtotal,
            taxAmount: taxAmount,
            discountAmount: discountAmount,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            remarks: remarks,
            pdfPath: pdfPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  Value<String?> serverId,
  required String invoiceServerId,
  Value<String?> itemId,
  required String itemName,
  required String quantity,
  required String unitPrice,
  required String totalPrice,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String> invoiceServerId,
  Value<String?> itemId,
  Value<String> itemName,
  Value<String> quantity,
  Value<String> unitPrice,
  Value<String> totalPrice,
});

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceServerId => $composableBuilder(
      column: $table.invoiceServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceServerId => $composableBuilder(
      column: $table.invoiceServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get invoiceServerId => $composableBuilder(
      column: $table.invoiceServerId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> invoiceServerId = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<String> quantity = const Value.absent(),
            Value<String> unitPrice = const Value.absent(),
            Value<String> totalPrice = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            serverId: serverId,
            invoiceServerId: invoiceServerId,
            itemId: itemId,
            itemName: itemName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            required String invoiceServerId,
            Value<String?> itemId = const Value.absent(),
            required String itemName,
            required String quantity,
            required String unitPrice,
            required String totalPrice,
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            serverId: serverId,
            invoiceServerId: invoiceServerId,
            itemId: itemId,
            itemName: itemName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()>;
typedef $$StockItemsTableCreateCompanionBuilder = StockItemsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String name,
  required String purchasePrice,
  required String salePrice,
  required String unit,
  required String currentStock,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$StockItemsTableUpdateCompanionBuilder = StockItemsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> name,
  Value<String> purchasePrice,
  Value<String> salePrice,
  Value<String> unit,
  Value<String> currentStock,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$StockItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$StockItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentStock => $composableBuilder(
      column: $table.currentStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$StockItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<String> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$StockItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockItemsTable,
    StockItem,
    $$StockItemsTableFilterComposer,
    $$StockItemsTableOrderingComposer,
    $$StockItemsTableAnnotationComposer,
    $$StockItemsTableCreateCompanionBuilder,
    $$StockItemsTableUpdateCompanionBuilder,
    (StockItem, BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>),
    StockItem,
    PrefetchHooks Function()> {
  $$StockItemsTableTableManager(_$AppDatabase db, $StockItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> purchasePrice = const Value.absent(),
            Value<String> salePrice = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String> currentStock = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              StockItemsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            unit: unit,
            currentStock: currentStock,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String name,
            required String purchasePrice,
            required String salePrice,
            required String unit,
            required String currentStock,
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              StockItemsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            unit: unit,
            currentStock: currentStock,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockItemsTable,
    StockItem,
    $$StockItemsTableFilterComposer,
    $$StockItemsTableOrderingComposer,
    $$StockItemsTableAnnotationComposer,
    $$StockItemsTableCreateCompanionBuilder,
    $$StockItemsTableUpdateCompanionBuilder,
    (StockItem, BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>),
    StockItem,
    PrefetchHooks Function()>;
typedef $$InventoryTransactionsTableCreateCompanionBuilder
    = InventoryTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String itemId,
  required String transactionType,
  required String quantity,
  Value<String?> unitPrice,
  required DateTime date,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$InventoryTransactionsTableUpdateCompanionBuilder
    = InventoryTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> itemId,
  Value<String> transactionType,
  Value<String> quantity,
  Value<String?> unitPrice,
  Value<DateTime> date,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$InventoryTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$InventoryTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$InventoryTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$InventoryTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryTransactionsTable,
    InventoryTransaction,
    $$InventoryTransactionsTableFilterComposer,
    $$InventoryTransactionsTableOrderingComposer,
    $$InventoryTransactionsTableAnnotationComposer,
    $$InventoryTransactionsTableCreateCompanionBuilder,
    $$InventoryTransactionsTableUpdateCompanionBuilder,
    (
      InventoryTransaction,
      BaseReferences<_$AppDatabase, $InventoryTransactionsTable,
          InventoryTransaction>
    ),
    InventoryTransaction,
    PrefetchHooks Function()> {
  $$InventoryTransactionsTableTableManager(
      _$AppDatabase db, $InventoryTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> quantity = const Value.absent(),
            Value<String?> unitPrice = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              InventoryTransactionsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            itemId: itemId,
            transactionType: transactionType,
            quantity: quantity,
            unitPrice: unitPrice,
            date: date,
            referenceId: referenceId,
            referenceType: referenceType,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String itemId,
            required String transactionType,
            required String quantity,
            Value<String?> unitPrice = const Value.absent(),
            required DateTime date,
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              InventoryTransactionsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            itemId: itemId,
            transactionType: transactionType,
            quantity: quantity,
            unitPrice: unitPrice,
            date: date,
            referenceId: referenceId,
            referenceType: referenceType,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventoryTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InventoryTransactionsTable,
        InventoryTransaction,
        $$InventoryTransactionsTableFilterComposer,
        $$InventoryTransactionsTableOrderingComposer,
        $$InventoryTransactionsTableAnnotationComposer,
        $$InventoryTransactionsTableCreateCompanionBuilder,
        $$InventoryTransactionsTableUpdateCompanionBuilder,
        (
          InventoryTransaction,
          BaseReferences<_$AppDatabase, $InventoryTransactionsTable,
              InventoryTransaction>
        ),
        InventoryTransaction,
        PrefetchHooks Function()>;
typedef $$CustomerTransactionsTableCreateCompanionBuilder
    = CustomerTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String customerId,
  required String transactionType,
  required String amount,
  required DateTime date,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$CustomerTransactionsTableUpdateCompanionBuilder
    = CustomerTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> customerId,
  Value<String> transactionType,
  Value<String> amount,
  Value<DateTime> date,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$CustomerTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerTransactionsTable> {
  $$CustomerTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$CustomerTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerTransactionsTable> {
  $$CustomerTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$CustomerTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerTransactionsTable> {
  $$CustomerTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$CustomerTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomerTransactionsTable,
    CustomerTransaction,
    $$CustomerTransactionsTableFilterComposer,
    $$CustomerTransactionsTableOrderingComposer,
    $$CustomerTransactionsTableAnnotationComposer,
    $$CustomerTransactionsTableCreateCompanionBuilder,
    $$CustomerTransactionsTableUpdateCompanionBuilder,
    (
      CustomerTransaction,
      BaseReferences<_$AppDatabase, $CustomerTransactionsTable,
          CustomerTransaction>
    ),
    CustomerTransaction,
    PrefetchHooks Function()> {
  $$CustomerTransactionsTableTableManager(
      _$AppDatabase db, $CustomerTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              CustomerTransactionsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            customerId: customerId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            referenceId: referenceId,
            referenceType: referenceType,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String customerId,
            required String transactionType,
            required String amount,
            required DateTime date,
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              CustomerTransactionsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            customerId: customerId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            referenceId: referenceId,
            referenceType: referenceType,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomerTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CustomerTransactionsTable,
        CustomerTransaction,
        $$CustomerTransactionsTableFilterComposer,
        $$CustomerTransactionsTableOrderingComposer,
        $$CustomerTransactionsTableAnnotationComposer,
        $$CustomerTransactionsTableCreateCompanionBuilder,
        $$CustomerTransactionsTableUpdateCompanionBuilder,
        (
          CustomerTransaction,
          BaseReferences<_$AppDatabase, $CustomerTransactionsTable,
              CustomerTransaction>
        ),
        CustomerTransaction,
        PrefetchHooks Function()>;
typedef $$SupplierTransactionsTableCreateCompanionBuilder
    = SupplierTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String supplierId,
  required String transactionType,
  required String amount,
  required DateTime date,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$SupplierTransactionsTableUpdateCompanionBuilder
    = SupplierTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> supplierId,
  Value<String> transactionType,
  Value<String> amount,
  Value<DateTime> date,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$SupplierTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierTransactionsTable> {
  $$SupplierTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$SupplierTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierTransactionsTable> {
  $$SupplierTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$SupplierTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierTransactionsTable> {
  $$SupplierTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$SupplierTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplierTransactionsTable,
    SupplierTransaction,
    $$SupplierTransactionsTableFilterComposer,
    $$SupplierTransactionsTableOrderingComposer,
    $$SupplierTransactionsTableAnnotationComposer,
    $$SupplierTransactionsTableCreateCompanionBuilder,
    $$SupplierTransactionsTableUpdateCompanionBuilder,
    (
      SupplierTransaction,
      BaseReferences<_$AppDatabase, $SupplierTransactionsTable,
          SupplierTransaction>
    ),
    SupplierTransaction,
    PrefetchHooks Function()> {
  $$SupplierTransactionsTableTableManager(
      _$AppDatabase db, $SupplierTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> supplierId = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              SupplierTransactionsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            supplierId: supplierId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            referenceId: referenceId,
            referenceType: referenceType,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String supplierId,
            required String transactionType,
            required String amount,
            required DateTime date,
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              SupplierTransactionsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            supplierId: supplierId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            referenceId: referenceId,
            referenceType: referenceType,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SupplierTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SupplierTransactionsTable,
        SupplierTransaction,
        $$SupplierTransactionsTableFilterComposer,
        $$SupplierTransactionsTableOrderingComposer,
        $$SupplierTransactionsTableAnnotationComposer,
        $$SupplierTransactionsTableCreateCompanionBuilder,
        $$SupplierTransactionsTableUpdateCompanionBuilder,
        (
          SupplierTransaction,
          BaseReferences<_$AppDatabase, $SupplierTransactionsTable,
              SupplierTransaction>
        ),
        SupplierTransaction,
        PrefetchHooks Function()>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String categoryId,
  required String amount,
  required DateTime date,
  required String paymentMode,
  Value<String?> description,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> categoryId,
  Value<String> amount,
  Value<DateTime> date,
  Value<String> paymentMode,
  Value<String?> description,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> paymentMode = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            categoryId: categoryId,
            amount: amount,
            date: date,
            paymentMode: paymentMode,
            description: description,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String categoryId,
            required String amount,
            required DateTime date,
            required String paymentMode,
            Value<String?> description = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            categoryId: categoryId,
            amount: amount,
            date: date,
            paymentMode: paymentMode,
            description: description,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
    Expense,
    PrefetchHooks Function()>;
typedef $$CashTransactionsTableCreateCompanionBuilder
    = CashTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String transactionType,
  required String amount,
  required DateTime date,
  Value<String?> source,
  Value<String?> remarks,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$CashTransactionsTableUpdateCompanionBuilder
    = CashTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> transactionType,
  Value<String> amount,
  Value<DateTime> date,
  Value<String?> source,
  Value<String?> remarks,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$CashTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CashTransactionsTable> {
  $$CashTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$CashTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashTransactionsTable> {
  $$CashTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$CashTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashTransactionsTable> {
  $$CashTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$CashTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashTransactionsTable,
    CashTransaction,
    $$CashTransactionsTableFilterComposer,
    $$CashTransactionsTableOrderingComposer,
    $$CashTransactionsTableAnnotationComposer,
    $$CashTransactionsTableCreateCompanionBuilder,
    $$CashTransactionsTableUpdateCompanionBuilder,
    (
      CashTransaction,
      BaseReferences<_$AppDatabase, $CashTransactionsTable, CashTransaction>
    ),
    CashTransaction,
    PrefetchHooks Function()> {
  $$CashTransactionsTableTableManager(
      _$AppDatabase db, $CashTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              CashTransactionsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            source: source,
            remarks: remarks,
            referenceId: referenceId,
            referenceType: referenceType,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String transactionType,
            required String amount,
            required DateTime date,
            Value<String?> source = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              CashTransactionsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            source: source,
            remarks: remarks,
            referenceId: referenceId,
            referenceType: referenceType,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CashTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashTransactionsTable,
    CashTransaction,
    $$CashTransactionsTableFilterComposer,
    $$CashTransactionsTableOrderingComposer,
    $$CashTransactionsTableAnnotationComposer,
    $$CashTransactionsTableCreateCompanionBuilder,
    $$CashTransactionsTableUpdateCompanionBuilder,
    (
      CashTransaction,
      BaseReferences<_$AppDatabase, $CashTransactionsTable, CashTransaction>
    ),
    CashTransaction,
    PrefetchHooks Function()>;
typedef $$BankAccountsTableCreateCompanionBuilder = BankAccountsCompanion
    Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String bankName,
  required String accountNumber,
  Value<String?> accountHolderName,
  Value<String?> branch,
  Value<String?> ifscCode,
  Value<String?> accountType,
  required String openingBalance,
  required String currentBalance,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$BankAccountsTableUpdateCompanionBuilder = BankAccountsCompanion
    Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> bankName,
  Value<String> accountNumber,
  Value<String?> accountHolderName,
  Value<String?> branch,
  Value<String?> ifscCode,
  Value<String?> accountType,
  Value<String> openingBalance,
  Value<String> currentBalance,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$BankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountHolderName => $composableBuilder(
      column: $table.accountHolderName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$BankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountHolderName => $composableBuilder(
      column: $table.accountHolderName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$BankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get accountHolderName => $composableBuilder(
      column: $table.accountHolderName, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<String> get ifscCode =>
      $composableBuilder(column: $table.ifscCode, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => column);

  GeneratedColumn<String> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<String> get currentBalance => $composableBuilder(
      column: $table.currentBalance, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$BankAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BankAccountsTable,
    BankAccount,
    $$BankAccountsTableFilterComposer,
    $$BankAccountsTableOrderingComposer,
    $$BankAccountsTableAnnotationComposer,
    $$BankAccountsTableCreateCompanionBuilder,
    $$BankAccountsTableUpdateCompanionBuilder,
    (
      BankAccount,
      BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>
    ),
    BankAccount,
    PrefetchHooks Function()> {
  $$BankAccountsTableTableManager(_$AppDatabase db, $BankAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> bankName = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<String?> accountHolderName = const Value.absent(),
            Value<String?> branch = const Value.absent(),
            Value<String?> ifscCode = const Value.absent(),
            Value<String?> accountType = const Value.absent(),
            Value<String> openingBalance = const Value.absent(),
            Value<String> currentBalance = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              BankAccountsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            bankName: bankName,
            accountNumber: accountNumber,
            accountHolderName: accountHolderName,
            branch: branch,
            ifscCode: ifscCode,
            accountType: accountType,
            openingBalance: openingBalance,
            currentBalance: currentBalance,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String bankName,
            required String accountNumber,
            Value<String?> accountHolderName = const Value.absent(),
            Value<String?> branch = const Value.absent(),
            Value<String?> ifscCode = const Value.absent(),
            Value<String?> accountType = const Value.absent(),
            required String openingBalance,
            required String currentBalance,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              BankAccountsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            bankName: bankName,
            accountNumber: accountNumber,
            accountHolderName: accountHolderName,
            branch: branch,
            ifscCode: ifscCode,
            accountType: accountType,
            openingBalance: openingBalance,
            currentBalance: currentBalance,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BankAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BankAccountsTable,
    BankAccount,
    $$BankAccountsTableFilterComposer,
    $$BankAccountsTableOrderingComposer,
    $$BankAccountsTableAnnotationComposer,
    $$BankAccountsTableCreateCompanionBuilder,
    $$BankAccountsTableUpdateCompanionBuilder,
    (
      BankAccount,
      BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>
    ),
    BankAccount,
    PrefetchHooks Function()>;
typedef $$BankTransactionsTableCreateCompanionBuilder
    = BankTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String accountId,
  required String transactionType,
  required String amount,
  required DateTime date,
  Value<String?> referenceNumber,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$BankTransactionsTableUpdateCompanionBuilder
    = BankTransactionsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> accountId,
  Value<String> transactionType,
  Value<String> amount,
  Value<DateTime> date,
  Value<String?> referenceNumber,
  Value<String?> remarks,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$BankTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $BankTransactionsTable> {
  $$BankTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$BankTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankTransactionsTable> {
  $$BankTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$BankTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankTransactionsTable> {
  $$BankTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$BankTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BankTransactionsTable,
    BankTransaction,
    $$BankTransactionsTableFilterComposer,
    $$BankTransactionsTableOrderingComposer,
    $$BankTransactionsTableAnnotationComposer,
    $$BankTransactionsTableCreateCompanionBuilder,
    $$BankTransactionsTableUpdateCompanionBuilder,
    (
      BankTransaction,
      BaseReferences<_$AppDatabase, $BankTransactionsTable, BankTransaction>
    ),
    BankTransaction,
    PrefetchHooks Function()> {
  $$BankTransactionsTableTableManager(
      _$AppDatabase db, $BankTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> referenceNumber = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              BankTransactionsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            accountId: accountId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            referenceNumber: referenceNumber,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String accountId,
            required String transactionType,
            required String amount,
            required DateTime date,
            Value<String?> referenceNumber = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              BankTransactionsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            accountId: accountId,
            transactionType: transactionType,
            amount: amount,
            date: date,
            referenceNumber: referenceNumber,
            remarks: remarks,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BankTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BankTransactionsTable,
    BankTransaction,
    $$BankTransactionsTableFilterComposer,
    $$BankTransactionsTableOrderingComposer,
    $$BankTransactionsTableAnnotationComposer,
    $$BankTransactionsTableCreateCompanionBuilder,
    $$BankTransactionsTableUpdateCompanionBuilder,
    (
      BankTransaction,
      BaseReferences<_$AppDatabase, $BankTransactionsTable, BankTransaction>
    ),
    BankTransaction,
    PrefetchHooks Function()>;
typedef $$StaffsTableCreateCompanionBuilder = StaffsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> role,
  Value<String?> address,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$StaffsTableUpdateCompanionBuilder = StaffsCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> role,
  Value<String?> address,
  Value<bool> isActive,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$StaffsTableFilterComposer
    extends Composer<_$AppDatabase, $StaffsTable> {
  $$StaffsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$StaffsTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffsTable> {
  $$StaffsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$StaffsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffsTable> {
  $$StaffsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$StaffsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffsTable,
    Staff,
    $$StaffsTableFilterComposer,
    $$StaffsTableOrderingComposer,
    $$StaffsTableAnnotationComposer,
    $$StaffsTableCreateCompanionBuilder,
    $$StaffsTableUpdateCompanionBuilder,
    (Staff, BaseReferences<_$AppDatabase, $StaffsTable, Staff>),
    Staff,
    PrefetchHooks Function()> {
  $$StaffsTableTableManager(_$AppDatabase db, $StaffsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              StaffsCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            phone: phone,
            email: email,
            role: role,
            address: address,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              StaffsCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            name: name,
            phone: phone,
            email: email,
            role: role,
            address: address,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StaffsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffsTable,
    Staff,
    $$StaffsTableFilterComposer,
    $$StaffsTableOrderingComposer,
    $$StaffsTableAnnotationComposer,
    $$StaffsTableCreateCompanionBuilder,
    $$StaffsTableUpdateCompanionBuilder,
    (Staff, BaseReferences<_$AppDatabase, $StaffsTable, Staff>),
    Staff,
    PrefetchHooks Function()>;
typedef $$StaffSalariesTableCreateCompanionBuilder = StaffSalariesCompanion
    Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String staffId,
  required String amount,
  required DateTime date,
  Value<String?> paymentMode,
  Value<String?> remarks,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$StaffSalariesTableUpdateCompanionBuilder = StaffSalariesCompanion
    Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> staffId,
  Value<String> amount,
  Value<DateTime> date,
  Value<String?> paymentMode,
  Value<String?> remarks,
  Value<String?> referenceId,
  Value<String?> referenceType,
  Value<DateTime?> createdAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$StaffSalariesTableFilterComposer
    extends Composer<_$AppDatabase, $StaffSalariesTable> {
  $$StaffSalariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get staffId => $composableBuilder(
      column: $table.staffId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$StaffSalariesTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffSalariesTable> {
  $$StaffSalariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get staffId => $composableBuilder(
      column: $table.staffId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$StaffSalariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffSalariesTable> {
  $$StaffSalariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$StaffSalariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffSalariesTable,
    StaffSalary,
    $$StaffSalariesTableFilterComposer,
    $$StaffSalariesTableOrderingComposer,
    $$StaffSalariesTableAnnotationComposer,
    $$StaffSalariesTableCreateCompanionBuilder,
    $$StaffSalariesTableUpdateCompanionBuilder,
    (
      StaffSalary,
      BaseReferences<_$AppDatabase, $StaffSalariesTable, StaffSalary>
    ),
    StaffSalary,
    PrefetchHooks Function()> {
  $$StaffSalariesTableTableManager(_$AppDatabase db, $StaffSalariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffSalariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffSalariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffSalariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> staffId = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> paymentMode = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              StaffSalariesCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            staffId: staffId,
            amount: amount,
            date: date,
            paymentMode: paymentMode,
            remarks: remarks,
            referenceId: referenceId,
            referenceType: referenceType,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String staffId,
            required String amount,
            required DateTime date,
            Value<String?> paymentMode = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> referenceType = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              StaffSalariesCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            staffId: staffId,
            amount: amount,
            date: date,
            paymentMode: paymentMode,
            remarks: remarks,
            referenceId: referenceId,
            referenceType: referenceType,
            createdAt: createdAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StaffSalariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffSalariesTable,
    StaffSalary,
    $$StaffSalariesTableFilterComposer,
    $$StaffSalariesTableOrderingComposer,
    $$StaffSalariesTableAnnotationComposer,
    $$StaffSalariesTableCreateCompanionBuilder,
    $$StaffSalariesTableUpdateCompanionBuilder,
    (
      StaffSalary,
      BaseReferences<_$AppDatabase, $StaffSalariesTable, StaffSalary>
    ),
    StaffSalary,
    PrefetchHooks Function()>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  required String entityType,
  required String entityId,
  Value<String?> entityDisplayName,
  Value<String?> entityPhone,
  required String amount,
  Value<DateTime?> dueDate,
  Value<String?> message,
  Value<bool> isResolved,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String?> serverId,
  Value<String?> clientId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String?> entityDisplayName,
  Value<String?> entityPhone,
  Value<String> amount,
  Value<DateTime?> dueDate,
  Value<String?> message,
  Value<bool> isResolved,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isSynced,
  Value<String> syncStatus,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityDisplayName => $composableBuilder(
      column: $table.entityDisplayName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityPhone => $composableBuilder(
      column: $table.entityPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityDisplayName => $composableBuilder(
      column: $table.entityDisplayName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityPhone => $composableBuilder(
      column: $table.entityPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityDisplayName => $composableBuilder(
      column: $table.entityDisplayName, builder: (column) => column);

  GeneratedColumn<String> get entityPhone => $composableBuilder(
      column: $table.entityPhone, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String?> entityDisplayName = const Value.absent(),
            Value<String?> entityPhone = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            serverId: serverId,
            clientId: clientId,
            entityType: entityType,
            entityId: entityId,
            entityDisplayName: entityDisplayName,
            entityPhone: entityPhone,
            amount: amount,
            dueDate: dueDate,
            message: message,
            isResolved: isResolved,
            resolvedAt: resolvedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String entityType,
            required String entityId,
            Value<String?> entityDisplayName = const Value.absent(),
            Value<String?> entityPhone = const Value.absent(),
            required String amount,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            serverId: serverId,
            clientId: clientId,
            entityType: entityType,
            entityId: entityId,
            entityDisplayName: entityDisplayName,
            entityPhone: entityPhone,
            amount: amount,
            dueDate: dueDate,
            message: message,
            isResolved: isResolved,
            resolvedAt: resolvedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncStatus: syncStatus,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$StockItemsTableTableManager get stockItems =>
      $$StockItemsTableTableManager(_db, _db.stockItems);
  $$InventoryTransactionsTableTableManager get inventoryTransactions =>
      $$InventoryTransactionsTableTableManager(_db, _db.inventoryTransactions);
  $$CustomerTransactionsTableTableManager get customerTransactions =>
      $$CustomerTransactionsTableTableManager(_db, _db.customerTransactions);
  $$SupplierTransactionsTableTableManager get supplierTransactions =>
      $$SupplierTransactionsTableTableManager(_db, _db.supplierTransactions);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$CashTransactionsTableTableManager get cashTransactions =>
      $$CashTransactionsTableTableManager(_db, _db.cashTransactions);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db, _db.bankAccounts);
  $$BankTransactionsTableTableManager get bankTransactions =>
      $$BankTransactionsTableTableManager(_db, _db.bankTransactions);
  $$StaffsTableTableManager get staffs =>
      $$StaffsTableTableManager(_db, _db.staffs);
  $$StaffSalariesTableTableManager get staffSalaries =>
      $$StaffSalariesTableTableManager(_db, _db.staffSalaries);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
