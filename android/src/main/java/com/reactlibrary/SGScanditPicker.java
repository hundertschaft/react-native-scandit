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
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
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

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public BarcodePicker createViewInstance(ThemedReactContext context) {
        // Store event dispatcher for emission of events
        this.eventDispatcher = context.getNativeModule(UIManagerModule.class).getEventDispatcher();

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

        this.eventDispatcher.dispatchEvent(new SettingsDidChangeEvent(picker.getId(), event));
        //this.deviceEventEmitterModule.emit(GET_SETTINGS_EVENT_NAME, event);
    }

    // This is called by React Native whenever a command is sent to us
    @Override
    public void receiveCommand(
            BarcodePicker view,
            int commandType,
            @Nullable ReadableArray args) {
        switch (commandType) {
            case COMMAND_STOP_SCANNING: {
                picker.stopScanning();
                return;
            }
            case COMMAND_START_SCANNING: {
                picker.startScanning();
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
                if (args != null && args.size() > 0) {
                    ReadableMap map = args.getMap(0);
                    setSettings(null, map);
                }
                return;
            }
            case COMMAND_GET_SETTINGS: {
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

        this.eventDispatcher.dispatchEvent(new DidScanEvent(picker.getId(), event));
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

}

