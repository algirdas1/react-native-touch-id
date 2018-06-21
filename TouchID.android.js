import { NativeModules, processColor } from 'react-native';
import { createError } from './TouchIDError';

const { isSupported, authenticate, ...errors } = NativeModules.FingerprintAuth;

export default {
  ...errors,
  isSupported: () => {
    return new Promise((resolve, reject) => {
      isSupported(
        error => {
          resolve({ supported: false, biometryType: 'TouchID' });
        },
        success => {
          resolve({ supported: true, biometryType: 'TouchID' });
        }
      );
    });
  },

  authenticate: (reason, config) => {
    DEFAULT_CONFIG = { title: 'Authentication Required', color: '#0264a6' };
    var authReason = reason ? reason : undefined;
    var authConfig = Object.assign({}, DEFAULT_CONFIG, config);
    var color = processColor(authConfig.color);

    authConfig.color = color;

    return new Promise((resolve, reject) => {
      authenticate(
        authReason,
        authConfig,
        (errorCode, errorMessage) => {
          console.log('error', errorCode, errorMessage);
          return reject(typeof error == 'String' ? createError(errorMessage, errorMessage) : createError(errorMessage));
        },
        success => {
          resolve(true);
        }
      );
    });
  }
};