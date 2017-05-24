/**
 * Created by Boris Conforty on 13.04.17.
 * Copyright © 2017 Salathé Group, EPFL. All rights reserved.
 */

package com.reactlibrary;

import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;

import com.scandit.barcodepicker.ScanditLicense;

import java.util.HashMap;
import java.util.Map;

import static com.scandit.recognition.Native.sc_get_framework_version;

public class SGScanditModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public SGScanditModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
    return "SGScandit";
  }

    @Override
    public @Nullable
    Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put("SDK_VERSION", sc_get_framework_version());
        constants.put("COMMAND_DONE_EVENT_NAME", SGScanditPicker.COMMAND_DONE_EVENT_NAME);

        return constants;
    }

    @ReactMethod
    public void setAppKey(String key) {
        ScanditLicense.setAppKey(key);
        Log.d(getName(), "Scandit Licence - App key set");
    }
}