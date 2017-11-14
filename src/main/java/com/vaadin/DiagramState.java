package com.vaadin;

import com.vaadin.shared.ui.JavaScriptComponentState;

import java.util.List;

/**
 * Created by kalistrat on 13.11.2017.
 */
public class DiagramState extends JavaScriptComponentState {
    private String graphFileName;

    public String getGraphFileName() {
        return graphFileName;
    }

    public void setGraphFileName(String fileName) {
        this.graphFileName = fileName;
    }
}
