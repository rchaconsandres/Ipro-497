import { SymbolView, type SymbolViewProps } from 'expo-symbols';
import { type ColorValue } from 'react-native';

type PlatformNames = Exclude<SymbolViewProps['name'], string>;

type IconProps = {
  /** SF Symbol name, used on iPhone. Browse them in Apple's SF Symbols app. */
  ios: NonNullable<PlatformNames['ios']>;
  /** Material Symbols name, used on Android and web. See fonts.google.com/icons. */
  md: NonNullable<PlatformNames['android']>;
  color: ColorValue;
  size?: number;
};

export function Icon({ ios, md, color, size = 24 }: IconProps) {
  return <SymbolView name={{ ios, android: md, web: md }} tintColor={color} size={size} />;
}
