package com.vaadin;

import com.vaadin.annotations.JavaScript;
import com.vaadin.ui.AbstractJavaScriptComponent;

import java.util.List;

/**
 * Created by kalistrat on 13.11.2017.
 */
@JavaScript({"d3.v3.js","com_example_vaadind3test_Diagram.js"})

public class Diagram extends AbstractJavaScriptComponent {
    public void setCoords(final List<Integer> coords) {
        getState().setCoords(coords);
    }

    @Override
    public DiagramState getState() {
        return (DiagramState) super.getState();
    }
}
