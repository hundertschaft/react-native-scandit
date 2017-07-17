/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React, { PropTypes } from 'react';
import { View, Text, Linking } from 'react-native';

export default class Welcome extends React.Component {
  styles = {
    wrapper: {
      flex: 1,
      padding: 24,
      justifyContent: 'center',
    },
    header: {
      fontSize: 18,
      marginBottom: 18,
    },
    content: {
      fontSize: 12,
      marginBottom: 10,
      lineHeight: 18,
    },
  };

  showApp(event) {
    event.preventDefault();
    if (this.props.showApp) this.props.showApp();
  }

  render() {
    return (
      <View style={this.styles.wrapper}>
        <Text style={this.styles.header}>React-Native-Scandit Demo</Text>
        <Text style={this.styles.content}>
          This demo app illustrates Scandit barcode scanning in React Native for iOS and Android.
          </Text>
        <Text style={this.styles.content}>
          It uses <Text style={{
            color: 'blue'
          }} onPress={() => Linking.openURL('https://github.com/shoplinksys/react-native-scandit')}>
            react-native-scandit</Text> for bridging the native ScanditSDKs and <Text style={{
              color: 'blue'
            }} onPress={() => Linking.openURL('https://github.com/storybooks/storybook/blob/master/app/react-native/readme.md')}>
            Storybook for React Native</Text> for simple UI exploration and development.
        </Text>
        <Text style={this.styles.content}>
          Please keep in mind that the Scandit SDK itself (<Text style={{
            color: 'blue'
          }} onPress={() => Linking.openURL('https://www.scandit.com/')}>
            scandit.com</Text>) is propatary. However, the React Native code here is free (MIT licence) and maintained
            by Shoplink (<Text style={{
            color: 'blue'
          }} onPress={() => Linking.openURL('https://shop.link/')}>
            shop.link</Text>). We are hiring!
        </Text>
      </View>
    );
  }
}

Welcome.defaultProps = {
  showApp: null,
};

Welcome.propTypes = {
  showApp: PropTypes.func,
};
