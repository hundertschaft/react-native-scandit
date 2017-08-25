/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React from 'react';
import { Text } from 'react-native';

import { storiesOf } from '@storybook/react-native';
import { linkTo } from '@storybook/addon-links';

import Welcome from '@scene/welcome';

storiesOf('Welcome', module).add('to Storybook', () => <Welcome showApp={linkTo('Button')} />);
