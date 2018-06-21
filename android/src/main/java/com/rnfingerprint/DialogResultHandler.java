package com.rnfingerprint;

import com.facebook.react.bridge.Callback;

import java.util.HashMap;
import java.util.Map;

public class DialogResultHandler implements FingerprintDialog.DialogResultListener {
    private Callback errorCallback;
    private Callback successCallback;

    public DialogResultHandler(Callback reactErrorCallback, Callback reactSuccessCallback) {
      errorCallback = reactErrorCallback;
      successCallback = reactSuccessCallback;
    }

    @Override
    public void onAuthenticated() {
      FingerprintAuthModule.inProgress = false;
      successCallback.invoke("Successfully authenticated.");
    }
    @Override
    public void onError(int errorCode, String errorString) {
      FingerprintAuthModule.inProgress = false;
      errorCallback.invoke(errorCode, errorString);
    }

    @Override
    public void onCancelled() {
      FingerprintAuthModule.inProgress = false;
        errorCallback.invoke(FingerprintAuthModule.FINGERPRINT_CANCELLED_BY_USER, "cancelled");
    }
}
