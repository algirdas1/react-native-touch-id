import { NativeModules } from 'react-native';
import { createError } from './TouchIDError';

const { isSupported, authenticate, ...errors } = NativeModules.TouchID;

export default {
  ...errors,
  isSupported: () => {
    return new Promise((resolve, reject) => {
      isSupported((error, biometryType) => {
        resolve({ supported: (error ? false : true), biometryType });
      });
    });
  },

  authenticate: (reason, config) => {
    const DEFAULT_CONFIG = { fallbackLabel: null };
    const authReason = reason ? reason : ' ';
    const authConfig = config ? config : DEFAULT_CONFIG;

    return new Promise((resolve, reject) => {
      authenticate(authReason, authConfig, error => {
        if (error) {
          reject(createError({ code: error.code, message: error.message }));
        } else {
          resolve(true);
        }
      });
    });
  }
};

// function TouchIDError(name, details) {
//   this.name = name || 'TouchIDError';
//   this.message = details.message || 'Touch ID Error';
//   this.details = details || {};
// }

// TouchIDError.prototype = Object.create(Error.prototype);
// TouchIDError.prototype.constructor = TouchIDError;

// function createError(error) {
//   let details = ERRORS[error];
//   details.name = error;

//   return new TouchIDError(error, details);
// }
