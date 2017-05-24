/**
 * Created by BDC on 25.04.17.
 * Copyright © 2017 Salathé Group, EPFL. All rights reserved.
 */

package com.reactlibrary;

import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.RectF;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.scandit.barcodepicker.ScanAreaSettings;
import com.scandit.barcodepicker.ScanSettings;
import com.scandit.base.util.JSONParseException;
import com.scandit.recognition.Barcode;
import com.scandit.recognition.BarcodeScannerSettings;
import com.scandit.recognition.Quadrilateral;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;


public class ScanditBarcodeHelpers {

    public static int stringToSymbology(String string) {
        for (int symbology: Barcode.ALL_SYMBOLOGIES) {
            if (Barcode.symbologyToString(symbology).equalsIgnoreCase(string)) {
                return symbology;
            }
        }
        return Barcode.SYMBOLOGY_UNKNOWN;
    }

    static public WritableMap pointToWritableMap(Point point) {
        WritableMap map = Arguments.createMap();
        map.putInt("x", point.x);
        map.putInt("y", point.y);
        return map;
    }

    static public WritableMap quadrilateralToWritableMap(Quadrilateral quadrilateral) {
        WritableMap map = Arguments.createMap();
        map.putMap("bottomRight", pointToWritableMap(quadrilateral.bottom_right));
        map.putMap("bottomLeft" , pointToWritableMap(quadrilateral.bottom_left));
        map.putMap("topRight"   , pointToWritableMap(quadrilateral.top_right));
        map.putMap("topLeft"    , pointToWritableMap(quadrilateral.top_left));
        return map;
    }

    static public WritableMap barcodeToWritableMap(Barcode barcode) {
        WritableMap map = Arguments.createMap();
        map.putInt    ("compositeFlag",    barcode.getCompositeFlag());
        map.putString ("data",             barcode.getData());
        map.putBoolean("isRecognized",     barcode.isRecognized());
        map.putBoolean("isGs1DataCarrier", barcode.isGs1DataCarrier());
        map.putInt    ("symbolCount",      barcode.getSymbolCount());
        map.putInt    ("symbology",        barcode.getSymbology());
        map.putString ("symbologyName",    barcode.getSymbologyName());
        map.putMap    ("location",         quadrilateralToWritableMap(barcode.getLocation()));
        return map;
    }

    private static final String ENABLEDSYMBOLOGIES = "enabledSymbologies";

    static public ScanSettings scanSettingsByMergingOldAndNew(ScanSettings old, ReadableMap newMap) {
        if (newMap == null) return old;

        // Convert new settings to JSON
        JSONObject newSettingsJson;
        try {
            newSettingsJson = ReactBridgeHelpers.convertMapToJson(newMap);
        } catch (JSONException error) {
            Log.e("React", "Could not convert ReadableMap settings to JSON");
            return old;
        }

        // Convert current settings to JSON
        JSONObject currentScanSettingsJson;
        try {
            currentScanSettingsJson = old.toJSON();
        } catch (JSONException e) {
            Log.e("React", "Could not convert scan settings to JSON");
            return old;
        }

        // Append/replace new settings
        Iterator<?> keys = newSettingsJson.keys();
        while (keys.hasNext()) {
            String key = (String)keys.next();
            try {
                currentScanSettingsJson.put(key, newSettingsJson.get(key));
            } catch (JSONException e) {
                Log.e("React", "Could not append value of settings key '" + key + "'");
            }
        }

        ScanSettings scanSettings;
        // Create new scanSettings from JSONObject
        try {
            scanSettings = ScanSettings.createWithJson(currentScanSettingsJson);
        } catch (JSONParseException error) {
            Log.e("React", "Could not create ScanSettings from JSON");
            return old;
        }

        // ScanSettings.createWithJson does not seem to handle "enabledSymbologies"...
        if (currentScanSettingsJson.has(ENABLEDSYMBOLOGIES)) {
            try {
                JSONArray enabledSymbology = currentScanSettingsJson.getJSONArray(ENABLEDSYMBOLOGIES);
                int length = enabledSymbology.length();
                for (int i=0; i<length; i++) {
                    String symbology = enabledSymbology.getString(i);
                    int symbologyCode = ScanditBarcodeHelpers.stringToSymbology(symbology);
                    scanSettings.setSymbologyEnabled(symbologyCode, true);
                }
            } catch (JSONException e) {
                Log.e("React", "Could not convert enabledSymbologies to JSONArray");
            }
        }

        return scanSettings;
    }

    static public WritableArray jsonArrayToWritableArray(JSONArray json) {
        WritableArray array = Arguments.createArray();

        int size = json.length();
        for (int i=0; i<size; i++) {
            Object value = null;
            try {
                value = json.get(i);

                if (value instanceof Boolean)            array.pushBoolean((Boolean)value);
                else if (value instanceof String)        array.pushString ((String)value);
                else if (value instanceof Double)        array.pushDouble ((Double)value);
                else if (value instanceof Integer)       array.pushInt    ((Integer)value);
                else if (value instanceof WritableMap)   array.pushMap    ((WritableMap) value);
                else if (value instanceof WritableArray) array.pushArray  ((WritableArray) value);
                else if (value == null)                  array.pushNull();
                else if (value instanceof JSONArray) {
                    array.pushArray(jsonArrayToWritableArray((JSONArray)value));
                }
                else if (value instanceof JSONObject) {
                    array.pushMap(jsonObjectToWritableMap((JSONObject)value));
                }

                else Log.e("React", "Value type not handled: " + value.getClass());

            } catch (JSONException e) {
                Log.e("React", "Could get value of JSONArray item at index " + i);
            }
        }

        return array;
    }

    static public WritableMap jsonObjectToWritableMap(JSONObject json) {
        WritableMap map = Arguments.createMap();

        Iterator<?> keys = json.keys();
        while (keys.hasNext()) {
            String key = (String)keys.next();
            try {
                Object value = json.get(key);
                if (value instanceof Boolean)            map.putBoolean(key, (Boolean)value);
                else if (value instanceof String)        map.putString (key, (String)value);
                else if (value instanceof Double)        map.putDouble (key, (Double)value);
                else if (value instanceof Integer)       map.putInt    (key, (Integer)value);
                else if (value instanceof WritableMap)   map.putMap    (key, (WritableMap) value);
                else if (value instanceof WritableArray) map.putArray  (key, (WritableArray) value);
                else if (value == null)                  map.putNull(key);
                else if (value instanceof JSONArray) {
                    map.putArray(key, jsonArrayToWritableArray((JSONArray)value));
                }
                else if (value instanceof JSONObject) {
                    map.putMap(key, jsonObjectToWritableMap((JSONObject)value));
                }

                else Log.e("React", "Value type not handled: " + value.getClass());

            } catch (JSONException e) {
                Log.e("React", "Could not append value of settings key '" + key + "'");
            }
        }

        return map;
    }

    static public String cameraFacingPreferenceToString(int cameraFacingPreference) {
        switch (cameraFacingPreference) {
            case ScanSettings.CAMERA_FACING_BACK : return "back";
            case ScanSettings.CAMERA_FACING_FRONT: return "front";
        }
        return "Unknown";
    }

    static public String workingRangeToString(int workingRange) {
        switch (workingRange) {
            case ScanSettings.WORKING_RANGE_LONG    : return "long";
            case ScanSettings.WORKING_RANGE_STANDARD: return "standard";
        }
        return "Unknown";
    }

    static public String recognitionModeToString(int recognitionMode) {
        switch (recognitionMode) {
            case ScanSettings.RECOGNITION_MODE_CODE: return "code";
            case ScanSettings.RECOGNITION_MODE_TEXT: return "text";
        }
        return "Unknown";
    }

    static public WritableMap pointToWritableMap(PointF point) {
        WritableMap map = Arguments.createMap();
        map.putDouble("x", point.x);
        map.putDouble("y", point.y);
        return map;
    }

    static public WritableMap rectToWritableMap(RectF rect) {
        WritableMap map = Arguments.createMap();
        map.putDouble("x", rect.left);
        map.putDouble("y", rect.top);
        map.putDouble("width", rect.width());
        map.putDouble("height", rect.height());
        return map;
    }

    static public String locationContraintToString(int constraint) {
        if (constraint == BarcodeScannerSettings.CODE_LOCATION_RESTRICT) {
            return "restrict";
        } else if (constraint == BarcodeScannerSettings.CODE_LOCATION_HINT) {
            return "hint";
        } else {
            return "unknown";
        }
    }

    static public WritableMap scanAreaToWritableMap(ScanAreaSettings settings) {
        if (settings == null) return null;

        WritableMap map = Arguments.createMap();
        switch (settings.primaryDirection) {
            case 1:
                map.putString("primaryDirection", "vertical");
                break;
            case 2:
                map.putString("primaryDirection", "horizontal");
                break;
            default:
                map.putString("primaryDirection", "unknown");
                break;
        }
        map.putMap("searchArea", rectToWritableMap(settings.searchArea));

        map.putMap("squareCodeLocationArea", rectToWritableMap(settings.squareCodeLocationArea));
        map.putString("squareCodeLocationConstraint", locationContraintToString(settings.squareCodeLocationConstraint));

        map.putMap("wideCodeLocationArea", rectToWritableMap(settings.wideCodeLocationArea));
        map.putString("wideCodeLocationConstraint", locationContraintToString(settings.wideCodeLocationConstraint));

        return map;
    }

    static public WritableMap scanSettingsToWritableMap(ScanSettings scanSettings) {
        WritableMap map;
        try {
            JSONObject json = scanSettings.toJSON();

            // Handle values that, strangely, are not put in json by Scandit framework
            if (!json.has("cameraFacingPreference")) {
                json.put("cameraFacingPreference", cameraFacingPreferenceToString(scanSettings.getCameraFacingPreference()));
            }
            if (!json.has("recognitionMode")) {
                json.put("recognitionMode", recognitionModeToString(scanSettings.getRecognitionMode()));
            }
            if (!json.has("codeCachingDuration")) {
                json.put("codeCachingDuration", scanSettings.getCodeCachingDuration());
            }
            if (!json.has("codeDuplicateFilter")) {
                json.put("codeDuplicateFilter", scanSettings.getCodeDuplicateFilter());
            }
            if (!json.has("codeRejectionEnabled")) {
                json.put("codeRejectionEnabled", scanSettings.isCodeRejectionEnabled());
            }
            if (!json.has("highDensityModeEnabled")) {
                json.put("highDensityModeEnabled", scanSettings.isHighDensityModeEnabled());
            }
            if (!json.has("matrixScanEnabled")) {
                json.put("matrixScanEnabled", scanSettings.isMatrixScanEnabled());
            }
            if (!json.has("maxNumberOfCodesPerFrame")) {
                json.put("maxNumberOfCodesPerFrame", scanSettings.getMaxNumberOfCodesPerFrame());
            }
            if (!json.has("relativeZoom")) {
                json.put("relativeZoom", scanSettings.getRelativeZoom());
            }
            if (!json.has("scanningHotSpot")) {
                json.put("scanningHotSpot", pointToWritableMap(scanSettings.getScanningHotSpot()));
            }
            if (!json.has("areaSettingsLandscape")) {
                json.put("areaSettingsLandscape", scanAreaToWritableMap(scanSettings.getAreaSettingsLandscape()));
            }
            if (!json.has("areaSettingsPortrait")) {
                json.put("areaSettingsPortrait", scanAreaToWritableMap(scanSettings.getAreaSettingsPortrait()));
            }

            // Handle values that, strangely, are put as codes instead of strings
            json.put("workingRange", workingRangeToString(scanSettings.getWorkingRange()));

            // TODO: textRecognition

            map = jsonObjectToWritableMap(json);

        } catch (JSONException e) {
            Log.e("React", "Could not convert scan settings to JSON");
            map = Arguments.createMap();
        }
        return map;
    }
}
