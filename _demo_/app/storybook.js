/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions, global-require */

import { AppRegistry } from 'react-native';
import { getStorybookUI, configure } from '@storybook/react-native';
import { storybookConfig } from "scandit/CONFIG.js";

// import stories
configure(() => {
  require('./component/button/story');
  require('./container/scanner/story');
  require('./scene/welcome/story');
}, module);

const StorybookUI = getStorybookUI(storybookConfig);
AppRegistry.registerComponent('scandit', () => StorybookUI);
export default StorybookUI;
