package com.vaadin;

import com.vaadin.shared.ui.JavaScriptComponentState;

import java.util.List;

/**
 * Created by kalistrat on 13.11.2017.
 */
public class DiagramState extends JavaScriptComponentState {
    private List<tDetectorDiagramData> measuresData;

    public List<tDetectorDiagramData> getGraphData() {
        return measuresData;
    }

    public void setGraphData(List<tDetectorDiagramData> listData) {
        this.measuresData = listData;
    }
}
