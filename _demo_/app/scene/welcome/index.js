/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { View, Text, Linking } from 'react-native';

import styled from 'styled-components/native';

const Wrapper = styled.View`
  flex: 1;
  padding: 24px;
  justify-content: center;
`;

const Header = styled.Text`
  font-size: 18px;
  margin-bottom: 18px;
`;

const Content = styled.Text`
  font-size: 12px;
  margin-bottom: 10px;
  line-height: 18px;
`;

export default class Welcome extends Component {

  showApp(event) {
    event.preventDefault();
    if (this.props.showApp) this.props.showApp();
  }

  render() {
    function Link(props) {
      return (
        <Text style={{ color: 'blue' }} onPress={() => Linking.openURL(props.url)}>
          {props.children}
        </Text >
      );
    };

    return (
      <Wrapper>
        <Header>React-Native-Scandit Demo</Header>
        <Content>
          This demo app illustrates Scandit barcode scanning in React Native for iOS and Android.
        </Content>
        <Content>
          It uses <Link url="https://github.com/shoplinksys/react-native-scandit">react-native-scandit</Link> for
          bridging the native ScanditSDKs and <Link
            url="https://github.com/storybooks/storybook/blob/master/app/react-native/readme.md">Storybook for React
          Native</Link> for simple UI exploration and development.
        </Content>
        <Content>
          Please keep in mind that the Scandit SDK itself (<Link url="https://www.scandit.com/">scandit.com</Link>)
          is propatary. However, the React Native code here is free (MIT licence) and maintained
          by Shoplink (<Link url="https://shop.link/">shop.link</Link>). PS: We are hiring!
        </Content>
      </Wrapper>
    );
  }
}

Welcome.defaultProps = {
  showApp: null,
};

Welcome.propTypes = {
  showApp: PropTypes.func,
};
