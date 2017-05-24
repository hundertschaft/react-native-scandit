/* @flow */

/* eslint
  no-underscore-dangle:
    ["error", { "allow": ["_commandPromiseHandler", "_nodeHandle", "_commandid"] }]
  no-console:
    0
*/

import { Component } from 'react';
import {
  findNodeHandle,
  NativeAppEventEmitter,
  Platform,
  UIManager,
} from 'react-native';

const eventEmitter = NativeAppEventEmitter;

type PromiseHandlerType = {
  commandid: number,
  resolve: Function,
  reject: Function,
  timeout: number,
}

function PromiseHandler() {
  this.handlers = {};

  eventEmitter.addListener(
    'COMMAND_DONE_EVENT_NAME', (event) => {
      const handler = this.handlers[event.commandid];
      if (handler) {
        this.remove(handler.commandid);
        if (event.type === 'resolve') {
          handler.resolve(event.result);
        } else {
          handler.reject(new Error(event.result));
        }
      }
    },
  );

  this.add = function add(handler: PromiseHandlerType) {
    this.handlers[handler.commandid] = { resolve: handler.resolve, reject: handler.reject };
  };

  this.remove = function remove(commandid) {
    const handler = this.handlers[commandid];
    if (handler) {
      clearTimeout(handler.timeout);
      delete this.handlers[commandid];
      // alert('Removed handler');
    } else {
      // alert('No handler for commandid ' + commandid);
    }
  };
}

class NativeComponent extends Component {

  // Android-specific code, for commands on Android don't handle promises
  static _commandid: number = 0;
  static _commandPromiseHandler: Object = new PromiseHandler();

  _nodeHandle: Object;

  nodeHandle() {
    if (!this._nodeHandle) {
      this._nodeHandle = findNodeHandle(this);
    }

    return this._nodeHandle;
  }

  dispatchCommand(command:any, args?: Array<any>): Promise<*> {
    return new Promise((resolve, reject) => {
      // if (1 === 1) return;

      if (typeof command === 'undefined') {
        // console.log('COMMAND ERROR! Command is "undefined".');
        return;
      }
      // console.log('COMMAND: ' + JSON.stringify(command));
      // console.log('COMMAND: ' + command);
      // console.log('COMMAND TYPE: ' + typeof command);
      let argArray;
      if (typeof args === 'undefined') {
        argArray = [];
      } else if (Array.isArray(args)) {
        argArray = args;
      } else {
        argArray = [args];
      }
      // if (typeof command === 'function') {
      if (Platform.OS === 'ios') {
        // iOS
        try {
          command.apply(
            this,
            [this.nodeHandle(), ...argArray],
          )
          .then((result) => { if (resolve) resolve(result); })
          .catch((result) => { if (reject) reject(result); });
        } catch (e) {
          // In case the command does not handle promises
        }
      } else if (Platform.OS === 'android') {
        // Android
        NativeComponent._commandid += 1;
        const commandid = NativeComponent._commandid;
        const timeout = setTimeout(() => {
          NativeComponent._commandPromiseHandler.remove(commandid);
        }, 2000);
        argArray.push({ commandid });

        // Since dispatchViewManagerCommand does not handle promises...
        NativeComponent._commandPromiseHandler.add({ commandid, resolve, reject, timeout });
        UIManager.dispatchViewManagerCommand(
          this.nodeHandle(),
          command,
          argArray,
        );
      }
    });
  }

}

export default NativeComponent;
