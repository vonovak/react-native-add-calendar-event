import { transformConfigColors } from '../index';

describe('processColorsIOS', () => {
  it('does not modify the passed object', () => {
    const original = {
      title: 'lunch',
      navigationBarIOS: {
        tintColor: 'red',
        barTintColor: '#0000ff',
        translucent: true,
      },
    };
    const transformed = transformConfigColors(original);
    const transformedNavigationBarIOS = transformed.navigationBarIOS;
    const origNavigationBarIOS = original.navigationBarIOS;

    expect(transformed).not.toBe(original);
    expect(transformedNavigationBarIOS).not.toBe(origNavigationBarIOS);
    expect(origNavigationBarIOS.tintColor).toBe('red');
    expect(origNavigationBarIOS.barTintColor).toBe('#0000ff');
    expect(origNavigationBarIOS.translucent).toBe(true);
  });

  it('transforms only colors', () => {
    const original = {
      title: 'lunch',
      navigationBarIOS: {
        tintColor: 'red',
        barTintColor: '#0000ff',
        translucent: true,
      },
    };
    const transformed = transformConfigColors(original);
    const transformedNavigationBarIOS = transformed.navigationBarIOS;

    expect(transformedNavigationBarIOS.tintColor).toBe(4294901760);
    expect(transformedNavigationBarIOS.barTintColor).toBe(4278190335);
    expect(transformedNavigationBarIOS.translucent).toBe(true);
  });
});
