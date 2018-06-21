import { NativeModules, processColor } from 'react-native';
const NativeTouchID = NativeModules.FingerprintAuth;
// Android provides more flexibility than iOS for handling the Fingerprint. Currently the config object accepts customizable title or color. Otherwise it defaults to this constant

const { isSupported, authenticate, ...errors } = NativeTouchID;

export default {
  ...errors,
  isSupported: () => {
    return new Promise((resolve, reject) => {
      NativeTouchID.isSupported(
        error => {
          return resolve({ supported: false, biometryType: 'TouchID' });
        },
        success => {
          return resolve({ supported: true, biometryType: 'TouchID' });
        }
      );
    });
  },
  authenticate: (reason, config) => {
    DEFAULT_CONFIG = { title: 'Authentication Required', color: '#0264a6' };
    var authReason = reason ? reason : ' ';
    var authConfig = Object.assign({}, DEFAULT_CONFIG, config);
    var color = processColor(authConfig.color);

    authConfig.color = color;

    return new Promise((resolve, reject) => {
      NativeTouchID.authenticate(
        authReason,
        authConfig,
        (errorCode, errorMessage) => {
          return reject(createError({ code: errorCode, message: errorMessage }));
        },
        success => {
          return resolve(true);
        }
      );
    });
  }
};

function TouchIDError(name, details) {
  this.name = name || 'TouchIDError';
  this.message = details.message || 'Touch ID Error';
  this.code = details.code;
  this.details = details || {};
}

TouchIDError.prototype = Object.create(Error.prototype);
TouchIDError.prototype.constructor = TouchIDError;

function createError(error) {
  return new TouchIDError('Touch ID Error', error);
}
