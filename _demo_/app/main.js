import React, { Component } from 'react';
import { AppRegistry, StyleSheet, View, Text } from 'react-native';

// Uses Nodes' Module Resolution. Read this if you feel confused
// https://blog.callstack.io/a-cure-for-relative-requires-in-react-native-2b263cecf0f6
import Welcome from "@scene/welcome";
import CenterView from "@container/centerView";

export default class App extends Component {
  render() {
    return (
      <CenterView>
        <Welcome />
      </CenterView>
    );
  }
}

AppRegistry.registerComponent('scandit', () => App);
