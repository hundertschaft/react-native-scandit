/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React, { PropTypes } from 'react';
import { View } from 'react-native';
import style from './style';

export default function centerView(props) {
  return (
    <View style={style.main}>
      {props.children}
    </View>
  );
}

centerView.defaultProps = {
  children: null,
};

centerView.propTypes = {
  children: PropTypes.node,
};
