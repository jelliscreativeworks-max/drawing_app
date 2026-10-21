import 'dart:ui';


abstract class PropertyId<T> {
  String get displayName;
  const PropertyId();}

//Stroke Ids -------------
class StrokeSizeId extends PropertyId<double>{ 
  const StrokeSizeId();
  @override String get displayName => 'Stroke Size';
}
class StrokeColorId extends PropertyId<Color>{
  const StrokeColorId();
  @override String get displayName => 'Stroke Color';
}

//Fill Ids -----------------
class FillColorId extends PropertyId<Color>{const FillColorId();
  @override String get displayName => 'Fill Color';
}

class FillTypeId extends ChoiceTypeId{
  const FillTypeId();
  @override String get displayName => 'Fill Type';
}

abstract class ChoiceTypeId<T extends Enum> extends PropertyId{
  const ChoiceTypeId();
}
