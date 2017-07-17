/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React, { PropTypes } from 'react';
import { TouchableHighlight } from 'react-native';

export default function button(props) {
  return (
    <TouchableHighlight onPress={props.onPress}>
      {props.children}
    </TouchableHighlight>
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
