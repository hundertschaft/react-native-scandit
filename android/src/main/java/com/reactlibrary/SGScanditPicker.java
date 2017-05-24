/**
 * Created by Boris Conforty on 13.04.17.
 * Copyright © 2017 Salathé Group, EPFL. All rights reserved.
 */

package com.reactlibrary;

import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.EventDispatcher;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.scandit.barcodepicker.BarcodePicker;
import com.scandit.barcodepicker.OnScanListener;
import com.scandit.barcodepicker.ScanSession;
import com.scandit.barcodepicker.ScanSettings;
import com.scandit.recognition.Barcode;

import java.util.List;
import java.util.Locale;
import java.util.Map;


public class SGScanditPicker extends SimpleViewManager<BarcodePicker> implements OnScanListener {

    private static final String REACT_CLASS = "SGScanditPicker";

    private static final int COMMAND_STOP_SCANNING  = 0;
    private static final int COMMAND_START_SCANNING = 1;
    private static final int COMMAND_START_SCANNING_IN_PAUSED_STATE = 2;
    private static final int COMMAND_PAUSE_SCANNING = 3;
    private static final int COMMAND_SET_SETTINGS   = 4;
    private static final int COMMAND_GET_SETTINGS   = 5;

    public static final String COMMAND_DONE_EVENT_NAME = "COMMAND_DONE_EVENT_NAME";

    private static final Map<String, Integer> COMMAND_MAP = MapBuilder.of(
            "stopScanning" , COMMAND_STOP_SCANNING,
            "startScanning", COMMAND_START_SCANNING,
            "startScanningInPausedState", COMMAND_START_SCANNING_IN_PAUSED_STATE,
            "pauseScanning", COMMAND_PAUSE_SCANNING,
            "setSettings"  , COMMAND_SET_SETTINGS,
            "getSettings"  , COMMAND_GET_SETTINGS
    );

    private static final String DID_SCAN_EVENT_KEY_NAME = "SGScanditPickerDidScan";
    private static final String SETTINGS_DID_CHANGE_EVENT_KEY_NAME = "SGScanditPickerSettingsDidChange";

    private static final String DID_SCAN_EVENT_NAME = "onDidScan";
    private static final String SETTINGS_DID_CHANGE_EVENT_NAME = "onSettingsDidChange";

    private static final String NEWLY_RECOGNIZED_CODES = "newlyRecognizedCodes";

    private BarcodePicker picker;
    private ScanSettings scanSettings = ScanSettings.create();
    private EventDispatcher eventDispatcher;
    private RCTNativeAppEventEmitter nativeAppEventEmitter;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public BarcodePicker createViewInstance(ThemedReactContext context) {
        // Store event dispatcher for emission of events
        eventDispatcher = context.getNativeModule(UIManagerModule.class).getEventDispatcher();

        nativeAppEventEmitter = context.getJSModule(RCTNativeAppEventEmitter.class);

        // BarcodePicker extends View
        picker = new BarcodePicker(context, scanSettings);

        // Tell picker to call our didScan method on scan
        picker.setOnScanListener(this);

        return picker;
    }

    @ReactProp(name = "settings")
    public void setSettings(BarcodePicker view, @Nullable ReadableMap settings) {
        /* Source code shows that the following settings are handled:
             recognitionMode: "code", "text"
             codeDuplicateFilter: simply there or not
             cameraFacingPreference: "back", "front"
             workingRange: "standard", "long"
             deviceName: String
             relativeZoom: double
             highDensityModeEnabled: boolean
             codeRejectionEnabled: boolean
             restrictedAreaScanningEnabled: boolean
             scanningHotSpot: Point
             activeScanningAreaLandscape: Rect
             areaSettingsPortrait: ScanAreaSettings
             areaSettingsLandscape: ScanAreaSettings
             activeScanningAreaPortrait: Rect
             textRecognition: TextRecognitionSettings

           enabledSymbologies is handled separately, since ScanSettings.createWithJson does not
           seem to process it...
         */

        scanSettings = ScanditBarcodeHelpers.scanSettingsByMergingOldAndNew(scanSettings, settings);

        picker.applyScanSettings(scanSettings);

        emitSettings();
    }

    // Tell React Native the commands we respond to
    @Override
    public Map<String,Integer> getCommandsMap() {
        return COMMAND_MAP;
    }

    private void emitSettings() {
        WritableMap event = ScanditBarcodeHelpers.scanSettingsToWritableMap(scanSettings);

        eventDispatcher.dispatchEvent(new SettingsDidChangeEvent(picker.getId(), event));
        //this.deviceEventEmitterModule.emit(GET_SETTINGS_EVENT_NAME, event);
    }

    // This is called by React Native whenever a command is sent to us
    @Override
    public void receiveCommand(
            BarcodePicker view,
            int commandType,
            @Nullable final ReadableArray args) {

        int argCount = args == null ? 0 : args.size();
        final WritableMap promiseResponse = Arguments.createMap();
        if (argCount > 0) {
            if (args.getType(args.size() - 1) == ReadableType.Map) {
                ReadableMap map = args.getMap(args.size() - 1);
                if (map.hasKey("commandid")) {
                    int commandid = map.getInt("commandid");
                    promiseResponse.putInt("commandid", commandid);
                    argCount--;
                }
            }
        }

        switch (commandType) {
            case COMMAND_STOP_SCANNING: {
                picker.stopScanning();
                return;
            }
            case COMMAND_START_SCANNING: {
                picker.startScanning(false, new Runnable() {
                    @Override
                    public void run() {
                        new PromiseSender(promiseResponse) {
                            @Override
                            public Object getResponse() {
                                return "Scan started";
                            }
                        };
                    }
                });
                return;
            }
            case COMMAND_START_SCANNING_IN_PAUSED_STATE: {
                picker.startScanning(true);
                return;
            }
            case COMMAND_PAUSE_SCANNING: {
                picker.pauseScanning();
                return;
            }
            case COMMAND_SET_SETTINGS: {
                if (argCount > 0) {
                    ReadableMap map = args.getMap(0);
                    setSettings(null, map);
                    new PromiseSender(promiseResponse) {
                        @Override
                        public Object getResponse() {
                            return ScanditBarcodeHelpers.scanSettingsToWritableMap(scanSettings);
                        }
                    };
                } else {
                    final int c = argCount;
                    new PromiseSender(promiseResponse) {
                        @Override
                        public Object getResponse() {
                            promiseFailed = true;
                            return "Cannot set null settings" + c;
                        }
                    };
                }
                return;
            }
            case COMMAND_GET_SETTINGS: {
                new PromiseSender(promiseResponse) {
                    @Override
                    public Object getResponse() {
                        return ScanditBarcodeHelpers.scanSettingsToWritableMap(scanSettings);
                    }
                };
                emitSettings();
                return;
            }

            default:
                throw new IllegalArgumentException(String.format(
                        Locale.ENGLISH,
                        "Unsupported command %d received by %s.",
                        commandType,
                        getClass().getSimpleName()));
        }
    }

    @Nullable
    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        Log.d("React", "COMMANDS DONE2");
        return MapBuilder.builder()
                .put(SETTINGS_DID_CHANGE_EVENT_KEY_NAME,
                        MapBuilder.of("registrationName", SETTINGS_DID_CHANGE_EVENT_NAME))
                .put(DID_SCAN_EVENT_KEY_NAME,
                        MapBuilder.of("registrationName", DID_SCAN_EVENT_NAME))
                .build();
    }

    // Called by picker whenever a scan occurs
    public void didScan(ScanSession scanSession) {
        List<Barcode> newBarcodes = scanSession.getNewlyRecognizedCodes();

        WritableArray newlyRecognizedCodes = Arguments.createArray();
        for (Barcode barcode: newBarcodes) {
            newlyRecognizedCodes.pushMap(ScanditBarcodeHelpers.barcodeToWritableMap(barcode));
        }

        WritableMap event = Arguments.createMap();
        event.putArray(NEWLY_RECOGNIZED_CODES, newlyRecognizedCodes);

        eventDispatcher.dispatchEvent(new DidScanEvent(picker.getId(), event));
    }

    private class DidScanEvent extends NativeEvent<DidScanEvent> {
        public static final String EVENT_NAME = DID_SCAN_EVENT_KEY_NAME;

        protected DidScanEvent(int viewTag, WritableMap event) {
            super(viewTag, event);
        }

        @Override
        public String getEventName() {
            return EVENT_NAME;
        }
    }

    private class SettingsDidChangeEvent extends NativeEvent<SettingsDidChangeEvent> {
        public static final String EVENT_NAME = SETTINGS_DID_CHANGE_EVENT_KEY_NAME;

        protected SettingsDidChangeEvent(int viewTag, WritableMap event) {
            super(viewTag, event);
        }

        @Override
        public String getEventName() {
            return EVENT_NAME;
        }
    }

    private abstract class PromiseSender {

        public final WritableMap promiseResponse;
        public boolean promiseFailed = false;

        public PromiseSender(WritableMap promiseResponse) {
            this.promiseResponse = promiseResponse;
            if (promiseResponse.hasKey("commandid")) {
                addResponse();
                nativeAppEventEmitter.emit(COMMAND_DONE_EVENT_NAME, promiseResponse);
            }
        }

        public abstract Object getResponse();

        private void addResponse() {
            final String key = "result";
            Object value = getResponse();

            if (value instanceof Boolean)            promiseResponse.putBoolean(key, (Boolean)value);
            else if (value instanceof String)        promiseResponse.putString (key, (String)value);
            else if (value instanceof Double)        promiseResponse.putDouble (key, (Double)value);
            else if (value instanceof Integer)       promiseResponse.putInt    (key, (Integer)value);
            else if (value instanceof WritableMap)   promiseResponse.putMap    (key, (WritableMap) value);
            else if (value instanceof WritableArray) promiseResponse.putArray  (key, (WritableArray) value);
            else if (value == null)                  promiseResponse.putNull(key);

            if (promiseFailed) {
                promiseResponse.putString("type", "reject");
            } else {
                promiseResponse.putString("type", "resolve");
            }
        }
    }

}

