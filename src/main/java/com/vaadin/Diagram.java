package com.vaadin;

import com.vaadin.annotations.JavaScript;
import com.vaadin.ui.AbstractJavaScriptComponent;

import java.util.List;

/**
 * Created by kalistrat on 13.11.2017.
 */
@JavaScript({"d3.min.js","diagram_connector.js"})

public class Diagram extends AbstractJavaScriptComponent {
    public void setFileData(String fileName) {
        getState().setGraphFileName(fileName);
    }

    @Override
    public DiagramState getState() {
        return (DiagramState) super.getState();
    }
}
