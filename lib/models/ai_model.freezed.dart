// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIModel _$AIModelFromJson(Map<String, dynamic> json) {
  return _AIModel.fromJson(json);
}

/// @nodoc
mixin _$AIModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  int get maxTokens => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  double get topP => throw _privateConstructorUsedError;
  int get topK => throw _privateConstructorUsedError;

  /// Serializes this AIModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIModelCopyWith<AIModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIModelCopyWith<$Res> {
  factory $AIModelCopyWith(AIModel value, $Res Function(AIModel) then) =
      _$AIModelCopyWithImpl<$Res, AIModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String provider,
      int maxTokens,
      double temperature,
      double topP,
      int topK});
}

/// @nodoc
class _$AIModelCopyWithImpl<$Res, $Val extends AIModel>
    implements $AIModelCopyWith<$Res> {
  _$AIModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? provider = null,
    Object? maxTokens = null,
    Object? temperature = null,
    Object? topP = null,
    Object? topK = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      topK: null == topK
          ? _value.topK
          : topK // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIModelImplCopyWith<$Res> implements $AIModelCopyWith<$Res> {
  factory _$$AIModelImplCopyWith(
          _$AIModelImpl value, $Res Function(_$AIModelImpl) then) =
      __$$AIModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String provider,
      int maxTokens,
      double temperature,
      double topP,
      int topK});
}

/// @nodoc
class __$$AIModelImplCopyWithImpl<$Res>
    extends _$AIModelCopyWithImpl<$Res, _$AIModelImpl>
    implements _$$AIModelImplCopyWith<$Res> {
  __$$AIModelImplCopyWithImpl(
      _$AIModelImpl _value, $Res Function(_$AIModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? provider = null,
    Object? maxTokens = null,
    Object? temperature = null,
    Object? topP = null,
    Object? topK = null,
  }) {
    return _then(_$AIModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      topK: null == topK
          ? _value.topK
          : topK // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIModelImpl implements _AIModel {
  const _$AIModelImpl(
      {required this.id,
      required this.name,
      required this.provider,
      this.maxTokens = 0,
      this.temperature = 0.7,
      this.topP = 1.0,
      this.topK = 0});

  factory _$AIModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String provider;
  @override
  @JsonKey()
  final int maxTokens;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final double topP;
  @override
  @JsonKey()
  final int topK;

  @override
  String toString() {
    return 'AIModel(id: $id, name: $name, provider: $provider, maxTokens: $maxTokens, temperature: $temperature, topP: $topP, topK: $topK)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.topP, topP) || other.topP == topP) &&
            (identical(other.topK, topK) || other.topK == topK));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, provider, maxTokens, temperature, topP, topK);

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIModelImplCopyWith<_$AIModelImpl> get copyWith =>
      __$$AIModelImplCopyWithImpl<_$AIModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIModelImplToJson(
      this,
    );
  }
}

abstract class _AIModel implements AIModel {
  const factory _AIModel(
      {required final String id,
      required final String name,
      required final String provider,
      final int maxTokens,
      final double temperature,
      final double topP,
      final int topK}) = _$AIModelImpl;

  factory _AIModel.fromJson(Map<String, dynamic> json) = _$AIModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get provider;
  @override
  int get maxTokens;
  @override
  double get temperature;
  @override
  double get topP;
  @override
  int get topK;

  /// Create a copy of AIModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIModelImplCopyWith<_$AIModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
