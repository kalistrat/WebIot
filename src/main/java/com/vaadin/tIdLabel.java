package com.vaadin;

import com.vaadin.ui.Label;

/**
 * Created by kalistrat on 20.02.2017.
 */
public class tIdLabel extends Label {

    Integer IdLabel;
    String tVal;

    public tIdLabel(Integer eId, String eVal){
        this.IdLabel = eId;
        this.tVal = eVal;
        this.setValue(this.tVal);
    }

    public void refrashValue(String newVal) {
        this.setValue(newVal);
    }
}
