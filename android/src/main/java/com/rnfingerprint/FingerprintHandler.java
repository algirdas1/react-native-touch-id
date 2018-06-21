package com.rnfingerprint;

import android.annotation.TargetApi;
import android.hardware.fingerprint.FingerprintManager;
import android.os.Build;
import android.content.Context;
import android.os.CancellationSignal;
import android.util.Log;

@TargetApi(Build.VERSION_CODES.M)
public class FingerprintHandler extends FingerprintManager.AuthenticationCallback {

    private CancellationSignal cancellationSignal;
    private boolean selfCancelled;

    private final FingerprintManager mFingerprintManager;
    private final Callback mCallback;

    public FingerprintHandler(Context context, Callback callback) {
        mFingerprintManager = context.getSystemService(FingerprintManager.class);
        mCallback = callback;
    }

    public void startAuth(FingerprintManager.CryptoObject cryptoObject) {
        cancellationSignal = new CancellationSignal();
        selfCancelled = false;
        mFingerprintManager.authenticate(cryptoObject, cancellationSignal, 0, this, null);
    }

    public void endAuth() {
        cancelAuthenticationSignal();
    }

    @Override
    public void onAuthenticationError(int errMsgId,
                                      CharSequence errString) {
        if (!selfCancelled) {
            mCallback.onError(errMsgId, errString.toString());
        }
    }

    @Override
    public void onAuthenticationFailed() {
        mCallback.onFailed();
    }

    @Override
    public void onAuthenticationSucceeded(FingerprintManager.AuthenticationResult result) {
        mCallback.onAuthenticated();
    }

    private void cancelAuthenticationSignal() {
        selfCancelled = true;
        if (cancellationSignal != null) {
            cancellationSignal.cancel();
            cancellationSignal = null;
        }
    }

    public interface Callback {
        void onAuthenticated();

        void onError(int errorCode, String errorString);

        void onCancelled();

        void onFailed();
    }
}
