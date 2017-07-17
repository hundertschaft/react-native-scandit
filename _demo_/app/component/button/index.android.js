/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React, { PropTypes } from 'react';
import { TouchableNativeFeedback } from 'react-native';

export default function button(props) {
  return (
    <TouchableNativeFeedback onPress={props.onPress}>
      {props.children}
    </TouchableNativeFeedback>
  );
}

button.defaultProps = {
  children: null,
  onPress: () => { },
};

button.propTypes = {
  children: PropTypes.node,
  onPress: PropTypes.func,
};
