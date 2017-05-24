package com.reactlibrary;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.RCTEventEmitter;

/**
 * Created by BDC on 23.05.17.
 */

public abstract class NativeEvent<T extends Event> extends Event<T> {

    private final WritableMap event;

    protected NativeEvent(int viewTag, WritableMap event) {
        super(viewTag);
        this.event = event;
    }

    @Override
    public void dispatch(RCTEventEmitter rctEventEmitter) {
        rctEventEmitter.receiveEvent(getViewTag(), getEventName(), this.event);
    }
}

