import React, { Component } from 'react';
import { AppRegistry, StyleSheet, View, Text, Button } from 'react-native';

// Uses Nodes' Module Resolution. Read this if you feel confused
// https://blog.callstack.io/a-cure-for-relative-requires-in-react-native-2b263cecf0f6
import Welcome from "@scene/welcome";
import CenterView from "@container/centerView";
import Scanner from "@container/scanner";

export default class App extends Component {

  constructor(props) {
    super(props);
    this.handleContinueButton = this.handleContinueButton.bind(this);
    this.state = { showScanner: false }
  }

  handleContinueButton() {
    this.setState({ showScanner: true });
  }

  render() {

    if (this.state.showScanner) {
      return (
        <Scanner />
      );
    } else {
      return (
        <CenterView >
          <Welcome />
          <Button title="Continue to Scanner" onPress={this.handleContinueButton} />
        </CenterView>
      );
    }

  }
}

AppRegistry.registerComponent('scandit', () => App);
