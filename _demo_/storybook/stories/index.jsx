/* eslint-disable import/no-extraneous-dependencies, import/no-unresolved, import/extensions */

import React from 'react';
import { Text } from 'react-native';

import { storiesOf } from '@storybook/react-native';
import { action } from '@storybook/addon-actions';
import { linkTo } from '@storybook/addon-links';

import button from '@component/button';
import centerView from '@container/centerView';
import Welcome from '@scene/Welcome';
import Scanner from '@container/Scanner';

storiesOf('Welcome', module).add('to Storybook', () => <Welcome showApp={linkTo('Button')} />);

storiesOf('Button', module)
  .addDecorator(getStory =>
    <centerView>
      {getStory()}
    </centerView>
  )
  .add('with text', () =>
    <button onPress={action('clicked-text')}>
      <Text>Hello Button Test</Text>
    </button>
  )
  .add('with some emoji', () =>
    <button onPress={action('clicked-emoji')}>
      <Text>😀 😎 👍 💯</Text>
    </button>
  );

storiesOf('Scanner', module).add('plain', () => <Scanner />);